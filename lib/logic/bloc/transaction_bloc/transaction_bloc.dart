import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
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

    on<ClearTransactionData>((event, emit) async {
      print("Mematikan Stream Firestore...");
      await _orderSubscription?.cancel();
      _orderSubscription = null;
      emit(TransactionInitial());
    });

    on<UpdateTransactionList>((event, emit) {
      _allOrders = event.orders;
      _applyFilter(emit);
    });

    on<SearchNameRequested>((event, emit) {
      _currentSearch = event.query;
      _applyFilter(emit);
    });

    on<AddOrderRequested>((event, emit) async {
      try {
        await _repository.addOrder(
          OrderModel(
            id: '',
            namaPelanggan: event.nama,
            totalHarga: event.harga,
            status: 'menunggu',
            kategori: event.kategori,
            isLunas: event.isLunas,
            createdAt: DateTime.now(),
          ),
        );
        add(LoadTransactions());
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

    on<LoadDebtRequested>((event, emit) {
      if (state is TransactionLoaded) {
        final currentState = state as TransactionLoaded;
        final debtList =
            currentState.orders.where((o) => o.isLunas == false).toList();
        emit(TransactionDebtLoaded(debtList));
      }
    });

    on<MarkAsPaidRequested>((event, emit) async {
      try {
        await FirebaseFirestore.instance
            .collection('orders')
            .doc(event.transactionId)
            .update({'isLunas': true});
        add(LoadTransactions());
      } catch (e) {
        print("Gagal update lunas: $e");
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

  @override
  Future<void> close() {
    _orderSubscription?.cancel();
    return super.close();
  }
}
