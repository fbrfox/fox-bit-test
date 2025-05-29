import 'dart:convert';
import 'package:foxbit_hiring_test_template/domain/entities/level1_update.dart';

class Level1UpdateModel extends Level1Update {
  const Level1UpdateModel({
    required super.instrumentId,
    super.lastTradedPx,
    super.rolling24HrVolume,
    super.rolling24HrPxChange,
  });

  factory Level1UpdateModel.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return Level1UpdateModel(
      instrumentId: json['InstrumentId'] as int,
      lastTradedPx: parseDouble(json['LastTradedPx']),
      rolling24HrVolume: parseDouble(json['Rolling24HrVolume']),
      rolling24HrPxChange: parseDouble(json['Rolling24HrPxChange']),
    );
  }

  factory Level1UpdateModel.fromJsonString(String jsonString) {
    final Map<String, dynamic> parsedJson = json.decode(jsonString) as Map<String, dynamic>;
    return Level1UpdateModel.fromJson(parsedJson);
  }
}