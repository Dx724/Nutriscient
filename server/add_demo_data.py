import pandas as pd
import random
from tqdm import tqdm

from client_test import add_new_weight, label_new_rfid

demo_esp_id = '2f6f1400'
# demo_rfid = '67fec893c2'

df = pd.read_csv('demo_data.csv').rename({
    'Weight Difference (kg)': 'actual',
    'Refill to Weight (kg)': 'refill',
    'Do-Track': 'track'}, axis=1)

result_list = dict()
last_weight = dict()
do_track = dict()

for index, row in df.iterrows():
    time = row['time'] + random.random() - 0.5
    rfid = str(row['ID'])
    weight_diff = row['actual']

    if rfid not in do_track.keys():
        do_track[rfid] = row['track']
    if row['refill'] != '-':
        refill_to = float(row['refill'])
        refill_time = time - (random.random() / 10)
        last_weight[rfid] = refill_to

        result_list[refill_time] = (rfid, refill_to)

    last_weight[rfid] -= row['actual']
    result_list[time] = (rfid, last_weight[rfid])

if __name__ == '__main__':
    for k, v in tqdm(result_list.items()):
        time = k
        rfid, weight = v
        packet = {'Client-Id': demo_esp_id,
                  'RFID-Id': rfid,
                  'Weight': weight}
        add_new_weight(packet)

    for rfid, do_track in tqdm(do_track.items()):
        packet = {'Client-Id': demo_esp_id,
                  'RFID-Id': rfid,
                  'Ingredient-Id': int(rfid),
                  'Do-Track': do_track
                  }
