import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/user_model.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/loading_screen.dart'; // Una pantalla de carga simple

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        // Aquí puedes añadir otros providers para otros servicios (ApiService, BlockchainService)
      ],
      child: MaterialApp(
        title: 'SaludChain App', // Nombre de tu App
        theme: ThemeData(
          primarySwatch: Colors.teal, // Un color base profesional
          scaffoldBackgroundColor: Colors.grey[100],
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.teal[700],
            foregroundColor: Colors.white,
            elevation: 4.0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal[600],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.teal, width: 2.0),
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          cardTheme: CardTheme(
            elevation: 2.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0),
          ),
        ),
        home: Consumer<AuthService>(
          builder: (context, authService, _) {
            if (authService.isAttemptingLogin) {
              return LoadingScreen(); // Muestra pantalla de carga mientras intenta auto-login
            }
            if (authService.currentUser != null) {
              return HomeScreen(user: authService.currentUser!);
            }
            return LoginScreen();
          },
        ),
        routes: {
          LoginScreen.routeName: (ctx) => LoginScreen(),
          // HomeScreen.routeName: (ctx) => HomeScreen(user: /* Necesitarás pasar el usuario aquí */),
          // Puedes definir más rutas aquí si usas named routes extensivamente
        },
      ),
    );
  }
}