import 'package:fotocopy_app/data/models/inventory_model.dart';

abstract class InventoryEvent {}

class LoadInventory extends InventoryEvent {}

class InventoryUpdated extends InventoryEvent {
  final List<InventoryModel> items;
  InventoryUpdated(this.items);
}

class ClearInventoryData extends InventoryEvent {}

class UpdateStokRequested extends InventoryEvent {
  final String id;
  final int jumlahBaru;
  UpdateStokRequested(this.id, this.jumlahBaru);
}

class DeleteInventoryItem extends InventoryEvent {
  final String id;
  DeleteInventoryItem(this.id);
}
