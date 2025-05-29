import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:foxbit_hiring_test_template/domain/entities/level1_update.dart';
import 'package:foxbit_hiring_test_template/domain/repositories/instrument_repository.dart';
import 'package:foxbit_hiring_test_template/domain/usecases/subscribe_level1_use_case.dart';
import 'package:mocktail/mocktail.dart';



class MockInstrumentRepository extends Mock implements InstrumentRepository {}

void main() {
  late SubscribeLevel1UseCase useCase;
  late MockInstrumentRepository mockInstrumentRepository;

  const tInstrumentId = 1;
  final tParams = SubscribeLevel1UseCaseParams(tInstrumentId);

  const tLevel1Update = Level1Update(
    instrumentId: tInstrumentId,
    lastTradedPx: 123.45,
    rolling24HrVolume: 1000.0,
    rolling24HrPxChange: 0.5,
  );

  setUp(() {
    mockInstrumentRepository = MockInstrumentRepository();
    useCase = SubscribeLevel1UseCase(mockInstrumentRepository);
    registerFallbackValue(SubscribeLevel1UseCaseParams(0));
  });

  group('buildUseCaseStream', () {
    test(
        'deve retornar um stream de Level1Update do repositório para um InstrumentId específico',
        () async {
      // Arrange
      when(() => mockInstrumentRepository.subscribeLevel1(tInstrumentId))
          .thenAnswer((_) => Stream.value(tLevel1Update));

      // Act
      final stream = await useCase.buildUseCaseStream(tParams);

      // Assert
      expect(stream, emitsInOrder([tLevel1Update, emitsDone]));
      
      verify(() => mockInstrumentRepository.subscribeLevel1(tInstrumentId)).called(1);
      verifyNoMoreInteractions(mockInstrumentRepository);
    });

  });

  group('unsubscribe', () {
    test('deve chamar o método unsubscribeLevel1 do repositório', () {
      // Arrange
      when(() => mockInstrumentRepository.unsubscribeLevel1(tInstrumentId))
          .thenAnswer((_) {});

      // Act
      useCase.unsubscribe(tInstrumentId);

      // Assert
      verify(() => mockInstrumentRepository.unsubscribeLevel1(tInstrumentId)).called(1);
      verifyNoMoreInteractions(mockInstrumentRepository);
    });
  });

  tearDown(() {
    useCase.dispose();
  });
}