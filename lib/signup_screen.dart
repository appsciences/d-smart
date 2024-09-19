import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io'; // Import for SocketException
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SignupScreen extends StatefulWidget {
  final Key? key;

  const SignupScreen({this.key}) : super(key: key);

  @override
  SignupScreenState createState() => SignupScreenState();
}

class SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _storage = FlutterSecureStorage();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text;
      final password = _passwordController.text;

      try {
        // Send signup request to the server
        final response = await http.post(
          Uri.parse('https://your-server-url.com/signup'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        );

        if (response.statusCode == 200) {
          final responseBody = jsonDecode(response.body);
          final jwt = responseBody['token'];

          // Store the JWT securely
          await _storage.write(key: 'jwt', value: jwt);

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Signup successful!')),
          );

          // Navigate to another screen or home screen
          Navigator.pop(context);
        } else {
          // Show error message for unsuccessful signup
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Signup failed: ${response.reasonPhrase}')),
          );
        }
      } on SocketException {
        // Handle network error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No such server. Please check your internet connection and try again.')),
        );
      } on FormatException {
        // Handle JSON format error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unexpected response format. Please try again later.')),
        );
      } catch (e) {
        // Handle other errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: _buildSignupCard(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.lightBlueAccent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildSignupCard() {
    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              SizedBox(height: 16.0),
              _buildEmailField(),
              SizedBox(height: 16.0),
              _buildPasswordField(),
              SizedBox(height: 20),
              _buildSignupButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        'Signup',
        style: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Container(
      width: 300.0, // Set a fixed width for the text field
      child: TextFormField(
        key: ValueKey('email'),
        controller: _emailController,
        decoration: InputDecoration(
          labelText: 'Email',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your email';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      width: 300.0, // Set a fixed width for the text field
      child: TextFormField(
        key: ValueKey('password'),
        controller: _passwordController,
        decoration: InputDecoration(
          labelText: 'Password',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        obscureText: true,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your password';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSignupButton() {
    return ElevatedButton(
      onPressed: _submitForm,
      style: _buttonStyle(),
      child: Text('Signup'),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      padding: EdgeInsets.symmetric(
        horizontal: 32.0,
        vertical: 12.0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }
}