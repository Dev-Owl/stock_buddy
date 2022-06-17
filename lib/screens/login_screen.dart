import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:stock_buddy/backend.dart';
import 'package:stock_buddy/utils/response_handler.dart';
import 'package:stock_buddy/utils/snackbar_extension.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with DefautltResponseHandler {
  final _emailController = TextEditingController();
  final _pwController = TextEditingController();
  bool _isLoading = false;
  bool _singUpCall = false;
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log in')),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 10,
        ),
        children: [
          Center(
            child: SizedBox(
              width: 350,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(
                    10,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Please login',
                          style: Theme.of(context).textTheme.headline5,
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: FaIcon(FontAwesomeIcons.user),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Email required';
                            }
                            return null;
                          },
                          enabled: _isLoading == false,
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _pwController,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: FaIcon(FontAwesomeIcons.key),
                          ),
                          obscureText: true,
                          obscuringCharacter: '*',
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Password required';
                            }
                            return null;
                          },
                          enabled: _isLoading == false,
                        ),
                        const SizedBox(height: 18),
                        _isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: _isLoading ? null : _signIn,
                                child: const Text('Login'),
                              ),
                        if (_isLoading == false)
                          TextButton(
                            onPressed: _register,
                            child: const Text('Register'),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _setLoading(bool newValue) {
    setState(() {
      _isLoading = newValue;
    });
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      _setLoading(true);
      _singUpCall = true;
      runRequest<GotrueSessionResponse>(
        supabase.auth.signUp(
          _emailController.text,
          _pwController.text,
        ),
        _handleResponse,
        fail: (ex) {
          _singUpCall = false;
          _setLoading(false);
        },
      );
    }
  }

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      _setLoading(true);
      runRequest<GotrueSessionResponse>(
        supabase.auth.signIn(
          email: _emailController.text,
          password: _pwController.text,
        ),
        _handleResponse,
        fail: (ex) {
          _setLoading(false);
        },
      );
    }
  }

  void _handleResponse(GotrueSessionResponse result) {
    if (result.error == null) {
      if (_singUpCall) {
        _setLoading(false);
        context.showSnackBar(
            message: 'Please check your inbox, confirm and login');
      } else {
        GoRouter.of(context).go('/');
      }
    } else {
      context.showErrorSnackBar(message: result.error!.message);
      _setLoading(false);
    }
  }
}
