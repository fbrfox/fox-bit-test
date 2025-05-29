import 'dart:async';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:foxbit_hiring_test_template/domain/entities/instrument.dart';
import 'package:foxbit_hiring_test_template/domain/repositories/instrument_repository.dart';

class GetInstrumentsUseCase extends UseCase<List<Instrument>, void> {
  final InstrumentRepository _instrumentRepository;

  GetInstrumentsUseCase(this._instrumentRepository);

  @override
  Future<Stream<List<Instrument>?>> buildUseCaseStream(void params) async {
    final StreamController<List<Instrument>> controller = StreamController();
    try {
      final List<Instrument> instruments = await _instrumentRepository.getInstruments();
      controller.add(instruments);
      controller.close();
    } catch (e) {
      controller.addError(e);
    }
    return controller.stream;
  }
}