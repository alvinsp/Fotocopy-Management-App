import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fotocopy_app/data/models/oder_model.dart';
import 'package:fotocopy_app/data/repositories/oder_repository.dart';
import 'package:fotocopy_app/logic/bloc/transaction_bloc/transaction_event.dart';
import 'package:fotocopy_app/logic/bloc/transaction_bloc/transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final OrderRepository _repository;
  StreamSubscription? _subscription;
  StreamSubscription? _orderSubscription;
  final DateTime _currentDate = DateTime.now();
  String _currentSearch = '';
  List<OrderModel> _allOrders = [];

  TransactionBloc(this._repository) : super(TransactionInitial()) {
    on<WatchOrders>((event, emit) {
      emit(TransactionLoading());
      _subscription?.cancel();
      _subscription = _repository.getOrders().listen((data) {
        add(OrdersUpdated(data));
      });
    });

    on<UpdateStatus>((event, emit) async {
      try {
        await _repository.updateStatus(event.orderId, event.newStatus);
      } catch (e) {
        emit(TransactionError("Failed to update"));
      }
    });

    on<AddOrderRequested>((event, emit) async {
      try {
        await _repository.addOrder(OrderModel(
          id: '',
          namaPelanggan: event.nama,
          totalHarga: event.harga,
          status: 'menunggu',
          kategori: event.kategori,
          timestamp: DateTime.now(),
        ));
      } catch (e) {
        emit(TransactionError("Failed to add"));
      }
    });

    on<DeleteOrderRequested>((event, emit) async {
      try {
        await _repository.deleteOrder(event.orderId);
      } catch (e) {
        emit(TransactionError("Failed to delete"));
      }
    });

    on<ChangeDateRequested>((event, emit) {
      emit(TransactionLoading());
      _orderSubscription?.cancel();
      _orderSubscription =
          _repository.watchOrdersByDate(event.selectedDate).listen((data) {
        add(OrdersUpdated(data));
      });
    });

    on<SearchNameRequested>((event, emit) {
      _currentSearch = event.query;

      final filtered = _allOrders.where((order) {
        return order.namaPelanggan
            .toLowerCase()
            .contains(_currentSearch.toLowerCase());
      }).toList();

      emit(TransactionLoaded(filtered, _currentDate,
          searchQuery: _currentSearch));
    });

    on<OrdersUpdated>((event, emit) {
      _allOrders = event.orders;

      final filtered = _allOrders.where((order) {
        return order.namaPelanggan
            .toLowerCase()
            .contains(_currentSearch.toLowerCase());
      }).toList();

      emit(TransactionLoaded(filtered, _currentDate,
          searchQuery: _currentSearch));
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
