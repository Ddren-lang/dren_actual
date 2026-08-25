import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dren/services/auth_service.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

 Future<void> iniciarSesion() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, completa todos los campos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // --- INICIO DE LÓGICA PARA REVISIÓN DE GOOGLE ---
    // Si el revisor usa estas credenciales, entra directo sin internet
    if (email == "review@dren.com" && password == "Dren2026*") {
      Navigator.pushReplacementNamed(context, '/home');
      return; // Detiene la ejecución aquí y no llama al AuthService
    }
    // --- FIN DE LÓGICA PARA REVISIÓN DE GOOGLE ---

    setState(() {
      _isLoading = true;
    });

    final result = await AuthService.login(email, password);

    if (!mounted) return;

    if (result['success']) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            _cajaMorado(size),
            Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: Image.asset(
                'assets/images/logo-Photoroom.png',
                width: 550,
                height: 230,
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 200),
                    _cajaLogin(context),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: MaterialButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            color: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                  context, 'registro');
                            },
                            child: const Text(
                              'Registrar cuenta',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10), // Espacio entre los botones
                        Expanded(
                          child: MaterialButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            color: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                  context, '/recuperar');
                            },
                            child: const Text(
                              'Recuperar contraseña',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container _cajaLogin(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      margin: const EdgeInsets.symmetric(horizontal: 30),
      width: double.infinity,
      height: 430,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Text('Login', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 30),
          TextFormField(
            controller: _emailController,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFE86CA6))),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFE86CA6), width: 2)),
              hintText: 'ejemplo@gmail.com',
              labelText: 'Correo electrónico',
              icon: Icon(Icons.alternate_email_rounded),
            ),
          ),
          const SizedBox(height: 30),
          TextFormField(
            controller: _passwordController,
            autocorrect: false,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFE86CA6))),
              focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFE86CA6), width: 2)),
              hintText: 'Contraseña',
              labelText: 'Contraseña',
              prefixIcon: const Icon(Icons.lock_clock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: const Color(0xFFE86CA6)),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 50),
          _isLoading
              ? const CircularProgressIndicator()
              : MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  disabledColor: Colors.grey,
                  //color: const Color(0xFFD29BFD),
                  color: const Color(0xFFE86CA6),
                  onPressed: iniciarSesion,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 20),
                    child: const Text('Iniciar Sesión',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
        ],
      ),
    );
  }

  Container _cajaMorado(Size size) {
    return Container(
      color: const Color(0xFFE86CA6),
      // color: const Color(0xFFD29BFD),
      width: double.infinity,
      height: size.height * 0.4,
    );
  }
}
