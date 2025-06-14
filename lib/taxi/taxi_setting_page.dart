import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  String _uiVersion = 'v2'; // Default to new UI

  @override
  void initState() {
    context.read<TaxiSettingsCubit>().fetchSettings();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Taxi Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF121212),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButton<String>(
              value: _uiVersion,
              dropdownColor: const Color(0xFF121212),
              style: const TextStyle(color: Colors.white),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'v1', child: Text('Version 1')),
                DropdownMenuItem(value: 'v2', child: Text('Version 2')),
                DropdownMenuItem(value: 'v3', child: Text('Version 3')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _uiVersion = value;
                  });
                }
              },
            ),
          ),
        ],
      ),
      body: _uiVersion == 'v1'
          ? _buildV1(context)
          : _uiVersion == 'v2'
              ? _buildV2(context)
              : _buildV3(context),
    );
  }

  Widget _buildV1(BuildContext context) {
    return BlocBuilder<TaxiSettingsCubit, TaxiSettingsState>(
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
              _buildFareSettingsSectionV1(context, cubit, state),
              const SizedBox(height: 16),
              _buildSectionV1(
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
              _buildSectionV1(
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
              _buildSectionV1(
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
              _buildSectionV1(
                title: "Trip Statuses",
                items: state.tripStatuses.map((status) => status.name).toList(),
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
    );
  }

  Widget _buildSectionV1({
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
                      _showDeleteDialogV1(context, item, title, onDelete),
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

  Widget _buildFareSettingsSectionV1(
      BuildContext context, TaxiSettingsCubit cubit, TaxiSettingsState state) {
    final perKmFareController =
        TextEditingController(text: state.settings.perKmFareRate.toString());
    final minimumFareController =
        TextEditingController(text: state.settings.minimumFare.toString());
    final whatsappThresholdController = TextEditingController(
        text: state.settings.whatsappNotificationFareThreshold.toString());
    final mapApiKeyController =
        TextEditingController(text: state.settings.mapApiKey ?? '');
    final twilioAccountSidController =
        TextEditingController(text: state.settings.twilioAccountSid ?? '');
    final twilioAuthTokenController =
        TextEditingController(text: state.settings.twilioAuthToken ?? '');
    final twilioWhatsAppNumberController =
        TextEditingController(text: state.settings.twilioWhatsAppNumber ?? '');

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
            const SizedBox(height: 8),
            TextField(
              controller: mapApiKeyController,
              decoration: const InputDecoration(
                labelText: "Map API Key",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: twilioAccountSidController,
              decoration: const InputDecoration(
                labelText: "Twilio Account SID",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: twilioAuthTokenController,
              decoration: const InputDecoration(
                labelText: "Twilio Auth Token",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: twilioWhatsAppNumberController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Twilio WhatsApp Number",
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
                        mapApiKey: mapApiKeyController.text.isEmpty
                            ? null
                            : mapApiKeyController.text,
                        twilioAccountSid:
                            twilioAccountSidController.text.isEmpty
                                ? null
                                : twilioAccountSidController.text,
                        twilioAuthToken: twilioAuthTokenController.text.isEmpty
                            ? null
                            : twilioAuthTokenController.text,
                        twilioWhatsAppNumber:
                            twilioWhatsAppNumberController.text.isEmpty
                                ? null
                                : twilioWhatsAppNumberController.text,
                        updatedAt: DateTime.now(),
                        updatedBy: 'admin',
                        taxiTypes: state.taxiTypes,
                        tripTypes: state.tripTypes,
                        serviceTypes: state.serviceTypes,
                        tripStatuses: state.tripStatuses,
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

  void _showDeleteDialogV1(BuildContext context, String item, String title,
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

  Widget _buildV2(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1E1E2D), Color(0xFF2A2A3E)],
        ),
      ),
      child: BlocBuilder<TaxiSettingsCubit, TaxiSettingsState>(
        builder: (context, state) {
          final cubit = context.read<TaxiSettingsCubit>();
          if (state.isLoading) {
            return const Center(child: CustomLoadingDialog());
          }
          if (state.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.errorMessage!,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => cubit.fetchSettings(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    child: const Text(
                      'Retry',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFareSettingsSectionV2(context, cubit, state),
                const SizedBox(height: 16),
                _buildSectionV2(
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
                _buildSectionV2(
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
                _buildSectionV2(
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
                _buildSectionV2(
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

  Widget _buildSectionV2({
    required String title,
    required List<String> items,
    required Function(String) onAdd,
    required Function(String, String) onEdit,
    required Function(String) onDelete,
    required BuildContext context,
  }) {
    final controller = TextEditingController();
    return Card(
      elevation: 0,
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: items.map((item) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: Chip(
                    label: Text(
                      "${item[0].toUpperCase()}${item.substring(1)}",
                      style: const TextStyle(color: Colors.black),
                    ),
                    onDeleted: () =>
                        _showDeleteDialogV2(context, item, title, onDelete),
                    deleteIcon: Container(
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4.0),
                      child: const Icon(Icons.close,
                          color: Colors.white, size: 16),
                    ),
                    deleteButtonTooltipMessage: "Delete $item",
                    backgroundColor: Colors.white.withOpacity(0.15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.white.withOpacity(0.4)),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: TextField(
                      controller: controller,
                      textCapitalization: TextCapitalization.sentences,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Add $title",
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.white.withOpacity(0.2)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.white.withOpacity(0.2)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFFFD700)),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: () {
                      if (controller.text.isNotEmpty) {
                        onAdd(controller.text);
                        controller.clear();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Add',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFareSettingsSectionV2(
      BuildContext context, TaxiSettingsCubit cubit, TaxiSettingsState state) {
    final perKmFareController =
        TextEditingController(text: state.settings.perKmFareRate.toString());
    final minimumFareController =
        TextEditingController(text: state.settings.minimumFare.toString());
    final whatsappThresholdController = TextEditingController(
        text: state.settings.whatsappNotificationFareThreshold.toString());
    final mapApiKeyController =
        TextEditingController(text: state.settings.mapApiKey ?? '');
    final twilioAccountSidController =
        TextEditingController(text: state.settings.twilioAccountSid ?? '');
    final twilioAuthTokenController =
        TextEditingController(text: state.settings.twilioAuthToken ?? '');
    final twilioWhatsAppNumberController =
        TextEditingController(text: state.settings.twilioWhatsAppNumber ?? '');

    return Card(
      elevation: 0,
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Fare Settings",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: perKmFareController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Per KM Fare Rate",
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFFD700)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: minimumFareController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Minimum Fare",
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFFD700)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: whatsappThresholdController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "WhatsApp Notification Threshold",
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFFD700)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: mapApiKeyController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Map API Key",
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFFD700)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: twilioAccountSidController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Twilio Account SID",
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFFD700)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: twilioAuthTokenController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Twilio Auth Token",
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFFD700)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: twilioWhatsAppNumberController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Twilio WhatsApp Number",
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFFD700)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  try {
                    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
                    if (twilioWhatsAppNumberController.text.isNotEmpty &&
                        !phoneRegex
                            .hasMatch(twilioWhatsAppNumberController.text)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                              "Invalid Twilio WhatsApp number format"),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                      return;
                    }
                    final settings = TaxiSettings(
                      perKmFareRate: double.parse(perKmFareController.text),
                      minimumFare: double.parse(minimumFareController.text),
                      whatsappNotificationFareThreshold:
                          double.parse(whatsappThresholdController.text),
                      mapApiKey: mapApiKeyController.text.isEmpty
                          ? null
                          : mapApiKeyController.text,
                      twilioAccountSid: twilioAccountSidController.text.isEmpty
                          ? null
                          : twilioAccountSidController.text,
                      twilioAuthToken: twilioAuthTokenController.text.isEmpty
                          ? null
                          : twilioAuthTokenController.text,
                      twilioWhatsAppNumber:
                          twilioWhatsAppNumberController.text.isEmpty
                              ? null
                              : twilioWhatsAppNumberController.text,
                      updatedAt: DateTime.now(),
                      updatedBy: 'admin',
                      taxiTypes: state.taxiTypes,
                      tripTypes: state.tripTypes,
                      serviceTypes: state.serviceTypes,
                      tripStatuses: state.tripStatuses,
                    );
                    cubit.updateSettings(settings, context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Invalid input: $e"),
                        backgroundColor: Colors.redAccent,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: state.isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Text(
                        'Save',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialogV2(BuildContext context, String item, String title,
      Function(String) onDelete) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E2D),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Confirm Delete',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          content: Text(
            "Delete ${title.toLowerCase().substring(0, title.length - 1)} '$item'?",
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () {
                onDelete(item);
                Navigator.of(context).pop();
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildV3(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF121212),
      ),
      child: BlocBuilder<TaxiSettingsCubit, TaxiSettingsState>(
        builder: (context, state) {
          final cubit = context.read<TaxiSettingsCubit>();
          if (state.isLoading) {
            return const Center(child: CustomLoadingDialog());
          }
          if (state.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.errorMessage!,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => cubit.fetchSettings(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF26A69A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    child: const Text(
                      'Retry',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFareSettingsSectionV3(context, cubit, state),
                const SizedBox(height: 16),
                _buildSectionV3(
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
                _buildSectionV3(
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
                _buildSectionV3(
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
                _buildSectionV3(
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

  Widget _buildSectionV3({
    required String title,
    required List<String> items,
    required Function(String) onAdd,
    required Function(String, String) onEdit,
    required Function(String) onDelete,
    required BuildContext context,
  }) {
    final controller = TextEditingController();
    return Card(
      elevation: 0,
      color: Colors.white.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          color: Colors.white.withOpacity(0.05),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: items.map((item) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Chip(
                    label: Text(
                      "${item[0].toUpperCase()}${item.substring(1)}",
                      style: const TextStyle(color: Colors.white),
                    ),
                    onDeleted: () =>
                        _showDeleteDialogV3(context, item, title, onDelete),
                    deleteIcon: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFE57373),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4.0),
                      child: const Icon(Icons.close,
                          color: Colors.white, size: 16),
                    ),
                    deleteButtonTooltipMessage: "Delete $item",
                    backgroundColor: const Color(0xFF26A69A).withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: TextField(
                      controller: controller,
                      textCapitalization: TextCapitalization.sentences,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Add $title",
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.white.withOpacity(0.1)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.white.withOpacity(0.1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFF26A69A)),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFE57373)),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: () {
                      if (controller.text.isNotEmpty) {
                        onAdd(controller.text);
                        controller.clear();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text("Please enter a value"),
                            backgroundColor: const Color(0xFFE57373),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF26A69A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Add',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFareSettingsSectionV3(
      BuildContext context, TaxiSettingsCubit cubit, TaxiSettingsState state) {
    final perKmFareController =
        TextEditingController(text: state.settings.perKmFareRate.toString());
    final minimumFareController =
        TextEditingController(text: state.settings.minimumFare.toString());
    final whatsappThresholdController = TextEditingController(
        text: state.settings.whatsappNotificationFareThreshold.toString());
    final mapApiKeyController =
        TextEditingController(text: state.settings.mapApiKey ?? '');
    final twilioAccountSidController =
        TextEditingController(text: state.settings.twilioAccountSid ?? '');
    final twilioAuthTokenController =
        TextEditingController(text: state.settings.twilioAuthToken ?? '');
    final twilioWhatsAppNumberController =
        TextEditingController(text: state.settings.twilioWhatsAppNumber ?? '');

    return Card(
      elevation: 0,
      color: Colors.white.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          color: Colors.white.withOpacity(0.05),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Fare Settings",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: perKmFareController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Per KM Fare Rate",
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF26A69A)),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE57373)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: minimumFareController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Minimum Fare",
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF26A69A)),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE57373)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: whatsappThresholdController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "WhatsApp Notification Threshold",
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF26A69A)),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE57373)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: mapApiKeyController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Map API Key",
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF26A69A)),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE57373)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: twilioAccountSidController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Twilio Account SID",
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF26A69A)),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE57373)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: twilioAuthTokenController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Twilio Auth Token",
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF26A69A)),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE57373)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: twilioWhatsAppNumberController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Twilio WhatsApp Number",
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF26A69A)),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE57373)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  try {
                    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
                    if (twilioWhatsAppNumberController.text.isNotEmpty &&
                        !phoneRegex
                            .hasMatch(twilioWhatsAppNumberController.text)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                              "Invalid Twilio WhatsApp number format"),
                          backgroundColor: const Color(0xFFE57373),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                      return;
                    }
                    final settings = TaxiSettings(
                      perKmFareRate: double.parse(perKmFareController.text),
                      minimumFare: double.parse(minimumFareController.text),
                      whatsappNotificationFareThreshold:
                          double.parse(whatsappThresholdController.text),
                      mapApiKey: mapApiKeyController.text.isEmpty
                          ? null
                          : mapApiKeyController.text,
                      twilioAccountSid: twilioAccountSidController.text.isEmpty
                          ? null
                          : twilioAccountSidController.text,
                      twilioAuthToken: twilioAuthTokenController.text.isEmpty
                          ? null
                          : twilioAuthTokenController.text,
                      twilioWhatsAppNumber:
                          twilioWhatsAppNumberController.text.isEmpty
                              ? null
                              : twilioWhatsAppNumberController.text,
                      updatedAt: DateTime.now(),
                      updatedBy: 'admin',
                      taxiTypes: state.taxiTypes,
                      tripTypes: state.tripTypes,
                      serviceTypes: state.serviceTypes,
                      tripStatuses: state.tripStatuses,
                    );
                    cubit.updateSettings(settings, context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Invalid input: $e"),
                        backgroundColor: const Color(0xFFE57373),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF26A69A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  elevation: 2,
                ),
                child: state.isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Save',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialogV3(BuildContext context, String item, String title,
      Function(String) onDelete) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF121212),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Confirm Delete',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          content: Text(
            "Delete ${title.toLowerCase().substring(0, title.length - 1)} '$item'?",
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () {
                onDelete(item);
                Navigator.of(context).pop();
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Color(0xFFE57373)),
              ),
            ),
          ],
        );
      },
    );
  }
}
