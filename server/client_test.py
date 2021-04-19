import time
import json
import requests
import numpy as np
import pandas as pd

client_id = b'}\r\x83\x00'  # machine.unique_id()
client_id = '{:02x}{:02x}{:02x}{:02x}'.format(client_id[0], client_id[1], client_id[2], client_id[3])

url_label_rfid = 'http://127.0.0.1:8080/label_rfid'

rfid_data = {'Client-Id' : client_id,
        'RFID-Id' : '1', 
        'Ingredient-Id' : '19335'}

def label_new_rfid():
    time_start = time.time()
    response = requests.post(url_label_rfid, json=json.dumps(rfid_data))
    if response.status_code == 200 and response.content == b'OK':
        print('>> [OK] Finished in ' + str(time.time() - time_start) + ' sec')
    else:
        print(f'>> [ERR] Code={response.status_code}, Message={response.content.decode()}')

if __name__ == '__main__':
    label_new_rfid()
