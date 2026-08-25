import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Tus imports de plantillas...
import 'package:dren/plantillas/home.dart';
import 'package:dren/plantillas/login.dart';
import 'package:dren/plantillas/registro.dart';
import 'package:dren/plantillas/reels.dart'; 
import 'package:dren/plantillas/post.dart';
import 'package:dren/plantillas/categorias.dart';

import 'package:dren/plantillas/reelss.dart';
import 'package:dren/plantillas/Perfil_user.dart';
import 'package:dren/plantillas/editar_perfil.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Obligatorio para SharedPreferences antes de runApp
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  Future<Map<String, dynamic>?> _getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('usuario');
      if (userData == null) return null;
      
      final Map<String, dynamic> decoded = jsonDecode(userData);
      // Verificamos que el ID exista para evitar errores de null
      if (decoded['id'] == null) return null; 
      
      return decoded;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es', 'ES')],
      locale: const Locale('es', 'ES'),
      
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => FutureBuilder<Map<String, dynamic>?>(
            future: _getUserData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              final usuario = snapshot.data;
              final bool estaLogueado = usuario != null;

              // Manejo de rutas protegidas
              switch (settings.name) {
                case 'login': return Login();
                case 'registro': return Registro();
                
                // Rutas que requieren usuario obligatorio
                case '/home': 
                  return estaLogueado ? Home(usuario: usuario) : Login();
                case '/reels': 
                  return estaLogueado ? SubirReelPage(userId: usuario['id'], usuario: usuario) : Login();
                case '/post': 
                  return estaLogueado ? CreatePostPage(userId: usuario['id'], usuario: usuario) : Login();
                case '/crear_categoria': 
                  return estaLogueado ? CrearCategoriaScreen(userId: usuario['id'], usuario: usuario) : Login();
                
                // Rutas generales
              
               
                case '/perfil': return PerfilScreen();
                case '/editar': return EditarPerfilScreen();
                case '/vistaReels': return ReelsScreen();
                
                default:
                  return estaLogueado ? Home(usuario: usuario) : Login();
              }
            },
          ),
        );
      },
      // Cambiamos a una ruta que estemos seguros que funciona
      initialRoute: 'login', 
    );
  }
}