import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(loginControllerProvider);
    
    // Listen for errors or success
    ref.listen(loginControllerProvider, (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${next.error}'), backgroundColor: Colors.red),
        );
      } else if (!next.isLoading && !next.hasError) {
          // Success
          if (mounted) {
             if (_emailCtrl.text.contains("mechanic")) {
               context.go('/mechanic-home');
             } else {
               context.go('/home');
             }
          }
      }
    });

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
               Container(
                 height: 120,
                 decoration: BoxDecoration(
                   shape: BoxShape.circle,
                   boxShadow: [
                     BoxShadow(color: const Color(0xFFFF6B00).withOpacity(0.2), blurRadius: 20, spreadRadius: 5)
                   ]
                 ),
                 child: Image.asset('assets/images/logo.jpg', height: 120),
               ),
               const SizedBox(height: 24),
               Text(
                "AutoLink",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 48),
              
              TextField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: _passCtrl,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: authState.isLoading
                    ? null
                    : () {
                        ref.read(loginControllerProvider.notifier).login(
                              _emailCtrl.text.trim(),
                              _passCtrl.text.trim(),
                            );
                      },
                child: authState.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("LOGIN"),
              ),
                const SizedBox(height: 24),
                const Row(children: [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("OR")), Expanded(child: Divider())]),
                const SizedBox(height: 24),

                OutlinedButton.icon(
                  onPressed: authState.isLoading
                      ? null
                      : () {
                          ref.read(loginControllerProvider.notifier).signInWithGoogle();
                        },
                  icon: Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/768px-Google_%22G%22_logo.svg.png',
                    height: 24,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.login), 
                  ),
                  label: const Text("Sign in with Google"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),
              
              TextButton(
                onPressed: () => context.push('/register'),
                child: const Text("Create Account"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
