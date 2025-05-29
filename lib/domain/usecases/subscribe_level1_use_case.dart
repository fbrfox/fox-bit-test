import 'dart:async';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:foxbit_hiring_test_template/domain/entities/level1_update.dart';
import 'package:foxbit_hiring_test_template/domain/repositories/instrument_repository.dart';

class SubscribeLevel1UseCaseParams {
  final int instrumentId;
  SubscribeLevel1UseCaseParams(this.instrumentId);
}

class SubscribeLevel1UseCase extends UseCase<Level1Update, SubscribeLevel1UseCaseParams> {
  final InstrumentRepository _instrumentRepository;

  SubscribeLevel1UseCase(this._instrumentRepository);

  @override
  Future<Stream<Level1Update?>> buildUseCaseStream(SubscribeLevel1UseCaseParams? params) async {
    if (params == null) {
      return Stream.value(null);
    }
    final StreamController<Level1Update> controller = StreamController<Level1Update>();

    final Stream<Level1Update> streamFromRepository = _instrumentRepository.subscribeLevel1(params.instrumentId);

    streamFromRepository.listen((update) {
      if (!controller.isClosed) {
        controller.add(update);
      }
    }, onError: (e) {
      if (!controller.isClosed) {
        controller.addError(e.toString());
      }
    }, onDone: () {
      if (!controller.isClosed) {
        controller.close();
      }
    },);
    
    return Future.value(controller.stream);
  }

  void unsubscribe(int instrumentId) {
    _instrumentRepository.unsubscribeLevel1(instrumentId);
  }
}