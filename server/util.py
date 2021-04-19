import requests
from cred import spoonacular_api_key
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
                'ingredient_name' : ingredient_name}
        print(post)
        post_id = collection.insert_one(post).inserted_id
        print(f'Insert ID: {post_id}')

class Nutrition_Database:
    def __init__(self):
        client = MongoClient('localhost', 27017)
        self.db = client['Nutriscient_nutrition']


def get_ingredient_nutrition(ingredient_id=1):
    # 1: Mobile App to search for ingredient, ask user to pick and get its spoonacular ID, pass into here
    # https://spoonacular.com/food-api/docs#Ingredient-Search
    # Step 2: Call API with the ingredient_id, 1 gram, get and parse a list of nutrition
    # https://spoonacular.com/food-api/docs#Get-Ingredient-Information
    url = 'https://api.spoonacular.com/food/ingredients/{ingredient_id}/information?' \
          'amount=1000&unit=grams&apiKey={api_key}'.format(ingredient_id=ingredient_id, api_key=spoonacular_api_key)

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
