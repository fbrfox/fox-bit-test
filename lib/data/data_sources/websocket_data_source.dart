import 'dart:async';
import 'dart:convert';

import 'package:foxbit_hiring_test_template/data/models/instrument_model.dart';
import 'package:foxbit_hiring_test_template/data/models/level1_update_model.dart';
import 'package:foxbit_hiring_test_template/domain/entities/level1_update.dart';

import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

abstract class WebSocketDataSource {
  Future<List<InstrumentModel>> getInstruments();
  Stream<Level1Update> subscribeLevel1(int instrumentId);
  void unsubscribeLevel1(int instrumentId);
  void dispose();
}

class WebSocketDataSourceImpl implements WebSocketDataSource {
  IOWebSocketChannel? _channel;
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController.broadcast();

  final Map<int, StreamController<Level1Update>> _level1UpdateControllers = {};
  final Map<int, Completer<dynamic>> _requestCompleters = {};
  int _nextRequestId = 1;

  final String _websocketUrl = 'wss://api.foxbit.com.br/';

  WebSocketDataSourceImpl() {
    _connect();
  }

  void _connect() {
    if (_channel != null && _channel?.closeCode == null) {
      return;
    }
    _channel = IOWebSocketChannel.connect(Uri.parse(_websocketUrl));
    _channel!.stream.listen(
      _onMessageReceived,
      onError: (error) {
        _messageController.addError(error.toString());
        _reconnect();
      },
      onDone: () {
        if (_channel?.closeCode != status.goingAway &&
            _channel?.closeCode != status.normalClosure) {
          _reconnect();
        }
      },
    );
  }

  void _reconnect() {
    _channel = null;
    _level1UpdateControllers.forEach((instrumentId, controller) {
      if (!controller.isClosed) controller.close();
    });
    _level1UpdateControllers.clear();

    Future.delayed(const Duration(seconds: 5), () {
      _connect();
    });
  }

  Future<T> _sendRequest<T>(
      String method, Map<String, dynamic> payload, T Function(dynamic) parser) {
    final requestId = _nextRequestId++;
    final completer = Completer<T>();
    _requestCompleters[requestId] = completer;

    final messagePayload = {
      "m": 0,
      "i": requestId,
      "n": method,
      "o": json.encode(payload),
    };

    if (_channel == null || _channel!.closeCode != null) {
      _connect();
      return Future.delayed(const Duration(seconds: 2), () {
        if (_channel != null && _channel!.closeCode == null) {
          _channel!.sink.add(json.encode(messagePayload));
          return completer.future;
        } else {
          completer
              .completeError(Exception('WebSocket not connected for $method'));
          _requestCompleters.remove(requestId);
          return completer.future;
        }
      });
    }

    _channel!.sink.add(json.encode(messagePayload));
    return completer.future;
  }

  void _onMessageReceived(dynamic message) {
    try {
      final decodedMessage =
          json.decode(message as String) as Map<String, dynamic>;
      _messageController.add(decodedMessage);

      final int sequenceNumber = decodedMessage['i'] as int;
      final String methodName = decodedMessage['n'] as String;
      final String payloadString = decodedMessage['o'] as String;

      if (_requestCompleters.containsKey(sequenceNumber)) {
        final completer = _requestCompleters.remove(sequenceNumber)!;
        if (methodName == 'getInstruments' && !completer.isCompleted) {
          final instruments = InstrumentModel.listFromJsonString(payloadString);
          completer.complete(instruments);
        } else if (methodName == 'SubscribeLevel1' && !completer.isCompleted) {
          Map<String, dynamic> confirmationPayload;
          try {
            confirmationPayload =
                json.decode(payloadString) as Map<String, dynamic>;
          } catch (e) {
            completer.complete(true);
            return;
          }

          if (confirmationPayload.containsKey('InstrumentId')) {
            final update = Level1UpdateModel.fromJsonString(payloadString);
            final controller = _level1UpdateControllers[update.instrumentId];
            if (controller != null && !controller.isClosed) {
              controller.add(update);
            }
          }
          completer.complete(true);
        } else {
          if (!completer.isCompleted) {
            completer.complete(json.decode(payloadString));
          }
        }
        return;
      }

      if (methodName == 'level1update' ||
          (methodName == 'SubscribeLevel1' && payloadString.isNotEmpty)) {
        Map<String, dynamic> updatePayload;
        try {
          updatePayload = json.decode(payloadString) as Map<String, dynamic>;
        } catch (e) {
          return;
        }

        if (updatePayload.containsKey('InstrumentId')) {
          final update = Level1UpdateModel.fromJson(updatePayload);
          final controller = _level1UpdateControllers[update.instrumentId];
          if (controller != null && !controller.isClosed) {
            controller.add(update);
          }
        }
      }
    } catch (e) {
      _messageController.addError(e);
    }
  }

  @override
  Future<List<InstrumentModel>> getInstruments() {
    return _sendRequest<List<InstrumentModel>>(
      'getInstruments',
      {},
      (responsePayload) {
        if (responsePayload is List<InstrumentModel>) {
          return responsePayload;
        }
        throw Exception('Unexpected response format for getInstruments');
      },
    );
  }

  @override
  Stream<Level1Update> subscribeLevel1(int instrumentId) {
    if (_level1UpdateControllers.containsKey(instrumentId) &&
        !_level1UpdateControllers[instrumentId]!.isClosed) {
      return _level1UpdateControllers[instrumentId]!.stream;
    }

    final controller =
        StreamController<Level1Update>.broadcast(onCancel: () {});
    _level1UpdateControllers[instrumentId] = controller;

    final payload = {'InstrumentId': instrumentId};

    _sendRequest<bool>('SubscribeLevel1', payload, (responsePayload) {
      if (responsePayload is Map && responsePayload.containsKey('Success')) {
        return responsePayload['Success'] as bool;
      }
      return true;
    }).then((success) {}).catchError((error) {
      if (!controller.isClosed) controller.addError(error.toString());
      _level1UpdateControllers.remove(instrumentId);
    });

    return controller.stream;
  }

  @override
  void unsubscribeLevel1(int instrumentId) {
    final controller = _level1UpdateControllers.remove(instrumentId);
    if (controller != null && !controller.isClosed) {
      controller.close();
    }
  }

  @override
  void dispose() {
    _requestCompleters.forEach((key, completer) {
      if (!completer.isCompleted) {
        completer.completeError(Exception("DataSource disposed"));
      }
    });
    _requestCompleters.clear();
    _level1UpdateControllers.forEach((id, controller) {
      if (!controller.isClosed) controller.close();
    });
    _level1UpdateControllers.clear();
    _messageController.close();
    _channel?.sink.close(status.goingAway);
    _channel = null;
  }
}
