import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fotocopy_app/data/repositories/inventory_repository.dart';
import 'package:fotocopy_app/data/repositories/oder_repository.dart';
import 'package:fotocopy_app/firebase_options.dart';
import 'package:fotocopy_app/logic/bloc/auth_bloc/auth_bloc.dart';
import 'package:fotocopy_app/logic/bloc/inventory_bloc/inventory_bloc.dart';
import 'package:fotocopy_app/logic/bloc/inventory_bloc/inventory_event.dart';
import 'package:fotocopy_app/logic/bloc/transaction_bloc/transaction_bloc.dart';
import 'package:fotocopy_app/logic/bloc/transaction_bloc/transaction_event.dart';
import 'package:fotocopy_app/logic/services/storage_sevice.dart'; // <--- Cek typo nama file ini ya
import 'package:fotocopy_app/presentation/screens/login_screen.dart';
import 'package:fotocopy_app/presentation/screens/main_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  bool isLoggedIn = await StorageService.checkLoginStatus();

  await initializeDateFormatting('id_ID', null);

  final orderRepository = OrderRepository();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: orderRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => AuthBloc()),
          BlocProvider(
            create: (context) =>
                TransactionBloc(orderRepository)..add(LoadTransactions()),
          ),
          BlocProvider(
            create: (context) =>
                InventoryBloc(InventoryRepository())..add(LoadInventory()),
          ),
        ],
        child: MyApp(isLoggedIn: isLoggedIn),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fotocopy Bekalan',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: isLoggedIn ? const MainScreen() : const LoginScreen(),
    );
  }
}
