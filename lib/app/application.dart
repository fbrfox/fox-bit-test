import 'package:flutter/material.dart';
import 'package:foxbit_hiring_test_template/app/pages/currency_list/currency_list_page.dart';

class FoxbitApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foxbit Test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: Colors.white),
      home: const CurrencyListPage(),
    );
  }
}
