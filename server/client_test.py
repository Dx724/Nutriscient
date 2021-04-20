import time
import json
import requests
import numpy as np
import pandas as pd

client_id = b'}\r\x83\x00'  # machine.unique_id()
client_id = '{:02x}{:02x}{:02x}{:02x}'.format(client_id[0], client_id[1], client_id[2], client_id[3])

url_label_rfid = 'http://127.0.0.1:8000/label_rfid'
url_get_unregistered = 'http://127.0.0.1:8000/return_unregistered_rfid'
url_add_weight = 'http://127.0.0.1:8000/add_weight'

rfid_sugar = {'Client-Id' : client_id,
        'RFID-Id' : '1', 
        'Ingredient-Id' : '19335'}

rfid_sugar_incomplete = {'Client-Id' : client_id,
        'RFID-Id' : '1'}

rfid_pineapple = {'Client-Id' : client_id,
        'RFID-Id' : '2',
        'Ingredient-Id' : '9266'}

rfid_pineapple_incomplete = {'Client-Id' : client_id,
        'RFID-Id' : '2'}

weight_sugar_filled = {'Client-Id' : client_id,
        'RFID-Id' : '1',
        'Weight' : '0.1'}

weight_sugar_used_1g = {'Client-Id' : client_id,
        'RFID-Id' : '1',
        'Weight' : '0.099'}

weight_pineapple_filled = {'Client-Id' : client_id,
        'RFID-Id' : '2',
        'Weight' : '0.5'}

weight_pineapple_used_100g = {'Client-Id' : client_id,
        'RFID-Id' : '2',
        'Weight' : '0.4'}

def label_new_rfid(rfid_data):
    time_start = time.time()
    response = requests.post(url_label_rfid, json=json.dumps(rfid_data))
    if response.status_code == 200 and response.content == b'OK':
        print('>> [OK] Finished in ' + str(time.time() - time_start) + ' sec')
    else:
        print(f'>> [ERR] Code={response.status_code}, Message={response.content.decode()}')

def get_unregistered_rfid():
    time_start = time.time()
    headers = {'Client-Id' : client_id}
    response = requests.get(url_get_unregistered, headers=headers)
    if response.status_code == 200:
        print('>> [OK] Finished in ' + str(time.time() - time_start) + ' sec')
    else:
        print(f'>> [ERR] Code={response.status_code}, Message={response.content.decode()}')

def add_new_weight(weight_data):
    time_start = time.time()
    response = requests.post(url_add_weight, json=json.dumps(weight_data))
    if response.status_code == 200 and response.content == b'OK':
        print('>> [OK] Finished in ' + str(time.time() - time_start) + ' sec')
    else:
        print(f'>> [ERR] Code={response.status_code}, Message={response.content.decode()}')

if __name__ == '__main__':
    
    print('testing RFID registration...')
    label_new_rfid(rfid_sugar_incomplete)
    label_new_rfid(rfid_pineapple_incomplete)
    get_unregistered_rfid()
    label_new_rfid(rfid_pineapple)
    label_new_rfid(rfid_sugar)
    
    """
    label_new_rfid(rfid_pineapple)
    label_new_rfid(rfid_sugar)
    
    print('\ntesting weight insertion...')
    add_new_weight(weight_sugar_filled)
    add_new_weight(weight_sugar_used_1g)
    add_new_weight(weight_pineapple_filled)
    add_new_weight(weight_pineapple_used_100g)
    """
