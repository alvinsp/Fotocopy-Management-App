import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fotocopy_app/data/repositories/inventory_repository.dart';
import 'package:fotocopy_app/logic/bloc/inventory_bloc/inventory_event.dart';

import 'inventory_state.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final InventoryRepository _repository;
  StreamSubscription? _inventorySubscription;

  InventoryBloc(this._repository) : super(InventoryInitial()) {
    on<LoadInventory>((event, emit) async {
      emit(InventoryLoading());
      await _inventorySubscription?.cancel();
      _inventorySubscription = null;

      _inventorySubscription = _repository.watchInventory().listen(
        (items) {
          if (!isClosed) {
            add(InventoryUpdated(items));
          }
        },
        onError: (e) {
          if (!isClosed) emit(InventoryError(e.toString()));
        },
      );
    });

    on<InventoryUpdated>((event, emit) {
      emit(InventoryLoaded(event.items));
    });

    on<UpdateStokRequested>((event, emit) async {
      try {
        await FirebaseFirestore.instance
            .collection('inventory')
            .doc(event.id)
            .update({
          'stok': event.jumlahBaru,
        });
        // Tidak perlu emit state baru karena stream watchInventory()
        // akan otomatis mendeteksi perubahan dan mengupdate UI.
      } catch (e) {
        print("Gagal update stok: $e");
      }
    });

    on<ClearInventoryData>((event, emit) async {
      await _inventorySubscription?.cancel();
      _inventorySubscription = null;
      emit(InventoryInitial());
    });

    on<DeleteInventoryItem>((event, emit) async {
      try {
        await FirebaseFirestore.instance
            .collection('inventory')
            .doc(event.id)
            .delete();
      } catch (e) {
        print("Gagal menghapus: $e");
      }
    });
  }

  @override
  Future<void> close() {
    _inventorySubscription?.cancel();
    return super.close();
  }
}
