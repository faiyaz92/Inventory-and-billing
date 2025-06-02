import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/taxi/taxi_setting_cubit.dart';
import 'package:requirment_gathering_app/taxi/taxi_setting_model.dart';
import 'package:requirment_gathering_app/taxi/taxi_type_model.dart';

@RoutePage()
class TaxiSettingsPage extends StatefulWidget {


  const TaxiSettingsPage({Key? key,}) : super(key: key);

  @override
  _TaxiSettingsPageState createState() => _TaxiSettingsPageState();
}

class _TaxiSettingsPageState extends State<TaxiSettingsPage> {
  final _taxiTypeController = TextEditingController();
  final _perKmFareController = TextEditingController();
  final _minimumFareController = TextEditingController();
  final _whatsappThresholdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Taxi Settings'),
      body: BlocBuilder<TaxiSettingsCubit, TaxiSettingsState>(
        builder: (context, state) {
          if (state is TaxiSettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TaxiSettingsSuccess) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  const Text('Taxi Types',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _taxiTypeController,
                          decoration:
                              const InputDecoration(labelText: 'Add Taxi Type'),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          if (_taxiTypeController.text.isNotEmpty) {
                            context.read<TaxiSettingsCubit>().addTaxiType(
                                  TaxiType(
                                    id: '',
                                    name: _taxiTypeController.text,
                                    createdAt: DateTime.now(),
                                    createdBy:
                                        'admin', // Replace with actual user
                                  ),
                                );
                            _taxiTypeController.clear();
                          }
                        },
                      ),
                    ],
                  ),
                  ...state.taxiTypes.map((type) => ListTile(
                        title: Text(type.name),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => context
                              .read<TaxiSettingsCubit>()
                              .deleteTaxiType(type.id),
                        ),
                      )),
                  const SizedBox(height: 16),
                  const Text('Fare Settings',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextFormField(
                    controller: _perKmFareController
                      ..text = state.settings.perKmFareRate.toString(),
                    decoration:
                        const InputDecoration(labelText: 'Per KM Fare Rate'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _minimumFareController
                      ..text = state.settings.minimumFare.toString(),
                    decoration:
                        const InputDecoration(labelText: 'Minimum Fare'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _whatsappThresholdController
                      ..text = state.settings.whatsappNotificationFareThreshold
                          .toString(),
                    decoration: const InputDecoration(
                        labelText: 'WhatsApp Notification Threshold'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<TaxiSettingsCubit>().updateSettings(
                            TaxiSettings(
                              perKmFareRate:
                                  double.parse(_perKmFareController.text),
                              minimumFare:
                                  double.parse(_minimumFareController.text),
                              whatsappNotificationFareThreshold: double.parse(
                                  _whatsappThresholdController.text),
                              updatedAt: DateTime.now(),
                              updatedBy: 'admin', // Replace with actual user
                            ),
                          );
                    },
                    child: const Text('Save Settings'),
                  ),
                ],
              ),
            );
          } else if (state is TaxiSettingsError) {
            return Center(child: Text(state.message));
          }
          return Container();
        },
      ),
    );
  }
}
