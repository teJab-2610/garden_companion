import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isUsernameTaken = false;
  bool _isEmailTaken = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppLogo(),
                _buildHeading(),
                const SizedBox(height: 16),
                _buildDescription(), // Added description
                const SizedBox(height: 16),
                _buildRegisterForm(),
              ],
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
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: RichText(
        textAlign: TextAlign.left,
        text: const TextSpan(
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
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildEmailTextField(),
            const SizedBox(height: 16),
            _buildPasswordTextField(),
            const SizedBox(height: 16),
            _buildConfirmPasswordTextField(),
            const SizedBox(height: 32),
            _buildUsernameTextField(),
            const SizedBox(height: 16),
            _buildNameTextField(),
            const SizedBox(height: 16),
            _buildPhoneNumberTextField(),
            const SizedBox(height: 32),
            _buildRegisterButton(),
          ],
        ),
      ),
    );
  }

  bool isValidEmail(String email) {
    const pattern = r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$';
    final regex = RegExp(pattern);
    return regex.hasMatch(email);
  }

  Future<bool> isEmailAvailable(String email) async {
    print(email);
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    print(querySnapshot.size);
    print(querySnapshot.docs.isEmpty);
    return querySnapshot.docs.isEmpty;
  }

  Future<void> checkEmailAvailability(String email) async {
    bool isAvailable = await isEmailAvailable(email);
    setState(() {
      _isEmailTaken = !isAvailable; // Update the validation result
    });
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
      onChanged: (value) {
        checkEmailAvailability(value);
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        if (!isValidEmail(_emailController.text)) {
          return 'Please enter a valid email';
        }
        if (_isEmailTaken) {
          return 'Email already taken';
        }

        return null;
      },
    );
  }

  Widget _buildNameTextField() {
    return TextFormField(
      controller: _nameController,
      keyboardType: TextInputType.name,
      decoration: const InputDecoration(
        labelText: 'Name',
        filled: true,
        fillColor: Color.fromARGB(255, 247, 250, 244),
        prefixIcon: Icon(Icons.person, color: Color.fromARGB(255, 91, 142, 85)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your name';
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

  Widget _buildConfirmPasswordTextField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        labelText: 'Re-enter Password',
        filled: true,
        fillColor: const Color.fromARGB(255, 247, 250, 244),
        prefixIcon: const Icon(Icons.lock, color: Color.fromARGB(255, 91, 142, 85)),
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
        if (value == null ||
            value.isEmpty ||
            value != _passwordController.text) {
          return 'Please re-enter your password';
        }
        return null;
      },
    );
  }

  Future<bool> isUsernameAvailable(String username) async {
    print(username);
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('userId', isEqualTo: username)
        .get();
    print(querySnapshot.size);
    print(querySnapshot.docs.isEmpty);
    return querySnapshot.docs.isEmpty;
  }

  Future<void> checkUsernameAvailability(String username) async {
    bool isAvailable = await isUsernameAvailable(username);
    setState(() {
      _isUsernameTaken = !isAvailable; // Update the validation result
    });
  }

  Widget _buildUsernameTextField() {
    return TextFormField(
      controller: _userNameController,
      keyboardType: TextInputType.name,
      decoration: const InputDecoration(
        labelText: 'Username',
        filled: true,
        fillColor: Color.fromARGB(255, 247, 250, 244),
        prefixIcon: Icon(Icons.person, color: Color.fromARGB(255, 91, 142, 85)),
      ),
      onChanged: (value) {
        checkUsernameAvailability(value);
      },
      validator: (value) {
        //if it matched with any username already present in data give error
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        if (_isUsernameTaken) {
          return 'Username already taken';
        }
        return null;
      },
    );
  }

  Widget _buildPhoneNumberTextField() {
    return TextFormField(
      controller: _phoneNumberController,
      keyboardType: TextInputType.phone,
      decoration: const InputDecoration(
        labelText: 'Phone Number',
        filled: true,
        fillColor: Color.fromARGB(255, 247, 250, 244),
        prefixIcon: Icon(Icons.phone, color: Color.fromARGB(255, 91, 142, 85)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty || value.length < 10) {
          return 'Please valid phone number';
        }
        return null;
      },
    );
  }

  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: () => _onRegisterPressed(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 91, 142, 85),
        padding: const EdgeInsets.symmetric(horizontal: 132, vertical: 20),
      ),
      child: const Text(
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
          _userNameController.text,
          _nameController.text,
          _phoneNumberController.text,
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
