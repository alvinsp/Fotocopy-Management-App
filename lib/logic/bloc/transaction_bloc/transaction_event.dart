import 'package:fotocopy_app/data/models/oder_model.dart';

abstract class TransactionEvent {}

class WatchOrders extends TransactionEvent {}

class OrdersUpdated extends TransactionEvent {
  final List<OrderModel> orders;
  OrdersUpdated(this.orders);
}

class UpdateStatus extends TransactionEvent {
  final String orderId;
  final String newStatus;
  UpdateStatus(this.orderId, this.newStatus);
}

class AddOrderRequested extends TransactionEvent {
  final String nama;
  final int harga;
  final String kategori;
  AddOrderRequested(this.nama, this.harga, this.kategori);
}

class DeleteOrderRequested extends TransactionEvent {
  final String orderId;
  DeleteOrderRequested(this.orderId);
}

class ChangeDateRequested extends TransactionEvent {
  final DateTime selectedDate;
  ChangeDateRequested(this.selectedDate);
}

class SearchNameRequested extends TransactionEvent {
  final String query;
  SearchNameRequested(this.query);
}
