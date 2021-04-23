import json
import traceback
import time
import pytz
from datetime import datetime
import numpy as np
import pandas as pd
from flask import Flask, make_response, request

from util import get_ingredient_nutrition, RFID_Database, Nutritions_Database, Weight_Database
from fcm import push_notification

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
            if 'Time-Stamp' in params.keys():
                epoch = float(params['Time-Stamp'])
            else:
                epoch = None
            weight_db.insert(esp_id, rfid, float(weight), epoch)
            if rfid_db.is_new_rfid(esp_id, rfid):
                if 'No-Notif' not in params.keys() or not params['No-Notif']:
                    print(f'New item: {rfid}. Pushing notification')
                    push_notification(
                        title='Register New Item', 
                        body=f'Tell us what is {float(weight):.2f}kg!',
                        field_a=weight,
                        topic=esp_id
                        )
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
        return make_response(f'Expected parameter: Client-Id!', 400)


@app.route('/label_rfid', methods=['POST'])
def label_rfid():
    """ Add record in database to correspond RFID with actual food item """
    params = request.values
    if all([i in params.keys() for i in ['Client-Id', 'RFID-Id', 'Ingredient-Id', 'Do-Track']]):
        esp_id, rfid, ingredient_id, do_track = params['Client-Id'], params['RFID-Id'], params['Ingredient-Id'], params['Do-Track']
        nutrition = get_ingredient_nutrition(ingredient_id)
        if nutrition is not None:
            ingredient_name, ingredient_nutrition = nutrition
            rfid_db.insert(esp_id, rfid, ingredient_name, do_track)
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
        Step 1: Find all entries in Weight_Database in the range
        [time.time() - one week   ...   time.time()]
        Sorted by timestamp
        '''
        current_time_epoch = time.time()
        from_time_epoch = time.time() - (86400 * 7)

        weight_col = weight_db.db['ESP' + esp_id]
        weight_all_cursor = weight_col.find({'time': {'$lte': current_time_epoch, '$gte': from_time_epoch}})
        weight_all_list = list(weight_all_cursor)

        unique_rfids = weight_all_cursor.distinct('rfid')
        data = []
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
            data.append(weight_rfid_grouped)
        '''
        Step 2: Clean those entries -- take diff on weight, and detect and 
        drop the refills entry
        '''
        data_cleaned = dict()
        for entry in data:
            weight_list = np.array([float(i['weight']) for i in entry['weights']])
            time_list = np.array([float(i['time']) for i in entry['weights']])
            actual_weight = -np.diff(weight_list)
            non_refill_idx = np.where(actual_weight > 0)[0]
            
            cleaned_weights = actual_weight[non_refill_idx]
            cleaned_times = time_list[non_refill_idx+1]      # +1 because diff
            if len(cleaned_weights) != 0:
                data_cleaned[entry['rfid']] = list(zip(cleaned_weights, cleaned_times))

        '''
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


        nutritions = res
        data_with_nutritions = dict()
        all_nutritions = set()

        for rfid, weight_pairs in data_cleaned.items():
            if rfid not in nutritions.keys():
                continue
            name, nutritions_dict = nutritions[rfid]
            data_with_nutritions[name] = list()

            for weight, t in weight_pairs:
                nutrition_weighted = {k: v*weight for k, v in nutritions_dict.items()}
                nutrition_weighted.update({'time': t})
                
                for nutrition in nutritions_dict.keys():
                    all_nutritions.add(nutrition)
                data_with_nutritions[name].append(nutrition_weighted)

        '''
        Step 4: Find all nutrients, reshape and put into pd dataframe
                df_calories_kcal: [{'time': xxx, 'name': xxx, 'amount' xxx}, ...]
                df_sugar: [{'time': xxx, 'name': xxx, 'amount' xxx}, ...]
        '''
        all_df = dict()

        for nutrition_name in all_nutritions:
            df_data = {'time': [], 'name': [], 'amount': []}
            for name, entries in data_with_nutritions.items():
                for entry in entries:
                    if nutrition_name in entry.keys():
                        df_data['time'].append(entry['time'])
                        df_data['name'].append(name)
                        df_data['amount'].append(entry[nutrition_name])
            
            all_df[nutrition_name] = pd.DataFrame(df_data)
        '''
        Step 5: For each df_<nutrition_name>
        For
            1) whole week / whole dataframe
            2) grouped into each day
        Do
            calculate sum(amount) and groupby(name).sum
        '''
        weekdays = np.array(['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'])
        response = dict()
        for nutrition_name in all_nutritions:
            df = all_df[nutrition_name]
            df.drop(df[df['time'] < time.time() - 7*86400].index)
            df['weekday'] = df['time'].apply(epoch_to_weekday)
            # Get rid of last week today's data
            today_weekday = epoch_to_weekday(time.time())
            df = df.drop(df[(df['weekday'] == today_weekday) & (df['time'] < time.time() - 86400)].index)

            def get_result(sub_df):
                result = {'all': sub_df['amount'].sum()}
                result.update(
                    sub_df.groupby('name').sum()['amount'].to_dict())
                return result

            response[nutrition_name] = {'weekly': get_result(df)}

            start_of_week = epoch_to_weekday(time.time() + 86400)
            weekday_offset = np.where(weekdays == start_of_week)[0][0]
            visualize_weekdays = list(np.roll(weekdays, -weekday_offset))

            for day in visualize_weekdays:
                response[nutrition_name][day] = get_result(df[df['weekday'] == day])

            response[nutrition_name]['plot_weekdays'] = visualize_weekdays

        return make_response(json.dumps({'ok': True, 'message': json.dumps(response)}), 200)
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
        weight_col = weight_db.db['ESP' + esp_id]
        rfid_col = rfid_db.db['ESP' + esp_id]

        unique_rfids = weight_col.distinct('rfid')
        res = []
        for rfid in unique_rfids:
            rfid_entry = rfid_col.find_one({'rfid' : rfid})
            if(rfid == '10'):
                print(rfid_entry['do_track'])
            if rfid_entry['ingredient_name'] != '' and rfid_entry['do_track'].lower() == 'true':
                """ RFID is registered and should be tracked """
                print(rfid)
                rfid_weights = []
                rfid_weights_cursor = weight_col.find({'rfid' : rfid}).sort('_id', 1)
                for rfid_weights_entry in list(rfid_weights_cursor):
                    rfid_weights.append(rfid_weights_entry['weight'])
                rfid_weights = np.array(rfid_weights)
                # print(rfid_weights)
                """ use minimum weight as container weight for taring """
                rfid_container_weight = np.amin(rfid_weights)
                # print(rfid_container_weight)

                rfid_weights = np.concatenate([[0], rfid_weights])
                """ for registration i.e. first refill """
                rfid_current_weight = rfid_weights[-1] - rfid_container_weight
                # print(rfid_current_weight)
                rfid_used_weights = -np.diff(rfid_weights)
                # print(rfid_used_weights)
                rfid_refill_idx = np.where(rfid_used_weights < 0)[0]
                rfid_refill_weights = rfid_weights[rfid_refill_idx + 1]
                rfid_latest_refill = rfid_refill_weights[-1] - rfid_container_weight
                # print(rfid_latest_refill)

                rfid_latest_refill_db_entry = weight_col.find_one({'$and' : [{'rfid' : rfid},
                        {'weight' : rfid_refill_weights[-1]}]})
                # print(rfid_latest_refill_db_entry)
                rfid_latest_refill_time = rfid_latest_refill_db_entry['time']
                # print(rfid_latest_refill_time)

                rfid_track_entry = {'name' : rfid_entry['ingredient_name'],
                        'recent_weight' : rfid_current_weight,
                        'last_refill' : rfid_latest_refill, 
                        'latest_refill_time' : rfid_latest_refill_time}
                res.append(rfid_track_entry)

        """
        fake_data = [{'rfid': 1, 'recent_weight': 90, 'last_refill': 100},
                     {'rfid': 2, 'recent_weight': 800, 'last_refill': 1000}]
        """
        json_data = json.dumps(res)
        return make_response(json_data, 200)
    else:
        return make_response('Invalid request', 400)


def epoch_to_weekday(epoch, timezone='America/New_York'):
    utc_dt = datetime.utcfromtimestamp(epoch).replace(tzinfo=pytz.utc)
    tz = pytz.timezone(timezone)
    dt = utc_dt.astimezone(tz)
    # return dt.strftime('%Y-%m-%d %H:%M:%S %Z%z')
    return dt.strftime('%A')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
