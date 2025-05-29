import 'package:flutter/material.dart';
import 'package:foxbit_hiring_test_template/domain/entities/instrument.dart';

class CurrencyListItem extends StatelessWidget {
  final Instrument instrument;

  const CurrencyListItem({super.key, required this.instrument});

  @override
  Widget build(BuildContext context) {
    String formatPrice(double? price) {
      if (price == null) return 'N/A';
      return 'R\$ ${price.toStringAsFixed(2)}';
    }

    String formatVolume(double? volume) {
      if (volume == null) return 'N/A';
      return volume.toStringAsFixed(3);
    }

    String formatChange(double? change) {
      if (change == null) return 'N/A';
      return '${change > 0 ? '+' : ''}${change.toStringAsFixed(2)}%';
    }

    Color changeColor = Colors.grey;
    if (instrument.rolling24HrPxChange != null) {
      if (instrument.rolling24HrPxChange! > 0) {
        changeColor = Colors.green;
      } else if (instrument.rolling24HrPxChange! < 0) {
        changeColor = Colors.red;
      }
    }
    
    final String imagePath = 'assets/images/${instrument.instrumentId}.png';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Image.asset(
              imagePath,
              width: 40,
              height: 40,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.monetization_on_outlined, size: 40); 
              },
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    instrument.symbol.split('/').first,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    instrument.symbol,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatPrice(instrument.lastTradedPx),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    formatChange(instrument.rolling24HrPxChange),
                    style: TextStyle(fontSize: 13, color: changeColor),
                  ),
                ],
              ),
            ),
            if (MediaQuery.of(context).size.width > 380)
                Expanded(
                flex: 2,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                    Text(
                        "Vol:",
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                    Text(
                        formatVolume(instrument.rolling24HrVolume),
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                        textAlign: TextAlign.right,
                    ),
                    ],
                ),
            ),
          ],
        ),
      ),
    );
  }
}