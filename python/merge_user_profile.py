这个脚本用于把 ads_user_profile 和 dws_user_preference_category 两份导出结果按 user_id 合并，生成最终 CSV。
import os
import csv

ADS_DIR = '/home/hadoop/result/ads_user_profile'
PREF_DIR = '/home/hadoop/result/dws_user_preference_category'
OUTPUT_CSV = '/home/hadoop/result/user_profile_merged.csv'


def find_result_file(directory):
    if not os.path.exists(directory):
        raise FileNotFoundError(f'目录不存在: {directory}')

    for name in os.listdir(directory):
        path = os.path.join(directory, name)
        if os.path.isfile(path) and not name.startswith('.') and not name.startswith('_'):
            return path

    raise FileNotFoundError(f'目录中没有可读取的数据文件: {directory}')


def read_ads_profile():
    file_path = find_result_file(ADS_DIR)
    data = {}

    with open(file_path, 'r', encoding='utf-8') as f:
        reader = csv.reader(f)
        for row in reader:
            if not row or len(row) < 6:
                continue

            user_id = row[0].strip()
            data[user_id] = {
                'user_id': user_id,
                'active_level': row[1].strip(),
                'consume_level': row[2].strip(),
                'purchase_intention': row[3].strip(),
                'user_value_level': row[4].strip(),
                'profile_update_time': row[5].strip()
            }

    return data


def read_preference_category():
    file_path = find_result_file(PREF_DIR)
    data = {}

    with open(file_path, 'r', encoding='utf-8') as f:
        reader = csv.reader(f)
        for row in reader:
            if not row or len(row) < 2:
                continue

            user_id = row[0].strip()
            preference_category = row[1].strip()
            data[user_id] = preference_category

    return data


def merge_and_export():
    ads_data = read_ads_profile()
    pref_data = read_preference_category()

    output_dir = os.path.dirname(OUTPUT_CSV)
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    with open(OUTPUT_CSV, 'w', encoding='utf-8', newline='') as f:
        writer = csv.writer(f)
        writer.writerow([
            'user_id',
            'active_level',
            'consume_level',
            'purchase_intention',
            'user_value_level',
            'preference_category',
            'profile_update_time'
        ])

        for user_id, profile in ads_data.items():
            writer.writerow([
                profile['user_id'],
                profile['active_level'],
                profile['consume_level'],
                profile['purchase_intention'],
                profile['user_value_level'],
                pref_data.get(user_id, ''),
                profile['profile_update_time']
            ])

    print(f'合并完成，输出文件: {OUTPUT_CSV}')
    print(f'共合并用户数: {len(ads_data)}')


if __name__ == '__main__':
    merge_and_export()
