import 'package:flutter/material.dart';

class BillingPage extends StatelessWidget {
  const BillingPage({Key? key}) : super(key: key);

  // @override
  // _BillingPageState createState() => _BillingPageState();
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

// class _BillingPageState extends State<BillingPage> {
//   final _formKey = GlobalKey<FormState>();
//   late BillingCubit _billingCubit;
//   late StockService _stockService;
//   late ProductService _productService;
//   late PartnerService _partnerService;
//   List<StoreDto> _stores = [];
//   List<StockModel> _availableStock = [];
//   List<Partner> _customers = [];
//   Map<String, String> _customerNames = {};
//
//   @override
//   void initState() {
//     super.initState();
//     _billingCubit = sl<BillingCubit>();
//     _stockService = sl<StockService>();
//     _productService = sl<ProductService>();
//     _partnerService = sl<PartnerService>();
//     _loadInitialData();
//   }
//
//   Future<void> _loadInitialData() async {
//     try {
//       _stores = await _stockService.getStores();
//       _customers = await _partnerService.getCompanies();
//       _customerNames = {for (var customer in _customers) customer.id: customer.companyName};
//       setState(() {});
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to load data: $e'), backgroundColor: AppColors.red),
//       );
//     }
//   }
//
//   Future<void> _loadStock(String storeId) async {
//     try {
//       _availableStock = await _stockService.getStock(storeId);
//       _availableStock = _availableStock.where((stock) => stock.quantity > 0).toList();
//       setState(() {});
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to load stock: $e'), backgroundColor: AppColors.red),
//       );
//     }
//   }
//
//   Future<void> _generateAndSharePDF(BillingState state) async {
//     final pdf = pw.Document();
//     final customerName = _customerNames[state.selectedCustomerId] ?? 'Unknown Customer';
//     pdf.addPage(
//       pw.Page(
//         build: (pw.Context context) => pw.Column(
//           crossAxisAlignment: pw.CrossAxisAlignment.start,
//           children: [
//             pw.Text('Bill Invoice', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
//             pw.Divider(),
//             pw.Text('Customer: $customerName'),
//             pw.Text('Date: May 15, 2025'),
//             pw.Text('Store: ${state.selectedStoreId}'),
//             pw.SizedBox(height: 20),
//             pw.Table.fromTextArray(
//               headers: ['Product Name', 'Quantity', 'Price per Unit', 'Total Price'],
//               data: state.items.map((item) {
//                 return [
//                   item.product.name,
//                   item.quantity.toString(),
//                   '₹${item.product.price}',
//                   '₹${item.totalPrice}',
//                 ];
//               }).toList(),
//             ),
//             pw.SizedBox(height: 20),
//             pw.Text('Subtotal: ₹${state.subtotal.toStringAsFixed(2)}'),
//             pw.Text('Tax (${state.taxPercentage}%): ₹${state.taxAmount.toStringAsFixed(2)}'),
//             pw.Text('Grand Total: ₹${state.grandTotal.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
//           ],
//         ),
//       ),
//     );
//
//     final outputDir = await getTemporaryDirectory();
//     final file = File("${outputDir.path}/bill_${DateTime.now().millisecondsSinceEpoch}.pdf");
//     await file.writeAsBytes(await pdf.save());
//
//     await Share.shareXFiles([XFile(file.path)], text: 'Here is your bill');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => _billingCubit,
//       child: Scaffold(
//         appBar: const CustomAppBar(title: 'Billing'),
//         body: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Form(
//             key: _formKey,
//             child: BlocConsumer<BillingCubit, BillingState>(
//               listener: (context, state) {
//                 if (state.error != null) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text(state.error!), backgroundColor: AppColors.red),
//                   );
//                 }
//                 if (state.isBillGenerated) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Bill created successfully')),
//                   );
//                 }
//               },
//               builder: (context, state) {
//                 if (state.isLoading) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//
//                 final customerName = _customerNames[state.selectedCustomerId] ?? 'Select Customer';
//
//                 return SingleChildScrollView(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Store Selection
//                       CustomDropdown(
//                         labelText: 'Store',
//                         selectedValue: state.selectedStoreId,
//                         items: _stores.map((store) => store.storeId).toList(),
//                         onChanged: (value) {
//                           context.read<BillingCubit>().selectStore(value!);
//                           _loadStock(value);
//                         },
//                         validator: (value) => value == null ? 'Please select a store' : null,
//                       ),
//                       const SizedBox(height: 16),
//                       // Customer Selection
//                       CustomDropdown(
//                         labelText: 'Customer',
//                         selectedValue: state.selectedCustomerId,
//                         items: _customers.map((customer) => customer.id).toList(),
//                         onChanged: (value) => context.read<BillingCubit>().selectCustomer(value!),
//                         validator: (value) => value == null ? 'Please select a customer' : null,
//                       ),
//                       const SizedBox(height: 16),
//                       Text('Customer: $customerName', style: const TextStyle(fontSize: 16)),
//                       const SizedBox(height: 16),
//                       // Add Product Dropdown
//                       if (state.selectedStoreId != null)
//                         CustomDropdown(
//                           labelText: 'Add Product',
//                           selectedValue: null,
//                           items: _availableStock.map((stock) => stock.productId).toList(),
//                           onChanged: (value) {
//                             final stock = _availableStock.firstWhere((s) => s.productId == value);
//                             context.read<BillingCubit>().addItem(stock);
//                           },
//                           hint: 'Select a product to add',
//                         ),
//                       const SizedBox(height: 16),
//                       // Products Table
//                       if (state.items.isNotEmpty)
//                         Table(
//                           border: TableBorder.all(),
//                           children: [
//                             TableRow(
//                               children: [
//                                 const Padding(
//                                   padding: EdgeInsets.all(8.0),
//                                   child: Text('Product', style: TextStyle(fontWeight: FontWeight.bold)),
//                                 ),
//                                 const Padding(
//                                   padding: EdgeInsets.all(8.0),
//                                   child: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold)),
//                                 ),
//                                 const Padding(
//                                   padding: EdgeInsets.all(8.0),
//                                   child: Text('Price', style: TextStyle(fontWeight: FontWeight.bold)),
//                                 ),
//                                 const Padding(
//                                   padding: EdgeInsets.all(8.0),
//                                   child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
//                                 ),
//                               ],
//                             ),
//                             ...state.items.asMap().entries.map((entry) {
//                               final index = entry.key;
//                               final item = entry.value;
//                               return TableRow(
//                                 children: [
//                                   Padding(
//                                     padding: const EdgeInsets.all(8.0),
//                                     child: Text(item.product.name),
//                                   ),
//                                   Padding(
//                                     padding: const EdgeInsets.all(8.0),
//                                     child: Row(
//                                       children: [
//                                         IconButton(
//                                           icon: const Icon(Icons.remove),
//                                           onPressed: () => context.read<BillingCubit>().updateQuantity(index, item.quantity - 1),
//                                         ),
//                                         SizedBox(
//                                           width: 50,
//                                           child: TextFormField(
//                                             initialValue: item.quantity.toString(),
//                                             keyboardType: TextInputType.number,
//                                             textAlign: TextAlign.center,
//                                             onChanged: (value) {
//                                               final newQty = int.tryParse(value) ?? 1;
//                                               context.read<BillingCubit>().updateQuantity(index, newQty);
//                                             },
//                                           ),
//                                         ),
//                                         IconButton(
//                                           icon: const Icon(Icons.add),
//                                           onPressed: () => context.read<BillingCubit>().updateQuantity(index, item.quantity + 1),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   Padding(
//                                     padding: const EdgeInsets.all(8.0),
//                                     child: Text('₹${item.product.price}'),
//                                   ),
//                                   Padding(
//                                     padding: const EdgeInsets.all(8.0),
//                                     child: Text('₹${item.totalPrice}'),
//                                   ),
//                                 ],
//                               );
//                             }),
//                           ],
//                         ),
//                       const SizedBox(height: 16),
//                       // Totals and Tax
//                       if (state.items.isNotEmpty) ...[
//                         Text('Subtotal: ₹${state.subtotal.toStringAsFixed(2)}'),
//                         const SizedBox(height: 8),
//                         CustomDropdown(
//                           labelText: 'Tax Percentage',
//                           selectedValue: state.taxPercentage.toString(),
//                           items: ['5.0', '10.0', '15.0'],
//                           onChanged: (value) => context.read<BillingCubit>().setTaxPercentage(double.parse(value!)),
//                         ),
//                         const SizedBox(height: 8),
//                         Text('Tax (${state.taxPercentage}%): ₹${state.taxAmount.toStringAsFixed(2)}'),
//                         const SizedBox(height: 8),
//                         Text(
//                           'Grand Total: ₹${state.grandTotal.toStringAsFixed(2)}',
//                           style: const TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 16),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           children: [
//                             ElevatedButton(
//                               onPressed: () => context.read<BillingCubit>().createBill(),
//                               child: const Text('Create Bill'),
//                             ),
//                             if (state.isBillGenerated)
//                               ElevatedButton(
//                                 onPressed: () => _generateAndSharePDF(state),
//                                 child: const Text('Share PDF'),
//                               ),
//                           ],
//                         ),
//                       ],
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }