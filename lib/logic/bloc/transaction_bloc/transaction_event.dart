import 'package:fotocopy_app/data/models/oder_model.dart';

abstract class TransactionEvent {}

class LoadTransactions extends TransactionEvent {}

class UpdateTransactionList extends TransactionEvent {
  final List<OrderModel> orders;
  UpdateTransactionList(this.orders);
}

class SearchNameRequested extends TransactionEvent {
  final String query;
  SearchNameRequested(this.query);
}

class ClearTransactionData extends TransactionEvent {}

class AddOrderRequested extends TransactionEvent {
  final String nama;
  final int harga;
  final String kategori;
  final bool isLunas;
  AddOrderRequested(this.nama, this.harga, this.kategori, this.isLunas);
}

class ChangeDateRequested extends TransactionEvent {
  final DateTime selectedDate;
  ChangeDateRequested(this.selectedDate);
}

class DeleteOrderRequested extends TransactionEvent {
  final String orderId;
  DeleteOrderRequested(this.orderId);
}

class UpdateStatus extends TransactionEvent {
  final String orderId;
  final String newStatus;

  UpdateStatus(this.orderId, this.newStatus);
}

class LoadDebtRequested extends TransactionEvent {}

class MarkAsPaidRequested extends TransactionEvent {
  final String transactionId;
  MarkAsPaidRequested(this.transactionId);
}
