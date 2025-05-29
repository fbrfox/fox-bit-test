import 'package:equatable/equatable.dart';

class Level1Update extends Equatable {
  final int instrumentId;
  final double? lastTradedPx;
  final double? rolling24HrVolume;
  final double? rolling24HrPxChange;

  const Level1Update({
    required this.instrumentId,
    this.lastTradedPx,
    this.rolling24HrVolume,
    this.rolling24HrPxChange,
  });

  @override
  List<Object?> get props => [
        instrumentId,
        lastTradedPx,
        rolling24HrVolume,
        rolling24HrPxChange,
      ];
}