import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:nutriscient/fcm/message.dart';

/// Define a top-level named handler which background/terminated messages will
/// call.
///
/// To verify things are working, check out the native platform logs.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

/// Create a [AndroidNotificationChannel] for heads up notifications
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  'This channel is used for important notifications.', // description
  importance: Importance.high,
);

/// Initialize the [FlutterLocalNotificationsPlugin] package.
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Awaited in main()
Future<void> fcmInit() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // runApp(MessagingExampleApp());
}

// Called in build, after super.initState()
void setupFcmCallbacks(BuildContext context) {
  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage message) {
    if (message != null) {
      print("Pushing1");
      Navigator.pushNamed(context, '/message',
          arguments: MessageArguments(message, true));
    }
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification notification = message.notification;
    AndroidNotification android = message.notification?.android;
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channel.description,
              // TODO add a proper drawable resource to android, for now using
              //      one that already exists in example app.
              icon: 'launch_background',
            ),
          ));
      print('Pushing2');
      Navigator.pushNamed(context, '/message',
          arguments: MessageArguments(message, true));
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('Pushing3');
    Navigator.pushNamed(context, '/message',
        arguments: MessageArguments(message, true));
  });
}

// Callback for notification setting
Future<void> updatePushNotiSubscription(bool doSubscribe) async {
  if (doSubscribe) {
    print('FlutterFire Messaging Example: Subscribing to topic "fcm_test".');
    await FirebaseMessaging.instance.subscribeToTopic('fcm_test');
    print(
        'FlutterFire Messaging Example: Subscribing to topic "fcm_test" successful.');
  } else {
    print(
        'FlutterFire Messaging Example: Unsubscribing from topic "fcm_test".');
    await FirebaseMessaging.instance.unsubscribeFromTopic('fcm_test');
    print(
        'FlutterFire Messaging Example: Unsubscribing from topic "fcm_test" successful.');
  }
}
