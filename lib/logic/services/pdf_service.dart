import 'package:fotocopy_app/data/models/oder_model.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static Future<void> generateReport(
      List<OrderModel> orders, DateTime date, int total) async {
    await initializeDateFormatting('id_ID', null);
    final pdf = pw.Document();
    final dateStr = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                  level: 0, child: pw.Text("Laporan Harian Toko Fotocopy")),
              pw.Text("Tanggal: $dateStr"),
              pw.SizedBox(height: 20),

              // Tabel Transaksi
              pw.TableHelper.fromTextArray(
                headers: ['Nama Pelanggan', 'Kategori', 'Status', 'Harga'],
                data: orders
                    .map((o) => [
                          o.namaPelanggan,
                          o.kategori,
                          o.status,
                          "Rp ${o.totalHarga}"
                        ])
                    .toList(),
              ),

              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text("Total Omzet: Rp $total",
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 18)),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }
}
