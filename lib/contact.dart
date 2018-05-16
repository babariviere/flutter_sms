import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';

/// Class that represents the photo of a [Contact]
class Photo {
  Uri _photoUri;
  Uri _thumbnailUri;
  Uint8List _bytes;
  Uint8List _thumbnailBytes;

  Photo(Uri photoUri, Uri thumbnailUri) {
    this._photoUri = photoUri;
    this._thumbnailUri = thumbnailUri;
  }

  /// Gets the full size photo Uri
  Uri get uri => this._photoUri;

  /// Gets the thumbnail photo Uri
  Uri get thumbnailUri => this._thumbnailUri;

  /// Get the bytes of the photo.
  /// By default the returned bytes are the thumbnail representation
  /// of the contact's photo. To retrieve the full size photo the
  /// optional parameter [fullSize] must by set to 'true';
  Future<Uint8List> readBytes({bool fullSize = false}) async {
    if (fullSize) {
      return await _readFullSizeBytes();
    } else {
      return await _readThumbnailBytes();
    }
  }

  Future<Uint8List> _readThumbnailBytes() async {
    if (this._thumbnailUri != null && this._thumbnailBytes == null) {
      var photoQuery = new ContactPhotoQuery();
      this._thumbnailBytes =
          await photoQuery.queryContactPhoto(this._thumbnailUri);
    }
    return _thumbnailBytes;
  }

  Future<Uint8List> _readFullSizeBytes() async {
    if (this._photoUri != null && this._bytes == null) {
      var photoQuery = new ContactPhotoQuery();
      this._bytes =
          await photoQuery.queryContactPhoto(this._photoUri, fullSize: true);
    }
    return _bytes;
  }
}

/// A contact's photo query
class ContactPhotoQuery {
  static ContactPhotoQuery _instance;
  final MethodChannel _channel;

  factory ContactPhotoQuery() {
    if (_instance == null) {
      final MethodChannel methodChannel = const MethodChannel(
          "plugins.babariviere.com/queryContactPhoto",
          const StandardMethodCodec());
      _instance = new ContactPhotoQuery._private(methodChannel);
    }
    return _instance;
  }

  ContactPhotoQuery._private(this._channel);

  /// Get the bytes of the photo specified by [uri].
  /// To get the full size of contact's photo the optional
  /// parameter [fullSize] must be set to true. By default
  /// the returned photo is the thumbnail representation of
  /// the contact's photo.
  Future<Uint8List> queryContactPhoto(Uri uri, {bool fullSize = false}) async {
    return await _channel.invokeMethod(
        "getContactPhoto", {"photoUri": uri.path, "fullSize": fullSize});
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
    if (data.containsKey("photo") && data.containsKey("thumbnail")) {
      this._photo =
          new Photo(Uri.parse(data["photo"]), Uri.parse(data["thumbnail"]));
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

  Future<Contact> queryContact(String address) async {
    if (address == null) {
      throw ("address is null");
    }
    if (queried.containsKey(address) && queried[address] != null) {
      return queried[address];
    }
    if (inProgress.containsKey(address) && inProgress[address] == true) {
      throw ("already requested");
    }
    inProgress[address] = true;
    return await _channel
        .invokeMethod("getContact", {"address": address}).then((dynamic val) {
      Contact contact = new Contact.fromJson(address, val);
      queried[address] = contact;
      inProgress[address] = false;
      return contact;
    });
  }
}

class UserProfile {
  String _fullName;
  Photo _photo;
  List<String> _addresses = new List<String>();

  UserProfile();

  UserProfile._fromJson(Map data) {
    if (data.containsKey("name")) {
      this._fullName = data["name"];
    }
    if (data.containsKey("photo") && data.containsKey("thumbnail")) {
      this._photo =
          new Photo(Uri.parse(data["photo"]), Uri.parse(data["thumbnail"]));
    }
    if (data.containsKey("addresses")) {
      _addresses = List.from(data["addresses"]);
    }
  }

  String get fullName => _fullName;

  Photo get photo => _photo;

  List<String> get addresses => _addresses;
}

class UserProfileProvider {
  static UserProfileProvider _instance;
  final MethodChannel _channel;

  factory UserProfileProvider() {
    if (_instance == null) {
      final MethodChannel methodChannel = const MethodChannel(
          "plugins.babariviere.com/userProfile", const JSONMethodCodec());
      _instance = new UserProfileProvider._private(methodChannel);
    }
    return _instance;
  }

  UserProfileProvider._private(this._channel);

  Future<UserProfile> getUserProfile() async {
    return await _channel.invokeMethod("getUserProfile").then((dynamic val) {
      if (val == null)
        return new UserProfile();
      else
        return new UserProfile._fromJson(val);
    });
  }
}
