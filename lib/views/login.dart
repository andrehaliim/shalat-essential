import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shalat_essential/components/rotating_dot.dart';
import 'package:shalat_essential/services/colors.dart';
import 'package:shalat_essential/views/register.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool obscurePassword = true;
  bool isLoading = false;
  final auth = FirebaseAuth.instance;

  void loginLoading() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  Future<void> doLogin() async {
    try {
      await auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login successful")),
      );
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final idToken = await user.getIdToken(); // normal token
        final idTokenResult = await user.getIdTokenResult(); // with extra info
        print("Token: $idToken");
        print("Expires at: ${idTokenResult.expirationTime}");
        Navigator.pop(context,true);
      }
    } on FirebaseAuthException catch (e) {
      print(e.message ?? '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Login failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    //final screenHeight = size.height;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, true);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(title: const Text('Muslim Essential'), backgroundColor: AppColors.background, surfaceTintColor: Colors.transparent),
        body: Container(
          width: screenWidth,
          padding: const EdgeInsets.all(30),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Log in now', style: Theme.of(context).primaryTextTheme.headlineMedium),
                Text('Please login to track your prayer', style: Theme.of(context).primaryTextTheme.labelLarge),
                const SizedBox(height: 20),

                // Email Label
                SizedBox(
                  width: screenWidth,
                  child: Text('Email', style: Theme.of(context).primaryTextTheme.labelLarge, textAlign: TextAlign.start),
                ),
                const SizedBox(height: 5),

                // Email Field
                Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(10),
                  child: TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email cannot be empty';
                      }
                      const emailPattern = r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$';
                      if (!RegExp(emailPattern).hasMatch(value)) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF415A77), width: 1.5),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Password Label
                SizedBox(
                  width: screenWidth,
                  child: Text('Password', style: Theme.of(context).primaryTextTheme.labelLarge, textAlign: TextAlign.start),
                ),
                const SizedBox(height: 5),

                // Password Field
                Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(10),
                  child: TextFormField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    cursorColor: Colors.white,
                    style: const TextStyle(color: Colors.white),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password cannot be empty';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF415A77), width: 1.5),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 5),

                SizedBox(
                  width: screenWidth,
                  child: Text('Forgot password', style: Theme.of(context).primaryTextTheme.bodyMedium, textAlign: TextAlign.end),
                ),

                const SizedBox(height: 40),

                // Login Button
                SizedBox(
                  width: screenWidth,
                  height: kMinInteractiveDimension,
                  child: ElevatedButton(
                    style: Theme.of(context).elevatedButtonTheme.style,
                    onPressed: () async{
                      if (_formKey.currentState!.validate()) {
                        // All validations passed
                        print("Email: ${emailController.text}");
                        print("Password: ${passwordController.text}");

                        loginLoading();
                        await doLogin();
                        loginLoading();
                      }
                    },
                    child: isLoading
                        ? RotatingDot()
                        : Text('Login', style: Theme.of(context).primaryTextTheme.labelLarge),
                  ),
                ),

                const SizedBox(height: 20),
                Text('Don\'t have an account?', style: Theme.of(context).primaryTextTheme.bodyMedium),
                const SizedBox(height: 20),

                // Register Button
                SizedBox(
                  width: screenWidth,
                  height: kMinInteractiveDimension,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      side: BorderSide(color: AppColors.borderColor, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.rightToLeft,
                          childBuilder: (context) => Register(),
                        ),
                      );
                    },
                    child: const Text('Register'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
