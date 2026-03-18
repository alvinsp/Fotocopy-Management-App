import 'package:fotocopy_app/data/models/oder_model.dart';

abstract class TransactionState {}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionError extends TransactionState {
  final String message;

  TransactionError(this.message);
}

class TransactionLoaded extends TransactionState {
  final List<OrderModel> orders;
  final DateTime selectedDate;
  final String searchQuery;
  TransactionLoaded(this.orders, this.selectedDate, {this.searchQuery = ''});
}
