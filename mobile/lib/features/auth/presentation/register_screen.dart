import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'auth_providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _role = "client"; // client or mechanic
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(registerControllerProvider);

    ref.listen(registerControllerProvider, (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${next.error}'), backgroundColor: Colors.red),
        );
      } else if (!next.isLoading && !next.hasError) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration Successful! Please Login.'), backgroundColor: Colors.green),
           );
           context.pop(); // Go back to login
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
               Container(
                 height: 100,
                 decoration: BoxDecoration(
                   shape: BoxShape.circle,
                   boxShadow: [
                     BoxShadow(color: const Color(0xFFFF6B00).withOpacity(0.2), blurRadius: 20, spreadRadius: 5)
                   ]
                 ),
                 child: Image.asset('assets/images/logo.jpg', height: 100),
               ),
               const SizedBox(height: 32),

              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person)),
              ),
              const SizedBox(height: 16),
  
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
  
              DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(labelText: 'I am a...', prefixIcon: Icon(Icons.work)),
                items: const [
                  DropdownMenuItem(value: "client", child: Text("Vehicle Owner")),
                  DropdownMenuItem(value: "mechanic", child: Text("Mechanic / Partner")),
                ],
                onChanged: (val) => setState(() => _role = val!),
              ),
              const SizedBox(height: 32),
  
              ElevatedButton(
                onPressed: authState.isLoading
                    ? null
                    : () {
                        ref.read(registerControllerProvider.notifier).register(
                              _emailCtrl.text.trim(),
                              _passCtrl.text.trim(),
                              _nameCtrl.text.trim(),
                              _role, // Ensure this matches UserRole enum in backend
                            );
                      },
                child: authState.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("REGISTER"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
