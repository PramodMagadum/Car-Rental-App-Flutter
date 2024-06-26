import 'package:car_rental/auth/wrapper.dart';
import 'package:car_rental/pages/details_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth/authentication_service.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
  BlocProvider(
    create: (context) => detialedCubit(false),
    child: MyApp())
  );
   
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ListenableProvider<AuthenticationService>(
          create: (_) => AuthenticationService(),
        ),
      ],
      child:  GetMaterialApp(
        transitionDuration: Duration(milliseconds: 500),
        debugShowCheckedModeBanner: false,
        title: 'Car Rental App',
        home: Wrapper(),
      ),
    );
  }
}
