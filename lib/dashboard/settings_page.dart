import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/dashboard/home/compaby_setting_state.dart';
import 'package:requirment_gathering_app/dashboard/home/company_settings_cubit.dart';
import 'package:requirment_gathering_app/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/widget/custom_button.dart';

class CompanySettingPage extends StatelessWidget {
  const CompanySettingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CompanySettingCubit>()..loadSettings(),
      child: BlocBuilder<CompanySettingCubit, CompanySettingState>(
        builder: (context, state) {
          final cubit = context.read<CompanySettingCubit>();

          return Scaffold(
            appBar: const CustomAppBar(
              title: "Company Settings",
              automaticallyImplyLeading: true,
            ),
            body: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSection(
                          title: "Sources",
                          items: state.settings.sources,
                          onAdd: (newSource) =>
                              cubit.addSource(newSource, context),
                          onDelete: (source) => cubit.removeSource(source),
                        ),
                        const SizedBox(height: 16),
                        _buildSection(
                          title: "Priorities",
                          items: state.settings.priorities,
                          onAdd: (newPriority) => cubit.addPriority(
                            newPriority,
                            context,
                          ),
                          onDelete: (priority) =>
                              cubit.removePriority(priority),
                        ),
                        const SizedBox(height: 16),
                        _buildSection(
                          title: "Verified On",
                          items: state.settings.verifiedOn,
                          onAdd: (newPlatform) =>
                              cubit.addVerifiedOn(newPlatform, context),
                          onDelete: (platform) =>
                              cubit.removeVerifiedOn(platform),
                        ),
                        const SizedBox(height: 16),
                        _buildCountrySection(context, cubit, state),
                      ],
                    ),
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
    required Function(String) onDelete,
  }) {
    final TextEditingController controller = TextEditingController();
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: items.map((item) {
                return Chip(
                  label: Text(
                    "${item[0].toUpperCase()}${item.substring(1)}",
                    style: const TextStyle(fontSize: 14),
                  ),
                  onDeleted: () => onDelete(item),
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
                      textCapitalization: TextCapitalization.sentences,
                      controller: controller,
                      decoration: const InputDecoration(
                        labelText: "Add Item",
                        border: OutlineInputBorder(),
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

  Widget _buildCountrySection(BuildContext context, CompanySettingCubit cubit,
      CompanySettingState state) {
    final TextEditingController countryController = TextEditingController();
    final TextEditingController cityController = TextEditingController();

    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Countries & Cities",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...state.settings.countryCityMap.keys.map((country) {
              return ExpansionTile(
                title: Row(
                  children: [
                    Expanded(child: Text(country)),
                    IconButton(
                      icon: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue, // Blue square for Edit
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(
                              4), // Slight rounding for smooth edges
                        ),
                        padding: const EdgeInsets.all(4.0),
                        // Padding inside the square
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white, // White icon
                          size: 24, // Smaller icon size
                        ),
                      ),
                      onPressed: () {
                        final TextEditingController editController =
                            TextEditingController(text: country);
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Edit Country"),
                              content: TextField(
                                controller: editController,
                                decoration: const InputDecoration(
                                    labelText: "New Country Name"),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    if (editController.text.isNotEmpty) {
                                      cubit.editCountry(country,
                                          editController.text, context);
                                      Navigator.of(context).pop();
                                    }
                                  },
                                  child: const Text("Save"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    IconButton(
                      icon: Container(
                        decoration: BoxDecoration(
                          color: Colors.red, // Red square for Delete
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(
                              4), // Slight rounding for smooth edges
                        ),
                        padding: const EdgeInsets.all(4.0),
                        // Padding inside the square
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white, // White icon
                          size: 24, // Smaller icon size
                        ),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Confirm Delete"),
                              content: Text("Delete country '$country'?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    cubit.removeCountry(country);
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("Delete"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8.0,
                      children: state.settings.countryCityMap[country]!
                          .map((city) => Chip(
                                label: Text(city),
                                onDeleted: () =>
                                    cubit.removeCity(country, city),
                              ))
                          .toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: TextField(
                              controller: cityController,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: const InputDecoration(
                                labelText: "Add City",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: CustomButton(
                            horizontalPadding: 8,
                            text: "Add City",
                            isLoading: false,
                            onPressed: () {
                              if (cityController.text.isNotEmpty) {
                                cubit.addCity(
                                  country,
                                  cityController.text,
                                  context,
                                );
                                cityController.clear();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: TextField(
                      controller: countryController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: "Add Country",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: CustomButton(
                    text: "Add Country",
                    horizontalPadding: 8,
                    isLoading: state.isSaving,
                    onPressed: () {
                      if (countryController.text.isNotEmpty) {
                        cubit.addCountry(
                          countryController.text,
                          context,
                        );
                        countryController.clear();
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
}
