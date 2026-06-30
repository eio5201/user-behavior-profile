这个文件包含 Hive 查询结果导出命令，方便 Python 读取。
USE user_profile_dw;

INSERT OVERWRITE LOCAL DIRECTORY '/home/hadoop/result/ads_user_profile'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
SELECT user_id, active_level, consume_level, purchase_intention, user_value_level, profile_update_time
FROM ads_user_profile;

INSERT OVERWRITE LOCAL DIRECTORY '/home/hadoop/result/dws_user_preference_category'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
SELECT user_id, preference_category
FROM dws_user_preference_category;

INSERT OVERWRITE LOCAL DIRECTORY '/home/hadoop/result/behavior_type'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
SELECT behavior_type, COUNT(*) AS behavior_count
FROM dwd_user_behavior_detail
GROUP BY behavior_type;

INSERT OVERWRITE LOCAL DIRECTORY '/home/hadoop/result/active_level'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
SELECT active_level, COUNT(*) AS user_count
FROM ads_user_profile
GROUP BY active_level;

INSERT OVERWRITE LOCAL DIRECTORY '/home/hadoop/result/consume_level'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
SELECT consume_level, COUNT(*) AS user_count
FROM ads_user_profile
GROUP BY consume_level;

INSERT OVERWRITE LOCAL DIRECTORY '/home/hadoop/result/purchase_intention'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
SELECT purchase_intention, COUNT(*) AS user_count
FROM ads_user_profile
GROUP BY purchase_intention;

INSERT OVERWRITE LOCAL DIRECTORY '/home/hadoop/result/user_value'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
SELECT user_value_level, COUNT(*) AS user_count
FROM ads_user_profile
GROUP BY user_value_level;

INSERT OVERWRITE LOCAL DIRECTORY '/home/hadoop/result/category_top10'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
SELECT preference_category, COUNT(*) AS user_count
FROM dws_user_preference_category
GROUP BY preference_category
ORDER BY user_count DESC
LIMIT 10;
