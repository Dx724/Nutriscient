import firebase_admin
from firebase_admin import db, messaging, credentials

# See https://firebase.google.com/docs/admin/setup#python for setting up / getting credentials
cred = credentials.Certificate("cred/nutriscient-47b3a-firebase-adminsdk-h2s14-179ee7ac0a.json")

firebase_admin.initialize_app(cred, options={
    'databaseURL': 'https://nutriscient-47b3a-default-rtdb.firebaseio.com/'
})

db_root = db.reference()


def get_db(esp_id):
    db_list = db_root.get(shallow=True)
    if db_list is None or esp_id not in db_list.keys():
        # TODO: DB Structure
        db_root.update({esp_id: 1})

    return db_root.child(esp_id)


def push_notification(title, body, field_a, topic='fcm_test'):
    message = messaging.Message(
        notification=messaging.Notification(
            title=title,
            body=body,
        ),
        android=messaging.AndroidConfig(
            priority='high'
        ),
        data={
            'Field-A': field_a,
        },
        topic=topic,
    )
    return 'Sent message ' + str(messaging.send(message))


if __name__ == '__main__':
    client_id = b'}\r\x83\x00'  # machine.unique_id()
    client_id = '{:02x}{:02x}{:02x}{:02x}'.format(client_id[0], client_id[1], client_id[2], client_id[3])
    db = get_db(client_id)

    print(push_notification("Title", "Body", "some data"))
