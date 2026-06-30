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
