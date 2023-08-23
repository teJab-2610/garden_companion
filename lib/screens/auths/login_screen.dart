import 'package:flutter/material.dart';
import 'package:garden_companion_2/screens/auths/register_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../home/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isPasswordVisible = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildAppLogo(),
                  _buildHeading(),
                  _buildDescription(),
                  _buildEmailTextField(),
                  _buildPasswordTextField(),
                  _buildRememberMeCheckbox(),
                  _buildLoginButton(),
                  _buildRegisterButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppLogo() {
    return const Row(
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
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: RichText(
        textAlign: TextAlign.left,
        text: const TextSpan(
          text: 'Login on ',
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
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: RichText(
        textAlign: TextAlign.left,
        text: const TextSpan(
          text: 'Login to your account. We can\'t wait to have you',
          style: TextStyle(
            fontFamily: 'Sf',
            fontSize: 16,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildEmailTextField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
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
        fillColor: const Color.fromARGB(255, 247, 250, 244),
        prefixIcon:
            const Icon(Icons.lock, color: Color.fromARGB(255, 91, 142, 85)),
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

  Widget _buildRememberMeCheckbox() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) => Row(
        children: [
          Checkbox(
            value: authProvider.rememberMe,
            onChanged: (value) {
              authProvider.setRememberMe(value!);
            },
          ),
          const Text('Remember Me'),
        ],
      ),
    );
  }

  Widget _buildRegisterButton() {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RegisterPage()),
        );
      },
      child: RichText(
        text: const TextSpan(
          text: "Don't have an account? ",
          style: TextStyle(
            color: Colors.black, // Set the text color to black
            fontSize: 16, // Adjust the font size as needed
          ),
          children: [
            TextSpan(
              text: 'Register Here',
              style: TextStyle(
                color: Colors.blue, // Set the text color to blue
                fontSize: 16, // Adjust the font size as needed
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        onPressed: () => _onLoginPressed(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 91, 142, 85),
          padding: const EdgeInsets.symmetric(horizontal: 132, vertical: 20),
        ),
        child: const Text(
          'LOGIN',
          style: TextStyle(fontSize: 16, fontFamily: 'Sf'),
        ),
      ),
    );
  }

  Future<void> _onLoginPressed(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.login(
        _emailController.text,
        _passwordController.text,
      );

      if (authProvider.rememberMe) {
        await authProvider.saveRememberMe();
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()), // Import HomePage
      );
    } catch (error) {
      _showLoginFailedDialog(context);
    }
  }

  void _showLoginFailedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Login Failed'),
        content: const Text('Invalid credentials. Please try again.'),
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
