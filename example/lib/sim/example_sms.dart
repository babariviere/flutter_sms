
import 'dart:async';

import 'package:flutter/foundation.dart';

class SimCard {
  final int slot;
  final String imei;

  SimCard({
    @required this.slot,
    @required this.imei
  });
}

class SimCardsManager {
  const SimCardsManager();

  Future<List<SimCard>> querySimCards() {
    return new Future.delayed(new Duration(milliseconds: 100), (){
      return [
        new SimCard(slot: 1, imei: 'imei-1'),
        new SimCard(slot: 2, imei: 'imei-2')
      ];
    });
  }
}