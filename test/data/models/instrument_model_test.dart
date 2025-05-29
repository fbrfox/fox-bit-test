import 'package:flutter_test/flutter_test.dart';
import 'package:foxbit_hiring_test_template/data/models/instrument_model.dart';
import 'package:foxbit_hiring_test_template/domain/entities/instrument.dart';

void main() {
  final tInstrumentModel = InstrumentModel(
    instrumentId: 1,
    symbol: "BTC/BRL",
    sortIndex: 0,
  );

  test('deve ser uma subclasse de Instrument (entidade)', () {
    // Assert
    expect(tInstrumentModel, isA<Instrument>());
  });

  group('fromJson', () {
    test('deve retornar um InstrumentModel válido a partir de um JSON', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        "OMSId": 1,
        "InstrumentId": 1,
        "Symbol": "BTC/BRL",
        "Product1": 1,
        "Product1Symbol": "BTC",
        "Product2": 2,
        "Product2Symbol": "BRL",
        "InstrumentType": "Standard",
        "VenueInstrumentId": 1,
        "VenueId": 1,
        "SortIndex": 0,
        "SessionStatus": "Running",
        
      };

      // Act
      final result = InstrumentModel.fromJson(jsonMap);

      // Assert
      expect(result.instrumentId, tInstrumentModel.instrumentId);
      expect(result.symbol, tInstrumentModel.symbol);
      expect(result.sortIndex, tInstrumentModel.sortIndex);
    });
  });

  group('listFromJsonString', () {
    test('deve retornar uma lista de InstrumentModel a partir de uma string JSON', () {
      // Arrange
      const jsonString = """
      [
        {"OMSId":1,"InstrumentId":1,"Symbol":"BTC/BRL","SortIndex":0},
        {"OMSId":1,"InstrumentId":2,"Symbol":"LTC/BRL","SortIndex":1}
      ]
      """;
      final expectedList = [
        InstrumentModel(instrumentId: 1, symbol: "BTC/BRL", sortIndex: 0),
        InstrumentModel(instrumentId: 2, symbol: "LTC/BRL", sortIndex: 1),
      ];

      // Act
      final result = InstrumentModel.listFromJsonString(jsonString);

      // Assert
      expect(result.length, 2);
      expect(result[0].instrumentId, expectedList[0].instrumentId);
      expect(result[0].symbol, expectedList[0].symbol);
      expect(result[1].instrumentId, expectedList[1].instrumentId);
      
    });
  });
}