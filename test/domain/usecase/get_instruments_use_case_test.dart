import 'package:flutter_test/flutter_test.dart';
import 'package:foxbit_hiring_test_template/domain/entities/instrument.dart';
import 'package:foxbit_hiring_test_template/domain/repositories/instrument_repository.dart';
import 'package:foxbit_hiring_test_template/domain/usecases/get_instruments_use_case.dart';
import 'package:mocktail/mocktail.dart';


class MockInstrumentRepository extends Mock implements InstrumentRepository {}

void main() {
  late GetInstrumentsUseCase useCase;
  late MockInstrumentRepository mockInstrumentRepository;

  setUp(() {
    mockInstrumentRepository = MockInstrumentRepository();
    useCase = GetInstrumentsUseCase(mockInstrumentRepository);
  });

  final tInstrumentsList = [
    Instrument(instrumentId: 1, symbol: 'BTC/BRL', sortIndex: 0, lastTradedPx: 300000.0),
    Instrument(instrumentId: 2, symbol: 'ETH/BRL', sortIndex: 1, lastTradedPx: 20000.0),
  ];

  test('deve obter lista de instrumentos do repositório', () async {
    // Arrange 
    when(() => mockInstrumentRepository.getInstruments())
        .thenAnswer((_) async => tInstrumentsList);

    // Act 
    final stream = await useCase.buildUseCaseStream(null);
    final result = await stream.first;

    // Assert 
    expect(result, tInstrumentsList);
    verify(() => mockInstrumentRepository.getInstruments()).called(1);
    verifyNoMoreInteractions(mockInstrumentRepository);
  });

}