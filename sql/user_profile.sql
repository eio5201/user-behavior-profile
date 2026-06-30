这个文件包含：

建库
建表
数据清洗
汇总统计
兴趣得分
偏好类别
核心画像表生成

CREATE DATABASE IF NOT EXISTS user_profile_dw;
USE user_profile_dw;

SET hive.execution.engine=mr;
SET mapreduce.framework.name=local;
SET hive.exec.mode.local.auto=true;
SET mapreduce.map.memory.mb=1024;
SET mapreduce.reduce.memory.mb=1024;
SET mapreduce.map.java.opts=-Xmx768m;
SET mapreduce.reduce.java.opts=-Xmx768m;
SET io.sort.mb=32;
SET mapreduce.task.io.sort.mb=32;

DROP TABLE IF EXISTS ods_user_behavior;

CREATE EXTERNAL TABLE ods_user_behavior (
    user_id STRING,
    item_id STRING,
    category_id STRING,
    behavior_type STRING,
    behavior_time BIGINT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/user/hive/user_profile/ods';

DROP TABLE IF EXISTS dwd_user_behavior_detail;

CREATE TABLE dwd_user_behavior_detail (
    user_id STRING,
    item_id STRING,
    category_id STRING,
    behavior_type STRING,
    behavior_date STRING,
    behavior_hour STRING
)
STORED AS ORC;

INSERT OVERWRITE TABLE dwd_user_behavior_detail
SELECT
    user_id,
    item_id,
    category_id,
    behavior_type,
    from_unixtime(behavior_time, 'yyyy-MM-dd') AS behavior_date,
    from_unixtime(behavior_time, 'HH') AS behavior_hour
FROM ods_user_behavior
WHERE user_id IS NOT NULL
  AND item_id IS NOT NULL
  AND category_id IS NOT NULL
  AND behavior_type IN ('pv', 'fav', 'cart', 'buy')
  AND behavior_time > 0;

DROP TABLE IF EXISTS dws_user_behavior_summary;

CREATE TABLE dws_user_behavior_summary (
    user_id STRING,
    pv_count BIGINT,
    fav_count BIGINT,
    cart_count BIGINT,
    buy_count BIGINT,
    active_days BIGINT,
    last_active_date STRING,
    category_count BIGINT
)
STORED AS ORC;

INSERT OVERWRITE TABLE dws_user_behavior_summary
SELECT
    user_id,
    SUM(CASE WHEN behavior_type = 'pv' THEN 1 ELSE 0 END) AS pv_count,
    SUM(CASE WHEN behavior_type = 'fav' THEN 1 ELSE 0 END) AS fav_count,
    SUM(CASE WHEN behavior_type = 'cart' THEN 1 ELSE 0 END) AS cart_count,
    SUM(CASE WHEN behavior_type = 'buy' THEN 1 ELSE 0 END) AS buy_count,
    COUNT(DISTINCT behavior_date) AS active_days,
    MAX(behavior_date) AS last_active_date,
    COUNT(DISTINCT category_id) AS category_count
FROM dwd_user_behavior_detail
GROUP BY user_id;

DROP TABLE IF EXISTS dws_user_category_score;

CREATE TABLE dws_user_category_score (
    user_id STRING,
    category_id STRING,
    category_score BIGINT
)
STORED AS ORC;

INSERT OVERWRITE TABLE dws_user_category_score
SELECT
    user_id,
    category_id,
    SUM(
        CASE behavior_type
            WHEN 'pv' THEN 1
            WHEN 'fav' THEN 2
            WHEN 'cart' THEN 3
            WHEN 'buy' THEN 5
            ELSE 0
        END
    ) AS category_score
FROM dwd_user_behavior_detail
GROUP BY user_id, category_id;

DROP TABLE IF EXISTS dws_user_preference_category;

CREATE TABLE dws_user_preference_category (
    user_id STRING,
    preference_category STRING
)
STORED AS ORC;

INSERT OVERWRITE TABLE dws_user_preference_category
SELECT
    user_id,
    category_id AS preference_category
FROM (
    SELECT
        user_id,
        category_id,
        category_score,
        ROW_NUMBER() OVER (
            PARTITION BY user_id
            ORDER BY category_score DESC
        ) AS rn
    FROM dws_user_category_score
) t
WHERE rn = 1;

DROP TABLE IF EXISTS ads_user_profile;

CREATE TABLE ads_user_profile (
    user_id STRING,
    active_level STRING,
    consume_level STRING,
    purchase_intention STRING,
    user_value_level STRING,
    profile_update_time STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

INSERT OVERWRITE TABLE ads_user_profile
SELECT
    s.user_id,
    CASE
        WHEN s.active_days >= 7 OR s.pv_count >= 100 THEN '高活跃用户'
        WHEN s.active_days BETWEEN 3 AND 6 OR s.pv_count BETWEEN 30 AND 99 THEN '中活跃用户'
        ELSE '低活跃用户'
    END AS active_level,
    CASE
        WHEN s.buy_count >= 10 THEN '高消费用户'
        WHEN s.buy_count BETWEEN 3 AND 9 THEN '中消费用户'
        WHEN s.buy_count BETWEEN 1 AND 2 THEN '低消费用户'
        WHEN s.buy_count = 0 AND (s.cart_count > 0 OR s.fav_count > 0) THEN '潜在消费用户'
        ELSE '无消费用户'
    END AS consume_level,
    CASE
        WHEN s.buy_count > 0 THEN '已购买用户'
        WHEN s.cart_count >= 5 OR s.fav_count >= 5 THEN '强购买意向'
        WHEN s.cart_count BETWEEN 2 AND 4 OR s.fav_count BETWEEN 2 AND 4 THEN '中购买意向'
        ELSE '弱购买意向'
    END AS purchase_intention,
    CASE
        WHEN (s.active_days >= 7 OR s.pv_count >= 100) AND s.buy_count >= 10 THEN '高价值用户'
        WHEN (s.active_days >= 7 OR s.pv_count >= 100) AND s.buy_count < 3 THEN '潜力用户'
        WHEN s.active_days BETWEEN 3 AND 6 OR s.buy_count BETWEEN 3 AND 9 THEN '普通用户'
        ELSE '流失风险用户'
    END AS user_value_level,
    CAST(current_timestamp() AS STRING) AS profile_update_time
FROM dws_user_behavior_summary s;
