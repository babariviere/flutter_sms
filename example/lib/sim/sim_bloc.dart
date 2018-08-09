import 'dart:async';

import 'package:sms/sms.dart';

class SimCardsBloc {
  SimCardsBloc() {
    _onSimCardChanged = _streamController.stream.asBroadcastStream();
  }

  final _simCardsProvider = new SimCardsProvider();
  final _streamController = new StreamController<SimCard>();
  Stream<SimCard> _onSimCardChanged;
  List<SimCard> _simCards;
  SimCard _selectedSimCard;

  Stream<SimCard> get onSimCardChanged => _onSimCardChanged;

  SimCard get selectedSimCard => _selectedSimCard;

  void loadSimCards() async {
    _simCards = await _simCardsProvider.getSimCards();
    _simCards.forEach((sim) {
      if (sim.state == SimCardState.Ready) {
        this.selectSimCard(sim);
      }
    });
  }

  void toggleSelectedSim() async {
    if (_simCards == null) {
      _simCards = await _simCardsProvider.getSimCards();
    }

    _selectNextSimCard();
    _streamController.add(_selectedSimCard);
  }

  SimCard _selectNextSimCard() {
    if (_selectedSimCard == null) {
      _selectedSimCard = _simCards[0];
      return _selectedSimCard;
    }

    for (var i = 0; i < _simCards.length; i++) {
      if (_simCards[i].imei == _selectedSimCard.imei) {
        if (i + 1 < _simCards.length) {
          _selectedSimCard = _simCards[i + 1];
        } else {
          _selectedSimCard = _simCards[0];
        }
        break;
      }
    }

    return _selectedSimCard;
  }

  void selectSimCard(SimCard sim) {
    _selectedSimCard = sim;
    _streamController.add(_selectedSimCard);
  }
}
