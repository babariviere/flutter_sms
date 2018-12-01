![xxhdpi](https://user-images.githubusercontent.com/37498811/41118114-d9cad440-6ab0-11e8-9254-68d6aac245be.png)

# [UNMAINTAINED] This project is unmaintained


# Flutter SMS

This is an SMS library for flutter.

It only support Android for now (I can't do it for iOS because I don't own Mac).

## Getting Started

For help getting started with Flutter, view our online
[documentation](https://flutter.io/).

For help on editing plugin code, view the [documentation](https://flutter.io/platform-plugins/#edit-code).

## Installation and Usage

Once you're familiar with Flutter you may install this package adding `sms` (0.1.4 or higher) to the dependencies list
of the `pubspec.yaml` file as follow:

```yaml
dependencies:
  flutter:
    sdk: flutter

  sms: ^0.2.0
```

Then run the command `flutter packages get` on the console.

## Querying SMS messages

Add the import statement for `sms` and create an instance of the *SmsQuery* class:

```dart
import 'package:sms/sms.dart';

void main() {
  SmsQuery query = new SmsQuery();
}

```

## Getting all SMS messages

```dart
List<SmsMessage> messages = await query.getAllSms;
``` 

**Note**: _the use of `await` keyword means that `getAllSms` is resolved asynchronously
and a Future is retorned._

## Filtering SMS messages

The method `querySms` from the `SmsQuery` class returns a list of sms depending of the supplied parameters. For example,
for querying all the sms messages sent and received write the followed code:

```dart
await query.querySms({
    kinds: [SmsQueryKind.Inbox, SmsQueryKind.Sent]
});
```

You can also query all the sms messages sent and received from a specific contact:

```dart
await query.querySms({
    address: getContactAddress()
});
```

## Getting all Threads Conversations

With `SmsQuery` you can also get the entire list of conversations:

```dart
List<SmsThread> threads = await query.getAllThreads;
```

## Getting the Contact info

Each conversation thread is related with a Contact. 
The class `Contact` contains all the info of a thread contact (address, photo, full name).
To get access to `Contact` class you must import `'package:sms/contact.dart'` into your dart file:

```dart
import 'package:sms/contact.dart';

void main() {
  ...
  Contact contact = threads.first.contact;
  print(contact.address);
}
```

## Querying Contact

You can also query a contact by its address _(phone number)_:

```dart
import 'package:sms/contact.dart';

void main() {
  ContactQuery contacts = new ContactQuery();
  Contact contact = await contacts.queryContact(someAddress());
  print(contact.fullName);
}
String getAddress() {...}
```

## The Contact photo

You can retrieve the photo of the contact (full size or thumbnail):

```dart
...
Uint8List fullSize = contact.photo.bytes;
Uint8List thumbnail = contact.thumbnail.bytes;
```

## User Profile

Some times it is useful to request basic info of the phone owner, like the contact photo, addresses, etc.

```dart
import 'package:sms/contact.dart';

UserProfileProvider provider = new UserProfileProvider();
UserProfile profile = await provider.getUserProfile();
print(profile.fullName);
```

## Sending SMS

What about sending a SMS? All you have to do is to create an instance of the `SmsSender` class:

```dart
import 'package:sms/sms.dart';

void main() {
  SmsSender sender = new SmsSender();
  String address = someAddress();
  ...
  sender.sendSms(new SmsMessage(address, 'Hello flutter!'));
}
```

To be notified when the message is sent and/or delivered, you must add a listener to your message:

```dart
import 'package:sms/sms.dart';

void main() {
  SmsSender sender = new SmsSender();
  String address = someAddress();
  ...
  SmsMessage message = new SmsMessage(address, 'Hello flutter!');
  message.onStateChanged.listen((state) {
    if (state == SmsMessageState.Sent) {
      print("SMS is sent!");
    } else if (state == SmsMessageState.Delivered) {
      print("SMS is delivered!");
    }
  });
  sender.sendSms(message);
}
```
Some times it is useful to be notified of delivered messages regardless of the message. To do that you must subscribe to the `onSmsDelivered` of the `SmsSender` class instance:

```dart
void main() {
...
SmsSender sender = new SmsSender();
sender.onSmsDelivered.listen((SmsMessage message){
  print('${message.address} received your message.');
}));
}
```

You can also send with another SimCard:

```dart
void main() {
SimCardsProvider provider = new SimCardsProvider();
SimCard card = await provider.getSimCards()[0];
SmsSender sender = new SmsSender();
SmsMessage message = new SmsMessage("address", "message");
sender.sendSMS(message, simCard: card);
}
```

**Note**: Using the `onSmsDelivered` from the `SmsSender` will only notify to listeners of messages that has been sent through `SmsSender.send()`.

## Receiving SMS

If you want to be notified for incoming new messages you must subscribe to an instance of the `SmsReceiver` class:

```dart
import 'package:sms/sms.dart';

void main() {
  SmsReceiver receiver = new SmsReceiver();
  receiver.onSmsReceived.listen((SmsMessage msg) => print(msg.body));
}
```

## Roadmap

- [x] SMS Receiver
- [x] SMS Sender
- [x] SMS Delivery
- [x] SMS Query
- [x] SMS Thread
- [ ] MMS Receiver
- [ ] MMS Sender
- [ ] MMS Delivery
- [ ] MMS Query
- [ ] Multi Sim Card
- [x] Contact
- [x] Contact Photo (full size, thumbnail)
- [x] User profile (basic info)

## Contributors

- babariviere [github](https://github.com/babariviere)
- joanpablo [github](https://github.com/joanpablo)
- saifulfrank [github](https://github.com/saifulfrank)

### App logo
Designed and created by [Imrul kayes](https://github.com/saifulfrank)

## Contributions

Any contribution is welcome.
