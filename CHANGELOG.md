## [0.2.4] - 2018-09-30

* Add fail state

## [0.2.3] - 2018-09-29

* Fix issue with SMS state handler

## [0.2.2] - 2018-09-05

* Update dart version

## [0.2.1] - 2018-08-13

* Fix issue with `toString` on error

## [0.2.0] - 2018-08-09

* Multi SIM card support

## [0.1.6] - 2018-08-07

* Fix permission error when sending SMS on Android O and above

## [0.1.5] - 2018-08-06

* Fix permission error on Android M and above

## [0.1.4] - 2018-06-16

* Error on contact lookup because of unknown size fixed

## [0.1.3] - 2018-05-29
* Error in Android 4.x because of missing permission 'READ_PROFILE' fixed
* Updated Flutter environment sdk to ">=1.19.0 <2.0.0"
* Example app code refactoring

## [0.1.2] - 2018-05-26
* Photo and thumbnail of a contact get loaded with the contact, no need to request them later.
* Example app UI slightly enhanced.

## [0.1.1] - 2018-05-14

* Sms Delivery with Dart Streams and Event Channels
* Fixed some minor errors
* Fixed error on User Profile. The method 'getUserProfile()' will always return an instance of UserProfile even when no user profile configured in the device.
* Fixed error in SmsThread.findContact when first message is a draft.

## [0.1.0] - 2018-04-23

* Sms Delivery

## [0.0.10] - 2018-04-18

* Automatically assign contact to created SmsThread
* Small fix for 'date' and 'dateSent' of SmsMessage
* Fixed error on multiple permissions requests
* Get basic User Profile info.
* Fix gradle build

## [0.0.9] - 2018-03-15

* backward compatibility for Contact (pull request #1 by joanpablo)

## [0.0.8] - 2018-03-10

* SmsReceiver creates all needed field
* Add basic contact support

## [0.0.7] - 2018-03-09

* Small fix for SMS thread

## [0.0.6] - 2018-03-09

* Implementation of SMS thread

## [0.0.5] - 2018-03-09

* Support for dart < 2.0.0

## [0.0.4] - 2018-03-09

* Better query for SMS, now you can query by multiple kind instead of only one.

## [0.0.3] - 2018-03-09

* Better handling of permissions
* Implementation of SmsQuery

## [0.0.2] - 2018-03-08

* Implementation of SmsSender

## [0.0.1] - 2018-03-08

* Implementation of SmsReceiver.
