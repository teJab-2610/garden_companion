import 'package:flutter/material.dart';
import 'package:garden_companion_2/screens/auths/register_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';
import '../home/home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRememberMe();
  }

  void _loadRememberMe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool rememberMe = prefs.getBool('rememberMe') ?? false;

    if (rememberMe) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }

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
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildEmailTextField(),
                  _buildPasswordTextField(),
                  _buildRememberMeCheckbox(),
                  _buildLoginButton(),
                  _buildGoogleSignInButton(),
                  _buildRegisterButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleSignInButton() {
    return ElevatedButton(
      onPressed: () => _onGoogleSignInPressed(context),
      child: Text('Sign in with Google'),
    );
  }

  Widget _buildEmailTextField() {
    return TextField(
      controller: _emailController,
      decoration: InputDecoration(labelText: 'Email'),
    );
  }

  Widget _buildPasswordTextField() {
    return TextField(
      controller: _passwordController,
      decoration: InputDecoration(labelText: 'Password'),
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
          Text('Remember Me'),
        ],
      ),
    );
  }

  Widget _buildRegisterButton() {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => RegisterPage()), // Navigate to RegisterPage
        );
      },
      child: Text('Don\'t have an account? Register Here'),
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: () => _onLoginPressed(context),
      child: const Text('Login'),
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
        MaterialPageRoute(builder: (context) => HomePage()), // Import HomePage
      );
    } catch (error) {
      _showLoginFailedDialog(context);
    }
  }

  Future<void> _onGoogleSignInPressed(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.loginWithGoogle();

      // Navigate to home screen (HomePage) after successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (error) {
      _showErrorDialog(context, 'Google Sign-In failed: $error');
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

  void _showLoginFailedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Login Failed'),
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
