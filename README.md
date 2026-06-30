# user-behavior-profile

# 基于Hive数据仓库的电商用户画像系统的设计与实现

## 项目简介

本项目是大数据编程课程设计，题目为**基于Hive数据仓库的电商用户画像系统的设计与实现**。  
系统以阿里天池 `UserBehavior` 用户行为数据集为基础，结合 Hadoop、HDFS、Hive 和 Python 等技术，完成了用户行为数据的分布式存储、数据清洗、行为统计、画像标签生成以及可视化展示。

项目主要实现了以下功能：

- 将用户行为数据上传到 HDFS
- 使用 Hive 构建 ODS、DWD、DWS、ADS 分层数据仓库
- 统计用户浏览、收藏、加购、购买等行为
- 计算用户兴趣偏好类别
- 生成用户活跃度、消费能力、购买意向、用户价值等画像标签
- 使用 Python 合并 Hive 导出结果并进行可视化展示

---

## 技术栈

- **Hadoop 3.3.6**
- **HDFS**
- **Hive 4.0.1**
- **Python 3**
- **matplotlib**
- **CSV / SQL / Shell**

---

## 数据集说明

本项目使用阿里天池公开数据集 **UserBehavior**。  
原始数据包含以下字段：

- `user_id`：用户ID
- `item_id`：商品ID
- `category_id`：商品类别ID
- `behavior_type`：行为类型
- `behavior_time`：行为时间戳

行为类型包括：

- `pv`：浏览
- `fav`：收藏
- `cart`：加入购物车
- `buy`：购买

由于实验环境内存有限，项目中随机抽取了部分数据作为实验样本进行分析。

---

## 项目功能

### 1. 数据存储
将用户行为数据上传至 HDFS 中进行分布式存储。

### 2. 数据清洗
通过 Hive 对原始数据进行过滤、清洗和时间字段转换。

### 3. 数据仓库分层
构建了以下数据仓库层次：

- `ODS`：原始数据层
- `DWD`：明细数据层
- `DWS`：汇总统计层
- `ADS`：应用结果层

### 4. 用户画像生成
生成以下画像标签：

- 活跃等级
- 消费等级
- 购买意向
- 用户价值等级
- 商品偏好类别

### 5. 结果可视化
使用 Python 对 Hive 导出的统计结果进行合并与可视化，生成图表用于课程设计报告展示。

---

## 项目结构

```text
.
├── sql/
│   ├── user_profile.sql
│   └── export_result.sql
├── python/
│   ├── merge_user_profile.py
│   └── draw_user_profile.py
├── report/
│   └── 基于Hive数据仓库的电商用户画像系统的设计与实现.pdf
├── docs/
│   ├── architecture.png
│   └── screenshots/
├── sample/
│   └── user_profile_merged_sample.csv
└── README.md

运行环境
1. Linux 环境
建议使用虚拟机或 Linux 服务器运行。

2. Hadoop 环境
确保 Hadoop、HDFS 和 YARN 已正常启动。

3. Hive 环境
确保 Hive 已正确安装，并且能够连接 HDFS。

4. Python 环境
Python 3 安装完成，并已安装 matplotlib。

运行步骤
第一步：上传数据到 HDFS
mkdir -p ~/data
head -n 10000 /mnt/hgfs/UserBehavior.csv/UserBehavior.csv > ~/data/UserBehavior_10000.csv
hdfs dfs -mkdir -p /user/hive/user_profile/ods
hdfs dfs -rm -r /user/hive/user_profile/ods
hdfs dfs -mkdir -p /user/hive/user_profile/ods
hdfs dfs -put ~/data/UserBehavior_10000.csv /user/hive/user_profile/ods/
hdfs dfs -ls /user/hive/user_profile/ods
第二步：执行 Hive SQL
进入 Hive 后执行：

hive
然后运行 sql/user_profile.sql 中的建表和数据处理语句。

也可以将 SQL 文件内容复制到 Hive 中逐步执行。

第三步：导出 Hive 查询结果
执行 sql/export_result.sql 中的导出语句，将统计结果保存到本地目录。

第四步：合并用户画像结果
运行 Python 合并脚本：

python3 python/merge_user_profile.py
合并结果将导出为：

/home/hadoop/result/user_profile_merged.csv
第五步：生成可视化图表
运行 Python 可视化脚本：

python3 python/draw_user_profile.py
图表将保存到：

/home/hadoop/charts/
输出结果
运行完成后，项目将生成以下结果：

1. 合并后的用户画像结果
/home/hadoop/result/user_profile_merged.csv
2. 可视化图表
/home/hadoop/charts/
包含图表例如：

用户行为类型分布图
用户活跃等级分布图
用户消费等级分布图
用户购买意向分布图
用户价值等级分布图
商品偏好类别 Top10 图
报告说明
本项目对应课程设计报告题目：

基于Hive数据仓库的电商用户画像系统的设计与实现

报告内容包括：

实验环境
数据集介绍
数据预处理
数据存储结构与格式
编程实现
在分布式系统中运行程序
数据查询
数据可视化
实验结果与分析
总结与展望
注意事项
本项目仅用于课程设计展示和学习交流。
原始数据集较大，仓库中不建议提交完整数据文件。
Hive 本地模式适合小规模实验数据，如果数据量过大，建议调整执行参数或使用更高配置环境。
如果图表中文显示异常，请确认系统已安装中文字体，例如 wqy-microhei-fonts。
