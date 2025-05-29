import 'package:flutter_test/flutter_test.dart';
import 'package:foxbit_hiring_test_template/data/data_sources/websocket_data_source.dart';
import 'package:foxbit_hiring_test_template/data/models/instrument_model.dart';
import 'package:foxbit_hiring_test_template/data/repositories/instrument_repository_impl.dart';
import 'package:foxbit_hiring_test_template/domain/entities/instrument.dart';
import 'package:foxbit_hiring_test_template/domain/entities/level1_update.dart';
import 'package:mocktail/mocktail.dart';


class MockWebSocketDataSource extends Mock implements WebSocketDataSource {}

void main() {
  late InstrumentRepositoryImpl repository;
  late MockWebSocketDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockWebSocketDataSource();
    repository = InstrumentRepositoryImpl(mockDataSource);
  });

  group('getInstruments', () {
    final tInstrumentModelList = [
      InstrumentModel(instrumentId: 1, symbol: 'BTC/BRL', sortIndex: 0),
      InstrumentModel(instrumentId: 2, symbol: 'ETH/BRL', sortIndex: 1),
    ];

    
    final tInstrumentEntityList = [
      Instrument(instrumentId: 1, symbol: 'BTC/BRL', sortIndex: 0),
      Instrument(instrumentId: 2, symbol: 'ETH/BRL', sortIndex: 1),
    ];

    test(
        'deve retornar List<Instrument> (entidades) quando a chamada ao data source for bem-sucedida',
        () async {
      // Arrange
      when(() => mockDataSource.getInstruments())
          .thenAnswer((_) async => tInstrumentModelList);

      // Act
      final result = await repository.getInstruments();

      // Assert
      expect(result, isA<List<Instrument>>());
      expect(result.length, tInstrumentEntityList.length);
      expect(result[0].instrumentId, tInstrumentEntityList[0].instrumentId);
      expect(result[0].symbol, tInstrumentEntityList[0].symbol);
      verify(() => mockDataSource.getInstruments()).called(1);
      verifyNoMoreInteractions(mockDataSource);
    });

    test('deve lançar uma exceção quando a chamada ao data source falhar', () async {
      // Arrange
      final tException = Exception('Falha na rede');
      when(() => mockDataSource.getInstruments()).thenThrow(tException);

      // Act
      final call = repository.getInstruments;

      // Assert
      expect(() => call(), throwsA(isA<Exception>()));
      verify(() => mockDataSource.getInstruments()).called(1);
      verifyNoMoreInteractions(mockDataSource);
    });
  });

  group('subscribeLevel1', () {
    const tInstrumentId = 1;
    const tLevel1Update = Level1Update(instrumentId: tInstrumentId, lastTradedPx: 100.0);
    
    test('deve retornar um Stream<Level1Update> do data source', () {
      // Arrange
      when(() => mockDataSource.subscribeLevel1(tInstrumentId))
          .thenAnswer((_) => Stream.value(tLevel1Update));

      // Act
      final resultStream = repository.subscribeLevel1(tInstrumentId);

      // Assert
      expect(resultStream, emits(tLevel1Update));
      verify(() => mockDataSource.subscribeLevel1(tInstrumentId)).called(1);
      verifyNoMoreInteractions(mockDataSource);
    });
  });

  group('dispose', () {
    test('deve chamar dispose no data source', () {
      // Arrange
      when(() => mockDataSource.dispose()).thenAnswer((_) {}); 

      // Act
      repository.dispose();

      // Assert
      verify(() => mockDataSource.dispose()).called(1);
      verifyNoMoreInteractions(mockDataSource);
    });
  });
}