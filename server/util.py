import requests
import time
import json
# from cred import spoonacular_api_key
from nutrition_dv import dv

from pymongo import MongoClient
from bson.json_util import dumps, loads


class RFID_Database:
    def __init__(self):
        client = MongoClient('localhost', 27017)
        self.db = client['Nutriscient_RFID']

    def insert(self, esp_id, rfid, ingredient_name):
        col_name = 'ESP' + esp_id
        collection = self.db[col_name]
        post = {'rfid' : rfid,
                'ingredient_name' : ingredient_name,
                'time' : time.time()}
        if collection.count_documents({'rfid' : rfid, 'ingredient_name' : ''}) != 0:
            """ Completing registration for {rfid} """
            collection.replace_one({'rfid' : rfid, 'ingredient_name' : ''}, post)
        elif collection.count_documents({'rfid' : rfid}) == 0:
            """ new RFID """
            collection.insert_one(post)
        elif collection.count_documents({'rfid' : rfid, 'ingredient_name' : {'$ne': ingredient_name}}):
            """ reused RFID """
            collection.replace_one({'rfid' : rfid, 'ingredient_name' : ingredient_name}, post)

    def insert_incomplete(self, esp_id, rfid):
        col_name = 'ESP' + esp_id
        collection = self.db[col_name]
        post = {'rfid' : rfid,
                'ingredient_name' : '',
                'time' : time.time()}
        if collection.count_documents({'rfid' : rfid}) == 0:
            collection.insert_one(post)

    def find_unregistered(self, esp_id):
        col_name = 'ESP' + esp_id
        collection = self.db[col_name]
        if collection.count_documents({}) == 0:
            collection_not_found = 'invalid ESP'
            return collection_not_found
        """ return most recent RFID that isn't registered with an ingredient """
        post_cursor = collection.find({'ingredient_name' : ''}).sort('_id', -1).limit(1)
        if post_cursor.count() == 0:
            all_registered = 'all registered'
            return all_registered
        post = post_cursor[0]
        del post['_id']
        del post['ingredient_name']
        return post


class Nutritions_Database:
    def __init__(self):
        client = MongoClient('localhost', 27017)
        self.db = client['Nutriscient_nutritions']

    def insert(self, esp_id, rfid, name, nutrition):
        col_name = 'ESP' + esp_id
        collection = self.db[col_name]
        post = {'rfid' : rfid,
                'name' : name,
                'nutrition' : nutrition}
        if collection.find({'rfid' : rfid}).count() == 0:
            """ new ingredient """
            collection.insert_one(post)
        elif collection.count_documents({'rfid' : rfid, 'name' : {'$ne': name}}):
            """ reused RFID """
            collection.replace_one({'rfid' : rfid, 'name' : name}, post)


class Weight_Database:
    def __init__(self):
        client = MongoClient('localhost', 27017)
        self.db = client['Nutriscient_weight']

    def insert(self, esp_id, rfid, weight):
        col_name = 'ESP' + esp_id
        collection = self.db[col_name]
        post = {'rfid' : rfid,
                'weight' : weight,
                'time' : time.time()}
        collection.insert_one(post)


def get_ingredient_nutrition(ingredient_id=1):
    # 1: Mobile App to search for ingredient, ask user to pick and get its spoonacular ID, pass into here
    # https://spoonacular.com/food-api/docs#Ingredient-Search
    # Step 2: Call API with the ingredient_id, 1 gram, get and parse a list of nutrition
    # https://spoonacular.com/food-api/docs#Get-Ingredient-Information
    url = 'https://api.spoonacular.com/food/ingredients/{ingredient_id}/information?' \
          'amount=1000&unit=grams&apiKey={api_key}'.format(ingredient_id=ingredient_id, api_key='262810135e8249fdaceee2c396c7f0ec')

    response = requests.get(url)
    if response.status_code != 200:
        print(f'Error HTTP {response.status_code}')
        print(response.content.decode())
        return None

    data = response.json()
    name = data['name']
    data = data['nutrition']['nutrients']
    data = {
        i['name'] + '_' + i['unit']: i['amount'] for i in data if i['amount'] != 0
    }
    data_cleaned = dict()
    for k, v in data.items():
        if k.lower() not in [i.lower() for i in dv.keys()]:
            print(f'Not found: {k}: {v}')
        else:
            data_cleaned[k] = v
    return name, data_cleaned


if __name__ == '__main__':
    # print(get_ingredient_nutrition(9266))
    print(get_ingredient_nutrition(19335))  # Sugar
