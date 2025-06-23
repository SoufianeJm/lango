import 'package:flutter/material.dart';
import '../../login/screens/login-screen.dart';
import 'package:flutter/services.dart';

// --- Helper Widgets ---
class RoundedTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final String? Function(String?)? validator;

  const RoundedTextField({
    Key? key,
    this.controller,
    required this.label,
    required this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        hintText: hint,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
    );
  }
}

class RoundedDropdown<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final String label;
  final void Function(T?)? onChanged;

  const RoundedDropdown({
    Key? key,
    required this.value,
    required this.items,
    required this.label,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      value: value,
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(item.toString()),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  DateTime? _dob;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dob) {
      setState(() {
        _dob = picked;
      });
    }
  }

  void _register() async {
    // TODO: Use all fields for registration logic

    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
    });
    // TODO: Implement registration logic here
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
    setState(() {
      _isLoading = false;
      // _errorMessage = 'Registration failed. Try again.'; // Uncomment to simulate error
    });
    // On success, navigate or show success message
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                // Title
                const Text(
                  'Register',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat', // Use a modern font if available
                  ),
                ),
                const SizedBox(height: 32),
                // First Name
                RoundedTextField(
                  controller: _firstNameController,
                  label: 'First Name',
                  hint: 'Enter First Name',
                  validator: (v) => v == null || v.trim().isEmpty ? 'Please enter your first name' : null,
                ),
                const SizedBox(height: 18),
                // Last Name
                RoundedTextField(
                  controller: _lastNameController,
                  label: 'Last Name',
                  hint: 'Enter last Name',
                  validator: (v) => v == null || v.trim().isEmpty ? 'Please enter your last name' : null,
                ),
                const SizedBox(height: 18),
                // Email
                RoundedTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  hint: 'Enter Address',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.mail_outline, color: Colors.grey),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Please enter your email';
                    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+');
                    if (!emailRegex.hasMatch(v)) return 'Please enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                // Password
                RoundedTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Enter Password',
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) => v == null || v.length < 6 ? 'Password must be at least 6 characters' : null,
                ),
                const SizedBox(height: 18),
                // Date of Birth
                GestureDetector(
                  onTap: _pickDate,
                  child: AbsorbPointer(
                    child: RoundedTextField(
                      controller: TextEditingController(
                        text: _dob == null ? '' : '${_dob!.year}-${_dob!.month.toString().padLeft(2, '0')}-${_dob!.day.toString().padLeft(2, '0')}',
                      ),
                      label: 'Date of Birth',
                      hint: 'Enter Date of Birth',
                      prefixIcon: const Icon(Icons.calendar_today_outlined, color: Colors.grey),
                      validator: (v) => _dob == null ? 'Select your date of birth' : null,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white, // Set text color to white
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _isLoading ? null : _register,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text(
                            'Register',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account?  ',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: _isLoading
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
