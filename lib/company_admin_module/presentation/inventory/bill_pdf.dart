import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';

@RoutePage()
class BillPdfPage extends StatelessWidget {
  final pw.Document pdf;
  final String billNumber;

  const BillPdfPage({
    super.key,
    required this.pdf,
    required this.billNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Bill: $billNumber',
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: AppColors.primary),
            onPressed: () async {
              try {
                await Printing.sharePdf(
                  bytes: await pdf.save(),
                  filename: 'bill_$billNumber.pdf',
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to share PDF: $e')),
                );
              }
            },
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) => pdf.save(),
        allowPrinting: true,
        allowSharing: false,
        // Share handled via app bar action
        canChangePageFormat: false,
        canDebug: false,
        pdfFileName: 'bill_$billNumber.pdf',
      ),
    );
  }
}
