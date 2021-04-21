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
url_get_all_ingredient = 'http://127.0.0.1:8000/get_all_ingredient'

rfid_sugar = {'Client-Id': client_id,
              'RFID-Id': '1',
              'Ingredient-Id': '19335',
              'Do-Track': True}

rfid_pineapple = {'Client-Id': client_id,
                  'RFID-Id': '2',
                  'Ingredient-Id': '9266',
                  'Do-Track': False}

weight_sugar_filled = {'Client-Id': client_id,
                       'RFID-Id': '1',
                       'Weight': '0.1'}

weight_sugar_used_1g = {'Client-Id': client_id,
                        'RFID-Id': '1',
                        'Weight': '0.099'}

weight_pineapple_filled = {'Client-Id': client_id,
                           'RFID-Id': '2',
                           'Weight': '0.5'}

weight_pineapple_used_100g = {'Client-Id': client_id,
                              'RFID-Id': '2',
                              'Weight': '0.4'}


def label_new_rfid(rfid_data):
    time_start = time.time()
    response = requests.post(url_label_rfid, params=rfid_data)
    if response.status_code == 200:
        print('>> [OK] Finished in ' + str(time.time() - time_start) + ' sec')
        print('\t\t--> ' + repr(response.json()))
    else:
        print(f'>> [ERR] Code={response.status_code}, Message={response.content.decode()}')


def get_unregistered_rfid(esp_id):
    time_start = time.time()
    params = {'Client-Id': esp_id}
    response = requests.get(url_get_unregistered, params=params)
    if response.status_code == 200:
        print('>> [OK] Finished in ' + str(time.time() - time_start) + ' sec')
        print('\t\t--> ' + repr(response.json()))
    else:
        print(f'>> [ERR] Code={response.status_code}, Message={response.content.decode()}')


def add_new_weight(weight_data):
    time_start = time.time()
    response = requests.post(url_add_weight, params=weight_data)
    if response.status_code == 200 and response.content == b'OK':
        print('>> [OK] Finished in ' + str(time.time() - time_start) + ' sec')
    else:
        print(f'>> [ERR] Code={response.status_code}, Message={response.content.decode()}')


def get_all_ingredient(esp_id):
    time_start = time.time()
    params = {'Client-Id': esp_id}
    response = requests.get(url_get_all_ingredient, params=params)
    if response.status_code == 200:
        print('>> [OK] Finished in ' + str(time.time() - time_start) + ' sec')
        print('\t\t--> ' + repr(response.json()))
    else:
        print(f'>> [ERR] Code={response.status_code}, Message={response.content.decode()}')


if __name__ == '__main__':
    print('\n---------------------\n[ESP] Get all ingredients')
    get_all_ingredient(client_id)

    print('\n---------------------\n[ESP] Add weight')
    add_new_weight(weight_sugar_filled)
    add_new_weight(weight_sugar_used_1g)
    add_new_weight(weight_pineapple_filled)
    add_new_weight(weight_pineapple_used_100g)

    print('\n---------------------\n[APP] Get unregistered RFIDs')
    get_unregistered_rfid(client_id)
    print('Expected: Should give 1')

    print('\n---------------------\n[APP] Label RFID')
    label_new_rfid(rfid_sugar)

    print('\n---------------------\n[APP] Get unregistered RFIDs')
    get_unregistered_rfid(client_id)
    print('Expected: Should give 2')

    print('\n---------------------\n[APP] Label RFID')
    label_new_rfid(rfid_sugar)

    print('\n---------------------\n[APP] Get unregistered RFIDs')
    get_unregistered_rfid(client_id)
    print('Expected: Should not have empty RFIDs')

    print('\n---------------------\n[APP] Get unregistered RFIDs')
    get_unregistered_rfid(client_id)
    print('Expected: Should not have empty RFIDs')

    print('\n---------------------\n[ESP] Get all ingredients')
    get_all_ingredient(client_id)