import 'dart:convert';
import 'package:foxbit_hiring_test_template/domain/entities/instrument.dart';

class InstrumentModel extends Instrument {
  InstrumentModel({
    required super.instrumentId,
    required super.symbol,
    required super.sortIndex,
  });

  factory InstrumentModel.fromJson(Map<String, dynamic> json) {
    return InstrumentModel(
      instrumentId: json['InstrumentId'] as int,
      symbol: json['Symbol'] as String,
      sortIndex: json['SortIndex'] as int,
    );
  }

  static List<InstrumentModel> listFromJsonString(String jsonString) {
    final List<dynamic> parsedList = json.decode(jsonString) as List<dynamic>;
    return parsedList
        .map((item) => InstrumentModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}