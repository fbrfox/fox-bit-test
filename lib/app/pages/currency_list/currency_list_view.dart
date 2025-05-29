import 'package:flutter/material.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart'
    as fca;
import 'package:foxbit_hiring_test_template/app/pages/currency_list/currency_list_controller.dart';
import 'package:foxbit_hiring_test_template/app/pages/currency_list/widgets/currency_list_item.dart';
import 'package:foxbit_hiring_test_template/data/data_sources/websocket_data_source.dart';
import 'package:foxbit_hiring_test_template/data/repositories/instrument_repository_impl.dart';
import 'package:foxbit_hiring_test_template/domain/entities/instrument.dart';
import 'package:foxbit_hiring_test_template/domain/usecases/get_instruments_use_case.dart';
import 'package:foxbit_hiring_test_template/domain/usecases/subscribe_level1_use_case.dart';

class CurrencyListView extends fca.View {
  const CurrencyListView({super.key});

  @override
  CurrencyListViewState createState() => CurrencyListViewState();
}

class CurrencyListViewState
    extends fca.ViewState<CurrencyListView, CurrencyListController> {
  CurrencyListViewState()
      : super(CurrencyListController(
            GetInstrumentsUseCase(
                InstrumentRepositoryImpl(WebSocketDataSourceImpl())),
            SubscribeLevel1UseCase(
                InstrumentRepositoryImpl(WebSocketDataSourceImpl()))));

  @override
  Widget get view => Scaffold(
        appBar: AppBar(
          title: const Text("Cotações de Moedas"),
        ),
        body: fca.ControlledWidgetBuilder<CurrencyListController>(
          builder: (context, controller) {
            if (controller.isLoading && controller.instruments == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.errorMessage != null &&
                controller.instruments == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(controller.errorMessage!),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: controller.retryLoadInstruments,
                      child: const Text("Tentar Novamente"),
                    ),
                  ],
                ),
              );
            }

            if (controller.instruments == null ||
                controller.instruments!.isEmpty) {
              return const Center(child: Text("Nenhuma moeda para exibir."));
            }

            return ListView.builder(
              itemCount: controller.instruments!.length,
              itemBuilder: (context, index) {
                final Instrument instrument = controller.instruments![index];
                return CurrencyListItem(instrument: instrument);
              },
            );
          },
        ),
      );
}
