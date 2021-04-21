import json
import traceback
import time
import datetime
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
            if rfid_db.is_new_rfid(esp_id, rfid):
                pass
                # TODO: Fire push notification
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
    else:
        response = {
            'ok': False,
            'msg': f'Expected parameters: Client-Id, RFID-Id, Ingredient-Id'
        }
        return make_response(json.dumps(response), 400)


@app.route('/visualize', methods=['GET'])
def get_visualization_data_all():
    params = request.values
    if 'Client-Id' in params.keys():
        esp_id = params['Client-Id']
        # TODO: Handle timezone
        '''
        Step 1: Find all entries in Weight_Database in the range [time.time() - one week   ...   time.time()] '''
        current_time_epoch = time.time()
        current_time_readable = datetime.datetime.fromtimestamp(current_time_epoch)
        from_time_readable = current_time_readable - datetime.timedelta(days=7)
        from_time_epoch = from_time_readable.timestamp()

        weight_col = weight_db.db['ESP' + esp_id]
        weight_all_cursor = weight_col.find({'time': {'$lte': current_time_epoch, '$gte': from_time_epoch}})
        weight_all_list = list(weight_all_cursor)

        unique_rfids = weight_all_cursor.distinct('rfid')
        res = []
        """ contains all the weights from the past week, grouped by rfid """
        for rfid in unique_rfids:
            weight_rfid_cursor = weight_all_cursor.collection.find({'rfid': rfid})
            weight_rfid_cursor = weight_rfid_cursor.sort('_id', 1)
            """ earliest first """
            weight_rfid_list = list(weight_rfid_cursor)
            res_rfid = []
            for weight_rfid_entry in weight_rfid_list:
                weight_rfid = {'weight': weight_rfid_entry['weight'],
                               'time': weight_rfid_entry['time']}
                res_rfid.append(weight_rfid)
            weight_rfid_grouped = {'rfid': rfid,
                                   'weights': res_rfid}
            res.append(weight_rfid_grouped)
        # print(res)

        '''
        Step 2: Clean those entries -- take diff on weight, and detect and drop the refills entry
        Step 3: Get a set of RFIDs, look up Nutritions_Database (if RFID not registered, drop),
                get their name, and net nutrition for RFID records from last step
                reshape into: (note the 'time' entry)
                {
                'name1': [{'time': xxx, 'calories_kcal': 300, 'Sugar_g': 10}, {'time': xxx, 'calories_kcal': 150, 'Sugar_g': 5}],
                'name2': [{'time': xxx, 'Chromium_µg': 5.1, 'Sugar_g': 10}, {'time': xxx, 'Chromium_µg': 2.45, 'Sugar_g': 5}]
                }
        '''
        nutritions_col = nutritions_db.db['ESP' + esp_id]
        nutritions_list = list(nutritions_col.find())
        res = {}
        """ name and nutritions of all RFIDs """
        for nutritions in nutritions_list:
            rfid = nutritions['rfid']
            nutritions_entry = (nutritions['name'], nutritions['nutrition'])
            res[rfid] = nutritions_entry
        # print(res)

        '''
        Step 4: Find all nutrients, reshape and put into pd dataframe
                df_calories_kcal: [{'time': xxx, 'name': xxx, 'amount' xxx}, ...]
                df_sugar: [{'time': xxx, 'name': xxx, 'amount' xxx}, ...]
        Step 5: For each df_<nutrition_name>, for 1) whole week / whole dataframe,  2) grouped into each day
                    calculate sum(amount) and groupby(name).sum
        Step 6: Form result
                calories --- Weekly ----
                          |            | --- beef -- as below 
                          |            | --- butter
                          |            | --- ... 
                          |
                          |
                          |-- Monday --| --- beef -- as below 
                          |            | --- butter
                          |            | --- ... 
                          | 
                          |-- Tuesday --
                          | 
                          | 
                          |- ...

                Repeat for other nutritions

                {
                    'total': 10000,
                    'beef': 4000,
                    'butter': 1500,
                    'milk': 400,
                    'salt': 100,
                    'oil': 3000,
                    'chicken': 1000,
                    'dv': dv['<nutrition name>']
                }

                result = 
                {
                    'ok': True,
                    'date_order': ['Tuesday', 'Wednesday', ..., 'Monday'],
                    'data': <as above>
                }
        '''
        return make_response(json.dumps({'ok': False, 'message': 'Not Implemented'}), 500)
        # return make_response(json_data, 200)
    else:
        return make_response('Invalid request', 400)


"""
@app.route('/visualize_ingredient', methods=['GET'])
def get_visualization_data_one_ingredient():
    params = request.values
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
"""


@app.route('/get_all_ingredient', methods=['GET'])
def get_all_ingredient_weight():
    params = request.values
    if 'Client-Id' in params.keys():
        esp_id = params['Client-Id']
        fake_data = [{'rfid': 1, 'recent_weight': 90, 'last_refill': 100},
                     {'rfid': 2, 'recent_weight': 800, 'last_refill': 1000}]
        json_data = json.dumps(fake_data)
        return make_response(json_data, 200)
    else:
        return make_response('Invalid request', 400)


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
