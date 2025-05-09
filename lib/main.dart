import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/user_model.dart'; // Asegúrate que este modelo no cause problemas si no se usa directamente aquí
import 'services/auth_service.dart';
import 'services/api_service.dart'; // <<--- AÑADE ESTA LÍNEA (Importar ApiService)
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/loading_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Color semilla para nuestro tema pastel elegante y moderno
    final Color seedColor = Color(0xFFC3B1E1); // Un lila pastel suave (Amethyst)
    // Puedes probar otros pasteles como:
    // final Color seedColor = Color(0xFFB2DFDB); // Menta pastel
    // final Color seedColor = Color(0xFFFFE0B2); // Durazno pastel
    // final Color seedColor = Color(0xFFCFD8DC); // Azul grisáceo pastel muy sutil

    return MultiProvider(
      providers: [
        // AuthService se provee primero
        ChangeNotifierProvider(create: (_) => AuthService()),

        // ApiService se provee después y puede acceder a AuthService
        // Usamos Provider.value si ApiService no es un ChangeNotifier,
        // o ChangeNotifierProvider si sí lo es.
        // Aquí asumimos que ApiService no es un ChangeNotifier y que su constructor
        // puede tomar una instancia de AuthService.
        Provider<ApiService>(
          create: (context) {
            // Obtiene la instancia de AuthService que ya está proveída
            // 'listen: false' es importante en 'create' para evitar reconstrucciones innecesarias.
            final authService = Provider.of<AuthService>(context, listen: false);
            return ApiService(authService: authService); // Pasa la instancia de AuthService
          },
        ),
      ],
      child: MaterialApp(
        title: 'SaludChain App',
        theme: ThemeData(
          useMaterial3: true, // Fundamental para un look moderno y para ColorScheme.fromSeed
          brightness: Brightness.light, // Los pasteles lucen mejor en temas claros

          colorScheme: ColorScheme.fromSeed(
            seedColor: seedColor,
            brightness: Brightness.light,
            // Puedes ajustar ligeramente los colores generados si es necesario:
            // primary: seedColor,
            // secondary: Colors.tealAccent[100], // Un acento pastel complementario
            // surface: Color(0xFFFEFBF_F), // Un blanco muy sutilmente teñido
            // background: Color(0xFFFDF9FF),
          ),

          scaffoldBackgroundColor: Color(0xFFFDFBFF), // Un fondo casi blanco con un toque del color primario

          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white, // AppBar más claro para un look moderno
            foregroundColor: Color(0xFF303030), // Texto oscuro en el AppBar para contraste
            elevation: 0.5, // Elevación muy sutil o 0 para un look plano
            centerTitle: false, // Títulos a la izquierda suelen ser más modernos
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500, // Un peso medio
              color: Color(0xFF303030), // Color de texto oscuro
              fontFamily: 'System', // Asegurar que use la fuente del sistema
            ),
            iconTheme: IconThemeData(
              color: Color(0xFF454545), // Iconos oscuros en el AppBar
            ),
          ),

          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: seedColor, // Color primario pastel
              foregroundColor: Colors.black87, // Texto oscuro para buena legibilidad sobre pastel claro
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0), // Bordes redondeados
              ),
              elevation: 2.0, // Sombra sutil
            ),
          ),

          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: seedColor, // Color primario pastel para el texto
              textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),

          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: seedColor, // Color primario pastel
              side: BorderSide(color: seedColor.withOpacity(0.7), width: 1.5), // Borde pastel
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),

          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white, // Fondo blanco para campos de entrada
            hintStyle: TextStyle(color: Colors.grey[400]),
            labelStyle: TextStyle(color: seedColor.withOpacity(0.9)), // Label con color pastel
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0), // Borde sutil
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: seedColor, width: 2.0), // Borde pastel enfocado
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
            elevation: 1.5, // Elevación sutil para las tarjetas
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0), // Bordes más redondeados
              // side: BorderSide(color: Colors.grey.shade200, width: 0.5), // Opcional: un borde muy sutil
            ),
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            color: Colors.white, // Tarjetas blancas para un look limpio
          ),

          textTheme: TextTheme(
            // Definir algunos estilos de texto clave para consistencia
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

            labelLarge: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600, color: seedColor, letterSpacing: 0.5), // Para botones, etc.
            labelMedium: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w500, color: Colors.grey[800], letterSpacing: 0.5),
            labelSmall: TextStyle(fontSize: 11.0, fontWeight: FontWeight.w500, color: Colors.grey[700], letterSpacing: 0.5),
          ).apply(
            // Opcional: aplica un color base al cuerpo del texto si no se especifica uno.
            // bodyColor: Color(0xFF333333),
            // displayColor: Color(0xFF111111),
          ),

          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: seedColor, // Color primario pastel
            foregroundColor: Colors.black87, // Texto oscuro para contraste
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
            iconColor: seedColor.withOpacity(0.9), // Color para los leading/trailing icons
            // dense: true, // Hace los ListTile más compactos
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          ),

          dividerTheme: DividerThemeData(
            color: Colors.grey[200],
            thickness: 0.8,
            space: 1, // Espacio por defecto que ocupa el divider
          ),
        ),
        home: Consumer<AuthService>(
          builder: (context, authService, _) {
            if (authService.isAttemptingLogin) {
              return LoadingScreen();
            }
            if (authService.currentUser != null) {
              return HomeScreen(user: authService.currentUser!);
            }
            return LoginScreen();
          },
        ),
        routes: {
          LoginScreen.routeName: (ctx) => LoginScreen(),
        },
      ),
    );
  }
}