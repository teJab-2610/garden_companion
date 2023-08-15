import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/login_bg.png'),
            fit: BoxFit.none,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildRegisterForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildEmailTextField(),
          _buildPasswordTextField(),
          _buildRegisterButton(),
        ],
      ),
    );
  }

  Widget _buildEmailTextField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(labelText: 'Email'),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordTextField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: true,
      decoration: const InputDecoration(labelText: 'Password'),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }

  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: () => _onRegisterPressed(context),
      child: Text('Register'),
    );
  }

  Future<void> _onRegisterPressed(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (_formKey.currentState!.validate()) {
      try {
        await authProvider.register(
          _emailController.text,
          _passwordController.text,
        );

        // Navigate back to login screen after successful registration
        Navigator.pop(context);
      } catch (error) {
        _showErrorDialog(context, 'Registration failed: $error');
      }
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
