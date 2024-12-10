// ignore_for_file: unused_field, unused_local_variable
import 'package:cpsl_flutter/client/capsule.dart';
import 'package:cpsl_flutter/widgets/demo_home.dart';
import 'package:cpsl_flutter/widgets/demo_otp_verification.dart';
import 'package:flutter/material.dart';
import 'package:capsule/capsule.dart';

class CapsuleEmailExample extends StatefulWidget {
  const CapsuleEmailExample({super.key});

  @override
  State<CapsuleEmailExample> createState() => _CapsuleEmailExampleState();
}

class _CapsuleEmailExampleState extends State<CapsuleEmailExample> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  Wallet? _wallet;
  String? _address;
  String? _recoveryShare;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    try {
      final isLoggedIn = await capsuleClient.isFullyLoggedIn();
      if (isLoggedIn && mounted) {
        final email = await capsuleClient.getEmail();
        final wallets = await capsuleClient.getWallets();

        if (wallets.isNotEmpty) {
          setState(() {
            _wallet = wallets.values.first;
            _address = wallets.values.first.address;
            _recoveryShare = "";
          });
        }

        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => const DemoHome()),
        // );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error checking login status: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _handleCreateNewUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      if (await capsuleClient.checkIfUserExists(email)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User already exists, please use passkey login')),
        );
        return;
      }

      await capsuleClient.createUser(email);
      if (!mounted) return;

      final bool verified = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => DemoOtpVerification(
                onVerify: (String code) async {
                  try {
                    final biometricsId = await capsuleClient.verifyEmail(code);
                    await capsuleClient.generatePasskey(email, biometricsId);
                    final result = await capsuleClient.createWallet(skipDistribute: false);
                    setState(() {
                      _wallet = result.wallet;
                      _address = result.wallet.address;
                      _recoveryShare = result.recoveryShare;
                    });
                    return true;
                  } catch (e) {
                    return false;
                  }
                },
              ),
            ),
          ) ??
          false;

      if (verified && mounted) {
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DemoHome()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handlePasskeyLogin() async {
    setState(() => _isLoading = true);

    try {
      final wallet = await capsuleClient.login();

      if (!mounted) return;

      setState(() {
        _wallet = wallet;
        _address = wallet.address;
        _recoveryShare = "";
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DemoHome()),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email + Passkey Example'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title Section
                const Text(
                  'Email Authentication',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Example implementation of email-based authentication using Capsule SDK with passkey support.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 48),

                // Email Input
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email address';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Create New User Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleCreateNewUser,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create New User'),
                ),
                const SizedBox(height: 32),

                // Separator
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 32),

                // Login with Passkey Button
                OutlinedButton(
                  onPressed: _isLoading ? null : _handlePasskeyLogin,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Login with Passkey'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}