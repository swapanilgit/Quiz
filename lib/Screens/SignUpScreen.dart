import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quiz/Screens/ProfileScreen.dart';
import 'package:quiz/Screens/UserCache.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isPasswordHidden = true;
  bool isChecked = false;
  bool _isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> createAccount() async {
    if (!_formKey.currentState!.validate()) return;

    if (!isChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please accept Terms & Conditions")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    var success = false;

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text,
          );

      await credential.user?.updateDisplayName(nameController.text.trim());
      await credential.user?.reload();

      await UserCache.initializeCurrentUserData(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        photoUrl: credential.user?.photoURL ?? '',
      );
      await UserCache.setLoggedIn(true);
      success = true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _toast("Account already exists for this email");
      } else if (e.code == 'weak-password') {
        _toast("Password is too weak");
      } else if (e.code == 'invalid-email') {
        _toast("Enter a valid email");
      } else {
        _toast(e.message ?? "Account creation failed");
      }
    } catch (_) {
      _toast("Firebase is not configured correctly");
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (!success) {
      return;
    }
    _toast("Account Created Successfully");


    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                /// Back Button
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                ),

                const SizedBox(height: 10),

                /// Title
                const Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Join thousands of learners and start your quiz journey today.",
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),

                const SizedBox(height: 30),

                /// Full Name
                buildLabel("Full Name"),
                const SizedBox(height: 8),
                buildTextField(
                  controller: nameController,
                  hint: "D Gukesh",
                  icon: Icons.person,
                  validator: (value) =>
                      value!.isEmpty ? "Enter your name" : null,
                ),

                const SizedBox(height: 20),

                /// Email
                buildLabel("Email Address"),
                const SizedBox(height: 8),
                buildTextField(
                  controller: emailController,
                  hint: "Please Enter Valid Email id",
                  icon: Icons.email,
                  validator: (value) {
                    if (value!.isEmpty) return "Enter email";
                    if (!value.contains("@")) return "Enter valid email";
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                /// Password
                buildLabel("Password"),
                const SizedBox(height: 8),
                buildTextField(
                  controller: passwordController,
                  hint: "********",
                  icon: Icons.lock,
                  obscureText: isPasswordHidden,
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordHidden
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.white54,
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordHidden = !isPasswordHidden;
                      });
                    },
                  ),
                  validator: (value) =>
                      value!.length < 6 ? "Minimum 6 characters" : null,
                ),

                const SizedBox(height: 20),

                /// Checkbox
                Row(
                  children: [
                    Checkbox(
                      value: isChecked,
                      activeColor: Colors.blue,
                      onChanged: (value) {
                        setState(() {
                          isChecked = value!;
                        });
                      },
                    ),
                    Expanded(
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(color: Colors.white70),
                          children: [
                            TextSpan(text: "I agree to the "),
                            TextSpan(
                              text: "Terms of Service",
                              style: TextStyle(color: Colors.blue),
                            ),
                            TextSpan(text: " and "),
                            TextSpan(
                              text: "Privacy Policy",
                              style: TextStyle(color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// Create Account Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: (_isLoading || !isChecked)
                        ? null
                        : createAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Create Account",
                            style: TextStyle(fontSize: 18),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                /// OR SIGN UP WITH
                // Row(
                //   children: const [
                //     Expanded(child: Divider(color: Colors.white24)),
                //     Padding(
                //       padding: EdgeInsets.symmetric(horizontal: 10),
                //       child: Text(
                //         "OR SIGN UP WITH",
                //         style: TextStyle(color: Colors.white54),
                //       ),
                //     ),
                //     Expanded(child: Divider(color: Colors.white24)),
                //   ],
                // ),

                // const SizedBox(height: 25),

                /// Google & Apple Buttons
                // Row(
                //   children: [
                //     Expanded(
                //       child: socialButton(
                //         icon: Icons.g_mobiledata,
                //         text: "Google",
                //         onTap: () {
                //           _toast('Google Sing Up Clicked');
                          
                //         },
                //       ),
                //     ),
                //     const SizedBox(width: 15),
                //     Expanded(
                //       child: socialButton(
                //         icon: Icons.apple,
                //         text: "Apple",
                //         onTap: () {
                //           _toast('Apple Sign Up Clicked');
                //         },
                //       ),
                //     ),
                //   ],
                // ),

                const SizedBox(height: 10),

                /// Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: TextStyle(fontSize: 14),
                    ),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(fontSize: 14, color: Colors.blue),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Label Widget
  Widget buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  /// TextField Widget
  Widget buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white54),
        suffixIcon: suffixIcon,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: const Color(0xFF1E293B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  /// Social Button Widget
  Widget socialButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
  
  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: AppColors.text)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.border),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
