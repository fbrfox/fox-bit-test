import 'dart:async';

import 'package:foxbit_hiring_test_template/data/data_sources/websocket_data_source.dart';
import 'package:foxbit_hiring_test_template/domain/entities/instrument.dart';
import 'package:foxbit_hiring_test_template/domain/entities/level1_update.dart';
import 'package:foxbit_hiring_test_template/domain/repositories/instrument_repository.dart';

class InstrumentRepositoryImpl implements InstrumentRepository {
  final WebSocketDataSource _webSocketDataSource;

  InstrumentRepositoryImpl(this._webSocketDataSource);

  @override
  Future<List<Instrument>> getInstruments() async {
    final instrumentModels = await _webSocketDataSource.getInstruments();

    final List<Instrument> instruments = instrumentModels.map((model) {
      return Instrument(
        instrumentId: model.instrumentId,
        symbol: model.symbol,
        sortIndex: model.sortIndex,
      );
    }).toList();

    return instruments;
  }

  @override
  Stream<Level1Update> subscribeLevel1(int instrumentId) {
    return _webSocketDataSource.subscribeLevel1(instrumentId);
  }

  @override
  void unsubscribeLevel1(int instrumentId) {
    _webSocketDataSource.unsubscribeLevel1(instrumentId);
  }

  @override
  void dispose() {
    _webSocketDataSource.dispose();
  }
}
