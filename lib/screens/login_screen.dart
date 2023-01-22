import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stock_buddy/backend.dart';
import 'package:stock_buddy/utils/response_handler.dart';
import 'package:stock_buddy/utils/snackbar_extension.dart';

class LoginScreen extends StatefulWidget {
  final String? resetToken;
  const LoginScreen(this.resetToken, {Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with DefautltResponseHandler {
  final _emailController = TextEditingController();
  final _pwController = TextEditingController();

  final String prefUserName = "user_name";

  bool _isLoading = false;
  final bool _singUpCall = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final lastUser = context.read<SharedPreferences>().getString(prefUserName);
    _emailController.text = lastUser ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final resetMode = widget.resetToken != null;
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
                          resetMode ? 'Reset your password' : 'Please login',
                          style: Theme.of(context).textTheme.headline5,
                        ),
                        const SizedBox(height: 18),
                        if (resetMode == false)
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
                          decoration: InputDecoration(
                            labelText: resetMode ? 'New password' : 'Password',
                            prefixIcon: const FaIcon(FontAwesomeIcons.key),
                          ),
                          obscureText: true,
                          obscuringCharacter: '*',
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Password required';
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) {
                            final callback = _isLoading ? null : _signIn;
                            callback?.call();
                          },
                          enabled: _isLoading == false,
                        ),
                        const SizedBox(height: 18),
                        _isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: _isLoading ? null : _signIn,
                                child: Text(resetMode ? 'Reset' : 'Login'),
                              ),
                        if (_isLoading == false)
                          TextButton(
                            onPressed: _register,
                            child: const Text('Register'),
                          ),
                        if (showForgotPasswordLink && resetMode == false)
                          TextButton(
                            onPressed: _resetPw,
                            child: const Text('Forgot password?'),
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

  Future<void> _resetPw() async {
    /*
    if (_emailController.text.isNotEmpty) {
      context.showSnackBar(message: 'Check your inbox for the used mail');
      final res = await supabase.auth.api.resetPasswordForEmail(
        _emailController.text,
        options: AuthOptions(
            redirectTo:
                kIsWeb ? null : 'io.supabase.flutter://reset-callback/'),
      );
      print(res.error);
    } else {
      context.showErrorSnackBar(message: 'Email required');
    }
    */
  }

  Future<void> _register() async {
    /*
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
    */
  }

  Future<void> _signIn() async {
    final backend = context.read<StockBuddyBackend>();
    if (widget.resetToken != null) {
      /*
      final res = await supabase.auth.api.updateUser(
        widget.resetToken!,
        UserAttributes(password: _pwController.text),
      );
      if (res.error == null) {
        _pwController.text = "";
        if (mounted) {
          context.showSnackBar(message: 'New password saved');
          context.go('/');
        }
      } else {
        if (mounted) {
          context.showErrorSnackBar(message: 'Something went wrong...');
        }
      }
      return;
      */
    }

    if (_formKey.currentState!.validate()) {
      _setLoading(true);
      context
          .read<SharedPreferences>()
          .setString(prefUserName, _emailController.text);
      backend.userName = _emailController.text;
      backend.userPassword = _pwController.text;
      runRequest<String>(
        backend.generateNewAuthToken(),
        _handleResponse,
        fail: (ex) {
          _setLoading(false);
          context.showErrorSnackBar(
              message: 'Unable to login, check your email and password');
        },
      );
    }
  }

  bool showForgotPasswordLink = false;

  void _handleResponse(String token) {
    GoRouter.of(context).go('/');
  }
}
