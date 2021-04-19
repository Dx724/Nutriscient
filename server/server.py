import json
import traceback
from flask import Flask, make_response, request

from util import get_ingredient_nutrition, RFID_Database, Nutrition_Database

app = Flask(__name__)
rfid_db = RFID_Database()
nutrition_db = Nutrition_Database()

@app.route('/')
def hello_world():
    return make_response('AWS Backend is live!')


@app.route('/debug')
def enter_debug_mode():
    try:
        import pdb
        pdb.set_trace()
    except:
        pass
    return make_response('Debug session ended')


@app.route('/add_data', methods=['POST'])
def add_data():
    try:
        header = request.headers
        if all([i in header.keys() for i in ['Client-Id', 'Weight', 'RFID-Id']]):
            esp_id, weight, rfid = header['Client-Id'], header['Weight'], header['RFID-Id']
            # TODO: Add to database
            raise NotImplementedError
        else:
            return make_response('Invalid request', 400)
    except:
        msg = traceback.format_exc()
        print(f'Server error: {msg}')
        return make_response(f'Server error: {msg}', 500)


@app.route('/label_rfid', methods=['POST'])
def label_rfid():
    """ Add record in database to correspond RFID with actual food item """
    params = json.loads(request.json)
    print(params.keys())
    if all([i in params.keys() for i in ['Client-Id', 'RFID-Id', 'Ingredient-Id']]):
        esp_id, rfid, ingredient_id = params['Client-Id'], params['RFID-Id'], params['Ingredient-Id']

        print("getting nutrition info")
        nutrition = get_ingredient_nutrition(ingredient_id)
        if nutrition is not None:
            ingredient_name, ingredient_nutrition = nutrition
            # TODO: Add to database
            # db_name[esp_id][rfid] = ingredient_name
            # db_nutrition[esp_id][rfid] = ingredient_nutrition
            #raise NotImplementedError
            rfid_db.insert(esp_id, rfid, ingredient_name)

            return make_response('OK')
        else:
            return make_response(f'Error finding nutrition info for id={ingredient_id}', 500)
    else:
        return make_response('Invalid request', 400)


@app.route('/visualize', methods=['GET'])
def get_visualization_data_all():
    params = request.values
    if 'Client-Id' in params.keys():
        esp_id = params['Client-Id']
        # TODO: Query database, format output data, return
        raise NotImplementedError
    else:
        return make_response('Invalid request', 400)


@app.route('/visualize_ingredient', methods=['GET'])
def get_visualization_data_one_ingredient():
    params = request.values
    if all([i in params.keys() for i in ['Client-Id', 'RFID-Id']]):
        esp_id, rfid = params['Client-Id'], params['RFID-Id']
        # TODO: Query database, format output data, return
        raise NotImplementedError
    else:
        return make_response('Invalid request', 400)


@app.route('/get_all_ingredient', methods=['GET'])
def get_all_ingredient_weight():
    params = request.values
    if 'Client-Id' in params.keys():
        esp_id = params['Client-Id']
        # TODO: Query database, format output data, return
        raise NotImplementedError
    else:
        return make_response('Invalid request', 400)


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
