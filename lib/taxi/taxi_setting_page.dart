import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_button.dart';
import 'package:requirment_gathering_app/core_module/utils/custom_loading_dialog.dart';
import 'package:requirment_gathering_app/taxi/taxi_setting_cubit.dart';
import 'package:requirment_gathering_app/taxi/taxi_setting_model.dart';

@RoutePage()
class TaxiSettingsPage extends StatefulWidget {
  const TaxiSettingsPage({Key? key}) : super(key: key);

  @override
  State<TaxiSettingsPage> createState() => _TaxiSettingsPageState();
}

class _TaxiSettingsPageState extends State<TaxiSettingsPage> {
  @override
  void initState() {
    context.read<TaxiSettingsCubit>().fetchSettings();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: "Taxi Settings",
        automaticallyImplyLeading: true,
      ),
      body: BlocBuilder<TaxiSettingsCubit, TaxiSettingsState>(
        builder: (context, state) {
          final cubit = context.read<TaxiSettingsCubit>();
          if (state.isLoading) {
            return const Center(child: CustomLoadingDialog());
          }
          if (state.errorMessage != null) {
            return Center(child: Text(state.errorMessage!));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFareSettingsSection(context, cubit, state),
                const SizedBox(height: 16),

                _buildSection(
                  title: "Taxi Types",
                  items: state.taxiTypes.map((type) => type.name).toList(),
                  onAdd: (name) => cubit.addTaxiType(name, context),
                  onEdit: (oldName, newName) =>
                      cubit.editTaxiType(oldName, newName, context),
                  onDelete: (name) {
                    final id = state.taxiTypes
                        .firstWhere((type) => type.name == name)
                        .id;
                    cubit.deleteTaxiType(id);
                  },
                  context: context,
                ),
                const SizedBox(height: 16),
                _buildSection(
                  title: "Trip Types",
                  items: state.tripTypes.map((type) => type.name).toList(),
                  onAdd: (name) => cubit.addTripType(name, context),
                  onEdit: (oldName, newName) =>
                      cubit.editTripType(oldName, newName, context),
                  onDelete: (name) {
                    final id = state.tripTypes
                        .firstWhere((type) => type.name == name)
                        .id;
                    cubit.deleteTripType(id);
                  },
                  context: context,
                ),
                const SizedBox(height: 16),
                _buildSection(
                  title: "Service Types",
                  items: state.serviceTypes.map((type) => type.name).toList(),
                  onAdd: (name) => cubit.addServiceType(name, context),
                  onEdit: (oldName, newName) =>
                      cubit.editServiceType(oldName, newName, context),
                  onDelete: (name) {
                    final id = state.serviceTypes
                        .firstWhere((type) => type.name == name)
                        .id;
                    cubit.deleteServiceType(id);
                  },
                  context: context,
                ),
                const SizedBox(height: 16),
                _buildSection(
                  title: "Trip Statuses",
                  items:
                      state.tripStatuses.map((status) => status.name).toList(),
                  onAdd: (name) => cubit.addTripStatus(name, context),
                  onEdit: (oldName, newName) =>
                      cubit.editTripStatus(oldName, newName, context),
                  onDelete: (name) {
                    final id = state.tripStatuses
                        .firstWhere((status) => status.name == name)
                        .id;
                    cubit.deleteTripStatus(id);
                  },
                  context: context,
                ),
                              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<String> items,
    required Function(String) onAdd,
    required Function(String, String) onEdit,
    required Function(String) onDelete,
    required BuildContext context,
  }) {
    final controller = TextEditingController();
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: items.map((item) {
                return Chip(
                  label: Text("${item[0].toUpperCase()}${item.substring(1)}"),
                  onDeleted: () =>
                      _showDeleteDialog(context, item, title, onDelete),
                  deleteIcon: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.all(4.0),
                    child:
                        const Icon(Icons.delete, color: Colors.white, size: 16),
                  ),
                  deleteButtonTooltipMessage: "Delete $item",
                  side: BorderSide.none,
                  backgroundColor:
                      Theme.of(context).colorScheme.primary.withOpacity(0.1),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: TextField(
                      controller: controller,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        labelText: "Add $title",
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: CustomButton(
                    text: "Add",
                    horizontalPadding: 16.0,
                    isLoading: false,
                    onPressed: () {
                      if (controller.text.isNotEmpty) {
                        onAdd(controller.text);
                        controller.clear();
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFareSettingsSection(
      BuildContext context, TaxiSettingsCubit cubit, TaxiSettingsState state) {
    final perKmFareController =
        TextEditingController(text: state.settings.perKmFareRate.toString());
    final minimumFareController =
        TextEditingController(text: state.settings.minimumFare.toString());
    final whatsappThresholdController = TextEditingController(
        text: state.settings.whatsappNotificationFareThreshold.toString());

    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Fare Settings",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: perKmFareController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Per KM Fare Rate",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: minimumFareController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Minimum Fare",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: whatsappThresholdController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "WhatsApp Notification Threshold",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 80,
                child: CustomButton(
                  text: "Save",
                  isLoading: state.isSaving,
                  onPressed: () {
                    try {
                      final settings = TaxiSettings(
                        perKmFareRate: double.parse(perKmFareController.text),
                        minimumFare: double.parse(minimumFareController.text),
                        whatsappNotificationFareThreshold:
                            double.parse(whatsappThresholdController.text),
                        updatedAt: DateTime.now(),
                        updatedBy: 'admin',
                        taxiTypes: state.taxiTypes,
                        tripTypes: state.tripTypes,
                        serviceTypes: state.serviceTypes,
                        tripStatuses: state.tripStatuses, // Replace with actual user
                      );
                      cubit.updateSettings(settings, context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Invalid input: $e")),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String item, String title,
      Function(String) onDelete) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: Text(
              "Delete ${title.toLowerCase().substring(0, title.length - 1)} '$item'?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                onDelete(item);
                Navigator.of(context).pop();
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}
