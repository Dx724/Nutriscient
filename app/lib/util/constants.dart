import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

String kBackend_default = 'http://ec2-35-153-232-54.compute-1.amazonaws.com:8000';
String kBackend = '';

String kScaleId_default = '7d0d8300';
String kScaleId = '';

Future<void> loadConstants() async {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final SharedPreferences prefs = await _prefs;

  kBackend = prefs.getString('kBackend') ?? kBackend_default;
  kScaleId = prefs.getString('kScaleId') ?? kScaleId_default;
}

Future<void> setConstant(String key, var value) async {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final SharedPreferences prefs = await _prefs;

  if (value is bool) {
    prefs.setBool(key, value);
  } else if (value is double) {
    prefs.setDouble(key, value);
  } else if (value is int) {
    prefs.setInt(key, value);
  } else if (value is String) {
    prefs.setString(key, value);
  } else if (value is List<String>) {
    prefs.setStringList(key, value);
  } else {
    throw Exception('value type not supported!');
  }
}

Future<void> saveAllConstants() async {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final SharedPreferences prefs = await _prefs;

  assert(kBackend != null);
  assert(kScaleId != null);

  prefs.setString('kBackend', kBackend);
  prefs.setString('kScaleId', kScaleId);
}
