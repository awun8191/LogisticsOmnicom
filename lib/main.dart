import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:logistics/core/routes/app_pages.dart';
import 'package:logistics/core/routes/app_routes.dart';
import 'package:logistics/core/services/firebase_authentication.dart';
import 'package:logistics/domain/repositories/auth_repository.dart';
import 'package:logistics/domain/repositories/customer_order_repository.dart';
import 'package:logistics/domain/repositories/invoice_repository.dart';
import 'package:logistics/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:logistics/presentation/bloc/invoice_bloc/invoice_bloc.dart';
import 'firebase_options.dart';
import "core/di/injection_container.dart" as di;
// duplicate import cleanup

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await di.initDI();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(authRepository: di.sl<AuthRepository>())),
        BlocProvider(
          create: (_) => InvoiceBloc(
            invoiceRepository: di.sl<InvoiceRepository>(),
            customerOrderRepository: di.sl<CustomerOrderRepository>(),
          ),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final authservice = di.sl<FirebaseAuthenticationService>();
    authservice.authStateChanges.listen((user) {
      if (user != null) {
        // User is signed in
        Get.toNamed(AppRoutes.dashboard);
      } else {
        Get.toNamed(AppRoutes.signin);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Logistics',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.initial,
      getPages: AppRouter.routes,
    );
  }
}
