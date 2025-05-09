import 'package:flutter/material.dart';
import 'package:healthcare_blockchain_app/services/api_service.dart';
import 'package:provider/provider.dart';

// Modelos y Servicios
import '../models/user_model.dart'; // Modelo de usuario, probablemente usado en HomeScreen u otras pantallas
import '../services/auth_service.dart'; // Servicio de autenticación
import '../services/api_service.dart';   // Servicio para interactuar con tu API backend

// Pantallas
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/loading_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Color semilla para el tema de la aplicación
    final Color seedColor = Color(0xFFC3B1E1); // Ejemplo: Lila pastel suave

    return MultiProvider(
      providers: [
        // 1. AuthService: Es un ChangeNotifier, por lo que se usa ChangeNotifierProvider.
        //    Estará disponible en toda la app y notificará a los oyentes sobre cambios (ej. estado de login).
        ChangeNotifierProvider(create: (_) => AuthService()),

        // 2. ApiService: No es un ChangeNotifier. Se provee usando un Provider simple.
        //    Depende de AuthService, así que se crea después y se le pasa la instancia de AuthService.
        Provider<ApiService>(
          create: (context) {
            // Obtiene la instancia de AuthService que ya fue proveída por el ChangeNotifierProvider anterior.
            // 'listen: false' es importante dentro de funciones 'create' para evitar reconstrucciones
            // innecesarias del provider mismo si AuthService notificara cambios (aunque aquí ApiService se crea una vez).
            final authService = Provider.of<AuthService>(context, listen: false);
            return ApiService(authService: authService); // Pasa la instancia de AuthService al constructor de ApiService
          },
        ),
        // Puedes añadir más providers aquí si tu aplicación crece.
      ],
      child: MaterialApp(
        title: 'SaludChain App', // Nombre de tu aplicación
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSeed(
            seedColor: seedColor,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: Color(0xFFFDFBFF),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF303030),
            elevation: 0.5,
            centerTitle: false,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Color(0xFF303030),
              fontFamily: 'System',
            ),
            iconTheme: IconThemeData(
              color: Color(0xFF454545),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: seedColor,
              foregroundColor: Colors.black87,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 2.0,
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: seedColor,
              textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: seedColor,
              side: BorderSide(color: seedColor.withOpacity(0.7), width: 1.5),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            hintStyle: TextStyle(color: Colors.grey[400]),
            labelStyle: TextStyle(color: seedColor.withOpacity(0.9)),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: seedColor, width: 2.0),
              borderRadius: BorderRadius.circular(12.0),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red.shade300, width: 1.5),
              borderRadius: BorderRadius.circular(12.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red.shade400, width: 2.0),
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          cardTheme: CardTheme(
            elevation: 1.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            color: Colors.white,
          ),
          textTheme: TextTheme(
            displayLarge: TextStyle(fontSize: 57.0, fontWeight: FontWeight.normal, color: Color(0xFF303030), letterSpacing: -0.25),
            displayMedium: TextStyle(fontSize: 45.0, fontWeight: FontWeight.normal, color: Color(0xFF303030)),
            displaySmall: TextStyle(fontSize: 36.0, fontWeight: FontWeight.normal, color: Color(0xFF303030)),
            headlineLarge: TextStyle(fontSize: 32.0, fontWeight: FontWeight.w500, color: Color(0xFF303030)),
            headlineMedium: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w500, color: Color(0xFF303030)),
            headlineSmall: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w500, color: Color(0xFF303030)),
            titleLarge: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w500, color: Color(0xFF303030), letterSpacing: 0.15),
            titleMedium: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500, color: Color(0xFF454545), letterSpacing: 0.15),
            titleSmall: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500, color: Color(0xFF454545), letterSpacing: 0.1),
            bodyLarge: TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal, color: Color(0xFF454545), letterSpacing: 0.5),
            bodyMedium: TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal, color: Color(0xFF454545), letterSpacing: 0.25),
            bodySmall: TextStyle(fontSize: 12.0, fontWeight: FontWeight.normal, color: Colors.grey[700], letterSpacing: 0.4),
            labelLarge: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600, color: seedColor, letterSpacing: 0.5),
            labelMedium: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w500, color: Colors.grey[800], letterSpacing: 0.5),
            labelSmall: TextStyle(fontSize: 11.0, fontWeight: FontWeight.w500, color: Colors.grey[700], letterSpacing: 0.5),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: seedColor,
            foregroundColor: Colors.black87,
            elevation: 3.0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          ),
          dialogTheme: DialogTheme(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
            backgroundColor: Colors.white,
            titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF303030)),
            contentTextStyle: TextStyle(fontSize: 16.0, color: Color(0xFF454545)),
          ),
          chipTheme: ChipThemeData(
            backgroundColor: seedColor.withOpacity(0.15),
            labelStyle: TextStyle(color: seedColor, fontWeight: FontWeight.w500),
            side: BorderSide.none,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          ),
          listTileTheme: ListTileThemeData(
            iconColor: seedColor.withOpacity(0.9),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          ),
          dividerTheme: DividerThemeData(
            color: Colors.grey[200],
            thickness: 0.8,
            space: 1,
          ),
        ),
        // Consumer<AuthService> decide qué pantalla mostrar inicialmente
        // basado en el estado de autenticación.
        home: Consumer<AuthService>(
          builder: (context, authService, child) {
            // Muestra LoadingScreen mientras se intenta el login (ej. auto-login con token guardado)
            // o durante el proceso de login/registro activo.
            if (authService.isAttemptingLogin || authService.isRegistering) {
              return LoadingScreen();
            }
            // Si hay un usuario actual (login exitoso), muestra HomeScreen.
            if (authService.currentUser != null) {
              return HomeScreen(user: authService.currentUser!);
            }
            // Si no, muestra LoginScreen.
            return LoginScreen();
          },
        ),
        // Define las rutas nombradas de tu aplicación si las usas.
        routes: {
          LoginScreen.routeName: (ctx) => LoginScreen(),
          // Ejemplo: HomeScreen.routeName: (ctx) => HomeScreen(), // Si HomeScreen se accede por ruta nombrada también
          // Ejemplo: PatientRegistrationScreen.routeName: (ctx) => PatientRegistrationScreen(),
        },
        // Opcional: onGenerateRoute para rutas dinámicas o desconocidas.
        // onGenerateRoute: (settings) { ... },
      ),
    );
  }
}

