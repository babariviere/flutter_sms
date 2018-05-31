
import 'dart:async';

import 'example_sms.dart';

class SimBloc {
  final _simCardsManager = const SimCardsManager();
  final _streamController = new StreamController<SimCard>();
  List<SimCard> _simCollection;
  SimCard _selectedSim;

  Stream<SimCard> get onSelectedSimChanged => _streamController.stream;

  void toggleSelectedSim() async {
    if (_simCollection == null) {
      _simCollection = await _simCardsManager.querySimCards();
    }

    _selectNextSim();
    _streamController.add(_selectedSim);
  }

  SimCard _selectNextSim() {
    if (_selectedSim == null) {
      _selectedSim = _simCollection[0];
      return _selectedSim;
    }

    for(var i = 0; i < _simCollection.length; i++) {
      if (_simCollection[i].imei == _selectedSim.imei) {
        if (i + 1 < _simCollection.length) {
          _selectedSim = _simCollection[i + 1];
        }
        else {
          _selectedSim = _simCollection[0];
        }
        break;
      }
    }

    return _selectedSim;
  }
}