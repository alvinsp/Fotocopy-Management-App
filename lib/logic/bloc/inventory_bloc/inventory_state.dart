import 'package:fotocopy_app/data/models/inventory_model.dart';

abstract class InventoryState {}

class InventoryInitial extends InventoryState {}

class InventoryLoading extends InventoryState {}

class InventoryLoaded extends InventoryState {
  final List<InventoryModel> items;
  InventoryLoaded(this.items);
}

class InventoryError extends InventoryState {
  final String message;
  InventoryError(this.message);
}
