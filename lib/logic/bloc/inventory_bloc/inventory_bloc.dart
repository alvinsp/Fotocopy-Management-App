import 'dart:async';

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

      _inventorySubscription = _repository.watchInventory().listen(
            (items) => add(InventoryUpdated(items)),
            onError: (e) => emit(InventoryError(e.toString())),
          );
    });

    on<InventoryUpdated>((event, emit) {
      emit(InventoryLoaded(event.items));
    });

    on<ClearInventoryData>((event, emit) async {
      await _inventorySubscription?.cancel();
      _inventorySubscription = null;
      emit(InventoryInitial());
    });
  }
}
