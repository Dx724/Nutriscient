import json
import traceback
from flask import Flask, make_response, request

from util import get_ingredient_nutrition, RFID_Database, Nutritions_Database, Weight_Database

app = Flask(__name__)
rfid_db = RFID_Database()
nutritions_db = Nutritions_Database()
weight_db = Weight_Database()

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


@app.route('/add_weight', methods=['POST'])
def add_data():
    try:
        params = request.values
        if all([i in params.keys() for i in ['Client-Id', 'RFID-Id', 'Weight']]):
            esp_id, rfid, weight = params['Client-Id'], params['RFID-Id'], params['Weight']
            weight_db.insert(esp_id, rfid, weight)
            return make_response('OK')
        else:
            return make_response('Invalid request', 400)
    except:
        msg = traceback.format_exc()
        print(f'Server error: {msg}')
        return make_response(f'Server error: {msg}', 500)


@app.route('/return_unregistered_rfid', methods=['GET'])
def return_unregistered_rfid():
    """ Push notification for user to complete registering RFID """
    params = request.values
    if 'Client-Id' in params.keys():
        esp_id = params['Client-Id']
        response = rfid_db.find_unregistered(esp_id)
        if response is None:
            response = {"exist": False}
        else:
            response["exist"] = True
        response = json.dumps(response)
        return make_response(response, 200)
    else: 
        msg = traceback.format_exc()
        print(f'Server error: {msg}')
        return make_response(f'Server error: {msg}', 500)


@app.route('/label_rfid', methods=['POST'])
def label_rfid():
    """ Add record in database to correspond RFID with actual food item """
    params = request.values
    if all([i in params.keys() for i in ['Client-Id', 'RFID-Id', 'Ingredient-Id']]):
        esp_id, rfid, ingredient_id = params['Client-Id'], params['RFID-Id'], params['Ingredient-Id']
        print(esp_id, rfid, ingredient_id)
        nutrition = get_ingredient_nutrition(ingredient_id)
        if nutrition is not None:
            ingredient_name, ingredient_nutrition = nutrition
            rfid_db.insert(esp_id, rfid, ingredient_name)
            nutritions_db.insert(esp_id, rfid, ingredient_name, ingredient_nutrition)
            return make_response(json.dumps({'ok': True}))
        else:
            response = {
                'ok': False,
                'msg': f'Error finding nutrition info for id={ingredient_id}'
            }
            return make_response(json.dumps(response), 500)
    elif all([i in params.keys() for i in ['Client-Id', 'RFID-Id']]):
        """ Registration was incomplete """
        esp_id, rfid = params['Client-Id'], params['RFID-Id']
        rfid_db.insert_incomplete(esp_id, rfid)
        return make_response(json.dumps({'ok': True}))
    else:
        response = {
            'ok': False,
            'msg': f'Expected parameters: Client-Id, RFID-Id, Ingredient-Id'
        }
        return make_response(json.dumps(response), 400)


@app.route('/visualize', methods=['GET'])
def get_visualization_data_all():
    params = json.loads(request.json)
    if 'Client-Id' in params.keys():
        esp_id = params['Client-Id']
        # TODO: Query database, format output data, return
        fake_data = [{'Fiber_g' : {{'rfid' : 1, 'nutrient' : 1}, {'rfid' : 2, 'nutrient' : 10}}}, 
                {'Sugar_g': {{'rfid' : 1, 'nutrient' : 10}, {'rfid' : 2, 'nutrient' : 20}}}]
        json_data = json.dumps(fake_data)
        return make_response(json_data, 200)
    else:
        return make_response('Invalid request', 400)


@app.route('/visualize_ingredient', methods=['GET'])
def get_visualization_data_one_ingredient():
    params = json.loads(request.json)
    if all([i in params.keys() for i in ['Client-Id', 'RFID-Id']]):
        esp_id, rfid = params['Client-Id'], params['RFID-Id']
        # TODO: Query database, format output data, return
        fake_data = [{'rfid' : 1, 'used' : 0.01, 'time' : 1618948800}, 
                {'rfid' : 1, 'used' : 0.01, 'time' : 1618902000}, 
                {'rfid' : 1, 'used' : 0.02, 'time' : 1618862400}] 
        json_data = json.dumps(fake_data)
        return make_response(json_data, 200)
    else:
        return make_response('Invalid request', 400)


@app.route('/get_all_ingredient', methods=['GET'])
def get_all_ingredient_weight():
    params = json.loads(request.json)
    if 'Client-Id' in params.keys():
        esp_id = params['Client-Id']
        # TODO: Query database, format output data, return
        fake_data = [{'rfid' : 1, 'recent_weight' : 90, 'last_refill' : 100},
                {'rfid' : 2, 'recent_weight' : 800, 'last_refill' : 1000}]
        json_data = json.dumps(fake_data)
        return make_response(json_data, 200)
    else:
        return make_response('Invalid request', 400)


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
