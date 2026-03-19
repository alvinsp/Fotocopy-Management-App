import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fotocopy_app/data/models/oder_model.dart';
import 'package:fotocopy_app/data/repositories/oder_repository.dart';
import 'package:fotocopy_app/logic/bloc/transaction_bloc/transaction_event.dart';
import 'package:fotocopy_app/logic/bloc/transaction_bloc/transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final OrderRepository _repository;
  StreamSubscription? _orderSubscription;

  List<OrderModel> _allOrders = [];
  String _currentSearch = '';
  DateTime _currentDate = DateTime.now();

  TransactionBloc(this._repository) : super(TransactionInitial()) {
    on<LoadTransactions>((event, emit) async {
      emit(TransactionLoading());
      await _orderSubscription?.cancel();

      _orderSubscription = _repository.getOrders().listen(
        (orders) {
          if (!isClosed) {
            add(UpdateTransactionList(orders));
          }
        },
        onError: (e) => emit(TransactionError(e.toString())),
      );
    });

    on<UpdateTransactionList>((event, emit) {
      _allOrders = event.orders;
      _applyFilter(emit);
    });

    on<SearchNameRequested>((event, emit) {
      _currentSearch = event.query;
      _applyFilter(emit);
    });

    on<ClearTransactionData>((event, emit) async {
      await _orderSubscription?.cancel();
      _orderSubscription = null;
      _allOrders = [];
      _currentSearch = '';
      emit(TransactionInitial());
    });

    on<AddOrderRequested>((event, emit) async {
      try {
        await _repository.addOrder(OrderModel(
          id: '',
          namaPelanggan: event.nama,
          totalHarga: event.harga,
          status: 'menunggu',
          kategori: event.kategori,
          createdAt: DateTime.now(),
        ));
      } catch (e) {
        emit(TransactionError("Gagal tambah pesanan: ${e.toString()}"));
      }
    });

    on<ChangeDateRequested>((event, emit) {
      _currentDate = event.selectedDate;
      _applyFilter(emit);
    });

    on<DeleteOrderRequested>((event, emit) async {
      try {
        await _repository.deleteOrder(event.orderId);
      } catch (e) {
        emit(TransactionError("Gagal menghapus pesanan"));
      }
    });

    on<UpdateStatus>((event, emit) async {
      try {
        await _repository.updateStatus(event.orderId, event.newStatus);
      } catch (e) {
        emit(TransactionError("Gagal memperbarui status: ${e.toString()}"));
      }
    });
  }

  void _applyFilter(Emitter<TransactionState> emit) {
    final filtered = _allOrders.where((order) {
      return order.namaPelanggan
          .toLowerCase()
          .contains(_currentSearch.toLowerCase());
    }).toList();
    emit(
        TransactionLoaded(filtered, _currentDate, searchQuery: _currentSearch));
  }
}
