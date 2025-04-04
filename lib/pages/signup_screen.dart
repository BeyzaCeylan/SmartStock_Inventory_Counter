import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  bool agreeTerms = true;

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

          // ✅ Beyaz kayıt formu alanı
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.80,
              padding: const EdgeInsets.fromLTRB(25.0, 80.0, 25.0, 20.0),
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
                      const Text(
                        'Get Started!',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF26A42C),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // ✅ Full Name
                      TextFormField(
                        validator: (value) => value!.isEmpty ? 'Enter your name' : null,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          hintText: 'Enter Full Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ✅ Email
                      TextFormField(
                        validator: (value) => value!.isEmpty ? 'Enter your email' : null,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'Enter Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ✅ Password
                      TextFormField(
                        obscureText: true,
                        validator: (value) => value!.isEmpty ? 'Enter password' : null,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ✅ Checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: agreeTerms,
                            onChanged: (value) {
                              setState(() => agreeTerms = value!);
                            },
                            activeColor: const Color(0xFF26A42C),
                          ),
                          const Expanded(
                            child: Text.rich(
                              TextSpan(
                                text: 'I agree to the processing of ',
                                style: TextStyle(color: Colors.black45),
                                children: [
                                  TextSpan(
                                    text: 'Personal data',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF26A42C),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ✅ Sign up butonu
                      SizedBox(
                        width: 200,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate() && agreeTerms) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Creating account...')),
                              );
                            } else if (!agreeTerms) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please accept the terms')),
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
                            'Sign up',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ✅ Girişe yönlendirme
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already have an account? ',
                              style: TextStyle(color: Colors.black45)),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                color: Color(0xFF26A42C),
                                fontWeight: FontWeight.bold,
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
