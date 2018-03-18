import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class Photo {
  Uri _photoUri;
  Uint8List _bytes;

  Photo(Uri photoUri) {
    this._photoUri = photoUri;
  }

  Uri get uri => this._photoUri;

  Future<Uint8List> readBytes() async {
    if (this._photoUri != null && this._bytes == null) {
      var photoQuery = new ContactPhotoQuery();
      this._bytes = await photoQuery.queryContactPhoto(this._photoUri);
    }
    return _bytes;
  }
}

class ContactPhotoQuery {

  static ContactPhotoQuery _instance;
  final MethodChannel _channel;

  factory ContactPhotoQuery() {
    if (_instance == null) {
      final MethodChannel methodChannel = const MethodChannel(
          "plugins.babariviere.com/queryContactPhoto", const StandardMethodCodec());
      _instance = new ContactPhotoQuery._private(methodChannel);
    }
    return _instance;
  }

  ContactPhotoQuery._private(this._channel);

  Future<Uint8List> queryContactPhoto(Uri photoUri) async {
    return await _channel.invokeMethod(
        "getContactPhoto", {"photoUri": photoUri.path});
  }
}

/// A contact of yours
class Contact {
  String _fullName;
  String _firstName;
  String _lastName;
  String _address;
  Photo _photo;

  Contact(String address,
      {String firstName, String lastName, String fullName, Photo photo}) {
    this._address = address;
    this._firstName = firstName;
    this._lastName = lastName;
    if (fullName == null) {
      this._fullName = _firstName + " " + _lastName;
    } else {
      this._fullName = fullName;
    }
    this._photo = photo;
  }

  Contact.fromJson(String address, Map data) {
    this._address = address;
    if (data == null) return;
    if (data.containsKey("first")) {
      this._firstName = data["first"];
    }
    if (data.containsKey("last")) {
      this._lastName = data["last"];
    }
    if (data.containsKey("name")) {
      this._fullName = data["name"];
    }
    if (data.containsKey("photo")) {
      this._photo = new Photo(Uri.parse(data["photo"]));
    }
  }

  String get fullName => this._fullName;

  String get firstName => this._firstName;

  String get lastName => this._lastName;

  String get address => this._address;

  Photo get photo => this._photo;
}

/// Called when sending SMS failed
typedef void ContactHandlerFail(Object e);

/// A contact query
class ContactQuery {
  static ContactQuery _instance;
  final MethodChannel _channel;
  static Map<String, Contact> queried = {};
  static Map<String, bool> inProgress = {};

  factory ContactQuery() {
    if (_instance == null) {
      final MethodChannel methodChannel = const MethodChannel(
          "plugins.babariviere.com/queryContact", const JSONMethodCodec());
      _instance = new ContactQuery._private(methodChannel);
    }
    return _instance;
  }

  ContactQuery._private(this._channel);

  Future<Contact> queryContact(String address,
      {ContactHandlerFail onError}) async {
    if (address == null) {
      onError("address is null");
      return null;
    }
    if (queried.containsKey(address) && queried[address] != null) {
      return queried[address];
    }
    if (inProgress.containsKey(address) && inProgress[address] == true) {
      onError("already requested");
      return null;
    }
    inProgress[address] = true;
    return await _channel.invokeMethod("getContact", {"address": address}).then(
            (dynamic val) {
          Contact contact = new Contact.fromJson(address, val);
          queried[address] = contact;
          inProgress[address] = false;
          return contact;
        }, onError: (Object e) {
      if (onError != null) {
        onError(e);
      }
    });
  }
}
