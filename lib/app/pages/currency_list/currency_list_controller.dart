import 'dart:async';

import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:foxbit_hiring_test_template/domain/entities/instrument.dart';
import 'package:foxbit_hiring_test_template/domain/entities/level1_update.dart';
import 'package:foxbit_hiring_test_template/domain/usecases/get_instruments_use_case.dart';
import 'package:foxbit_hiring_test_template/domain/usecases/subscribe_level1_use_case.dart';

class CurrencyListController extends Controller {
  final GetInstrumentsUseCase _getInstrumentsUseCase;
  final SubscribeLevel1UseCase _subscribeLevel1UseCase;

  CurrencyListController(this._getInstrumentsUseCase, this._subscribeLevel1UseCase) : super();

  

  List<Instrument>? instruments;
  String? errorMessage;
  bool isLoading = true;

  final Map<int, StreamSubscription<Level1Update?>> _level1Subscriptions = {};

  @override
  void onInitState() {
    super.onInitState();
    _loadInstruments();
  }

  void _loadInstruments() {
    isLoading = true;
    errorMessage = null;
    refreshUI();

    _getInstrumentsUseCase.execute(
      _GetInstrumentsObserver(this),
    );
  }

  void _handleInstrumentList(List<Instrument>? fetchedInstruments) {
    if (fetchedInstruments != null && fetchedInstruments.isNotEmpty) {
      fetchedInstruments.sort((a, b) => a.sortIndex.compareTo(b.sortIndex));
      instruments = fetchedInstruments;

      for (final instrument in instruments!) {
        _subscribeToInstrumentUpdates(instrument.instrumentId);
      }
    } else {
      instruments = [];
      errorMessage = "Nenhuma moeda encontrada.";
    }
    isLoading = false;
    refreshUI();
  }

  void _subscribeToInstrumentUpdates(int instrumentId) {
    _level1Subscriptions[instrumentId]?.cancel();

    final params = SubscribeLevel1UseCaseParams(instrumentId);

    _subscribeLevel1UseCase.buildUseCaseStream(params).then((stream) {
         _level1Subscriptions[instrumentId] = stream.listen(
            (Level1Update? update) {
                if (update != null) {
                    _updateInstrumentData(update);
                }
            },
            onError: (e) {
            },
            onDone: () {
            }
        );
    }).catchError((e) {
    });
  }

  void _updateInstrumentData(Level1Update update) {
    if (instruments == null) return;

    final index = instruments!.indexWhere((inst) => inst.instrumentId == update.instrumentId);
    if (index != -1) {
      instruments![index] = instruments![index].copyWith(
        lastTradedPx: update.lastTradedPx ?? instruments![index].lastTradedPx,
        rolling24HrVolume: update.rolling24HrVolume ?? instruments![index].rolling24HrVolume,
        rolling24HrPxChange: update.rolling24HrPxChange ?? instruments![index].rolling24HrPxChange,
      );
      refreshUI();
    }
  }

  void retryLoadInstruments() {
    _loadInstruments();
  }

  @override
  void onDisposed() {
    _level1Subscriptions.forEach((id, subscription) {
      subscription.cancel();
      _subscribeLevel1UseCase.unsubscribe(id);
    });
    _level1Subscriptions.clear();
    _getInstrumentsUseCase.dispose();
    _subscribeLevel1UseCase.dispose();
    super.onDisposed();
  }
  
  @override
  void initListeners() {
    
  }
}

class _GetInstrumentsObserver implements Observer<List<Instrument>> {
  final CurrencyListController _controller;
  _GetInstrumentsObserver(this._controller);

  @override
  void onNext(List<Instrument>? instruments) {
    _controller._handleInstrumentList(instruments);
  }

  @override
  void onError(e) {
    _controller.errorMessage = 'Falha ao carregar moedas: $e';
    _controller.isLoading = false;
    _controller.refreshUI();
  }

  @override
  void onComplete() {
  }
}