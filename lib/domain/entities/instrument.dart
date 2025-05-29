import 'package:equatable/equatable.dart';

class Instrument extends Equatable {
  final int instrumentId;
  final String symbol;
  final int sortIndex;
  double? lastTradedPx;
  double? rolling24HrVolume;
  double? rolling24HrPxChange;

  Instrument({
    required this.instrumentId,
    required this.symbol,
    required this.sortIndex,
    this.lastTradedPx,
    this.rolling24HrVolume,
    this.rolling24HrPxChange,
  });

  Instrument copyWith({
    double? lastTradedPx,
    double? rolling24HrVolume,
    double? rolling24HrPxChange,
  }) {
    return Instrument(
      instrumentId: instrumentId,
      symbol: symbol,
      sortIndex: sortIndex,
      lastTradedPx: lastTradedPx ?? this.lastTradedPx,
      rolling24HrVolume: rolling24HrVolume ?? this.rolling24HrVolume,
      rolling24HrPxChange: rolling24HrPxChange ?? this.rolling24HrPxChange,
    );
  }

  @override
  List<Object?> get props => [
        instrumentId,
        symbol,
        sortIndex,
        lastTradedPx,
        rolling24HrVolume,
        rolling24HrPxChange,
      ];
}