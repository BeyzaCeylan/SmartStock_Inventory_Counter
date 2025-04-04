import 'package:flutter/material.dart';
import 'signup_screen.dart';

// SignUpScreen yoksa geçici placeholder

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: const Center(child: Text("Sign Up Page")),
    );
  }


class AuthSelectionPage extends StatefulWidget {
  const AuthSelectionPage({super.key});

  @override
  State<AuthSelectionPage> createState() => _AuthSelectionPageState();
}

class _AuthSelectionPageState extends State<AuthSelectionPage> {
  final _formKey = GlobalKey<FormState>();
  bool rememberPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ✅ Arka plan resmi
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),

          // ✅ Beyaz kutu alanı
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.fromLTRB(25.0, 30.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(60.0),
                  topRight: Radius.circular(60.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      const Image(
                        image: AssetImage('assets/images/smartstock_logo.png'),
                        height: 130,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Welcome Back!',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF26A42C),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Email
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Email';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'Enter Email',
                          hintStyle: const TextStyle(color: Colors.black26),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),

                      // Password
                      TextFormField(
                        obscureText: true,
                        obscuringCharacter: '*',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Password';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter Password',
                          hintStyle: const TextStyle(color: Colors.black26),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),

                      // Checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: rememberPassword,
                            onChanged: (value) {
                              setState(() => rememberPassword = value!);
                            },
                            activeColor: const Color(0xFF26A42C),
                          ),
                          const Text(
                            'Remember me',
                            style: TextStyle(color: Colors.black45),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),

                      // Login button
                      SizedBox(
                        width: 200,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Processing Data')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 28, 106, 32),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),

                      // ✅ Sign up yönlendirme metni
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Don\'t have an account? ',
                            style: TextStyle(
                              color: Colors.black45,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (e) => const SignUpScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Sign up',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF26A42C),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
