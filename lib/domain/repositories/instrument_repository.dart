import 'dart:async';
import 'package:foxbit_hiring_test_template/domain/entities/instrument.dart';
import 'package:foxbit_hiring_test_template/domain/entities/level1_update.dart';

abstract class InstrumentRepository {
  Future<List<Instrument>> getInstruments();
  Stream<Level1Update> subscribeLevel1(int instrumentId);
  void unsubscribeLevel1(int instrumentId);
  void dispose();
}