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

  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppLogo(),
                _buildHeading(),
                SizedBox(height: 16),
                _buildDescription(), // Added description
                SizedBox(height: 16),
                _buildRegisterForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(
          Icons.nature,
          color: Color.fromARGB(255, 91, 142, 85),
          size: 48,
        ),
        SizedBox(width: 8),
        Text(
          'GardenCompanion',
          style: TextStyle(
            fontFamily: 'Sf',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildHeading() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: RichText(
        textAlign: TextAlign.left,
        text: TextSpan(
          text: 'Register on ',
          style: TextStyle(
            fontFamily: 'Sf',
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          children: [
            TextSpan(
              text: 'GardenCompanion',
              style: TextStyle(
                fontFamily: 'Sf',
                fontSize: 18,
                color: Color.fromARGB(255, 91, 142, 85),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: RichText(
        textAlign: TextAlign.left,
        text: TextSpan(
          text: 'Create an account. We can\'t wait to have you',
          style: TextStyle(
            fontFamily: 'Sf',
            fontSize: 16,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildEmailTextField(),
          SizedBox(height: 16),
          _buildPasswordTextField(),
          SizedBox(height: 32),
          _buildRegisterButton(),
        ],
      ),
    );
  }

  Widget _buildEmailTextField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email',
        filled: true,
        fillColor: Color.fromARGB(255, 247, 250, 244),
        prefixIcon: Icon(Icons.email, color: Color.fromARGB(255, 91, 142, 85)),
      ),
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
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        labelText: 'Password',
        filled: true,
        fillColor: Color.fromARGB(255, 247, 250, 244),
        prefixIcon: Icon(Icons.lock, color: Color.fromARGB(255, 91, 142, 85)),
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
          child: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
        ),
      ),
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
      style: ElevatedButton.styleFrom(
        primary: Color.fromARGB(255, 91, 142, 85),
        padding: EdgeInsets.symmetric(horizontal: 132, vertical: 20),
      ),
      child: Text(
        'REGISTER',
        style: TextStyle(fontSize: 16, fontFamily: 'Sf'),
      ),
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
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
