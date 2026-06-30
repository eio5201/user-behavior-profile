这个脚本用于读取 Hive 导出的结果并生成 PNG 图表。
import os
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


BASE_DIR = '/home/hadoop/result'
OUTPUT_DIR = '/home/hadoop/charts'

plt.rcParams['font.sans-serif'] = [
    'WenQuanYi Micro Hei',
    'SimHei',
    'Microsoft YaHei',
    'Noto Sans CJK SC',
    'DejaVu Sans'
]
plt.rcParams['axes.unicode_minus'] = False


def find_result_file(directory):
    if not os.path.exists(directory):
        raise FileNotFoundError(f'目录不存在: {directory}')

    candidates = []
    for name in os.listdir(directory):
        path = os.path.join(directory, name)
        if os.path.isfile(path) and not name.startswith('.') and not name.startswith('_'):
            candidates.append(path)

    if not candidates:
        raise FileNotFoundError(f'目录中没有数据文件: {directory}')

    candidates.sort()
    return candidates[0]


def read_hive_result(relative_path):
    file_path = find_result_file(os.path.join(BASE_DIR, relative_path))
    labels = []
    values = []

    with open(file_path, 'r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if not line:
                continue

            parts = line.split(',')
            if len(parts) < 2:
                continue

            label = parts[0].strip()
            value_text = parts[1].strip()

            try:
                value = int(value_text)
            except ValueError:
                continue

            labels.append(label)
            values.append(value)

    return labels, values


def draw_bar(labels, values, title, xlabel, ylabel, output_name, color='#4C78A8'):
    if not labels:
        print('跳过空数据图表:', title)
        return

    plt.figure(figsize=(10, 6))
    bars = plt.bar(labels, values, color=color)

    plt.title(title, fontsize=16)
    plt.xlabel(xlabel, fontsize=12)
    plt.ylabel(ylabel, fontsize=12)
    plt.xticks(rotation=25)

    for bar in bars:
        height = bar.get_height()
        plt.text(
            bar.get_x() + bar.get_width() / 2,
            height,
            str(int(height)),
            ha='center',
            va='bottom',
            fontsize=10
        )

    plt.tight_layout()
    output_path = os.path.join(OUTPUT_DIR, output_name)
    plt.savefig(output_path, dpi=300)
    plt.close()
    print(f'已生成: {output_path}')


def draw_pie(labels, values, title, output_name):
    if not labels:
        print('跳过空数据图表:', title)
        return

    plt.figure(figsize=(8, 8))
    plt.pie(values, labels=labels, autopct='%1.1f%%', startangle=90, counterclock=False)
    plt.title(title, fontsize=16)
    plt.tight_layout()

    output_path = os.path.join(OUTPUT_DIR, output_name)
    plt.savefig(output_path, dpi=300)
    plt.close()
    print(f'已生成: {output_path}')


def draw_horizontal_bar(labels, values, title, xlabel, ylabel, output_name, color='#59A14F'):
    if not labels:
        print('跳过空数据图表:', title)
        return

    pairs = list(zip(labels, values))
    pairs.sort(key=lambda x: x[1])

    sorted_labels = [x[0] for x in pairs]
    sorted_values = [x[1] for x in pairs]

    plt.figure(figsize=(10, 7))
    bars = plt.barh(sorted_labels, sorted_values, color=color)

    plt.title(title, fontsize=16)
    plt.xlabel(xlabel, fontsize=12)
    plt.ylabel(ylabel, fontsize=12)

    for bar in bars:
        width = bar.get_width()
        plt.text(
            width,
            bar.get_y() + bar.get_height() / 2,
            str(int(width)),
            ha='left',
            va='center',
            fontsize=10
        )

    plt.tight_layout()
    output_path = os.path.join(OUTPUT_DIR, output_name)
    plt.savefig(output_path, dpi=300)
    plt.close()
    print(f'已生成: {output_path}')


def main():
    if not os.path.exists(OUTPUT_DIR):
        os.makedirs(OUTPUT_DIR)

    tasks = [
        ('behavior_type', 'bar', '用户行为类型分布', '行为类型', '行为次数', 'behavior_type_distribution.png'),
        ('active_level', 'pie', '用户活跃等级分布', '', '', 'active_level_distribution.png'),
        ('consume_level', 'pie', '用户消费等级分布', '', '', 'consume_level_distribution.png'),
        ('purchase_intention', 'bar', '用户购买意向分布', '购买意向', '用户数量', 'purchase_intention_distribution.png'),
        ('user_value', 'bar', '用户价值等级分布', '用户价值等级', '用户数量', 'user_value_distribution.png'),
        ('category_top10', 'horizontal_bar', '商品偏好类别 Top10', '用户数量', '商品类别', 'category_top10.png')
    ]

    for rel_path, chart_type, title, xlabel, ylabel, output_name in tasks:
        labels, values = read_hive_result(rel_path)
        if chart_type == 'bar':
            draw_bar(labels, values, title, xlabel, ylabel, output_name)
        elif chart_type == 'pie':
            draw_pie(labels, values, title, output_name)
        elif chart_type == 'horizontal_bar':
            draw_horizontal_bar(labels, values, title, xlabel, ylabel, output_name)

    print(f'全部图表生成完成，输出目录: {OUTPUT_DIR}')


if __name__ == '__main__':
    main()
