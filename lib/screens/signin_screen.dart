import 'package:flutter/material.dart';

import 'package:auth/auth.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  String? _error;
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _userController,
            decoration: const InputDecoration(
              labelText: 'Email',
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
            ),
          ),
          const SizedBox(height: 4),
          _error != null ? Text(_error!, style: const TextStyle(color: Colors.red)) : Container(),
          ElevatedButton(
            child: const Text('Sign In'),
            onPressed: () async {
              try {
                await Auth.signIn(_userController.text.trim(), _passwordController.text.trim());
              } catch (err) {
                setState(() {
                  _error = err.toString();
                });
              }
            },
          ),
        ],
      ),
    );
  }
}
