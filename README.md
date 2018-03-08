# Flutter SMS

This is an SMS library for flutter.

It only support Android for now (I can't do it for iOS because I don't own Mac).

## Getting Started

For help getting started with Flutter, view our online
[documentation](https://flutter.io/).

For help on editing plugin code, view the [documentation](https://flutter.io/platform-plugins/#edit-code).

### Receiving SMS

```dart
var receiver = SmsReceiver();
receiver.onSmsReceived.listen((SmsMessage msg) => ...);
```

### Sender SMS

```dart
var sender = SmsSender();
sender.sendSMS(SmsMessage('address', 'body'));
```

## Roadmap

- [x] Sms Receiver
- [x] Sms Sender
- [ ] Sms Delivery
- [ ] Sms Query
- [ ] MMS Receiver
- [ ] MMS Sender
- [ ] MMS Delivery
- [ ] MMS Query
- [ ] Multi Sim Card

## Contributions

Any contribution is welcome.