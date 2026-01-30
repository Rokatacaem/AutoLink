
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/client_repository.dart';
import 'client_providers.dart';

class AddVehicleScreen extends ConsumerStatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  ConsumerState<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends ConsumerState<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brandCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _vinCtrl = TextEditingController();
  final _nickCtrl = TextEditingController();
  
  bool _isLoading = false;
  String? _error;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final data = {
      'brand': _brandCtrl.text.trim(),
      'model': _modelCtrl.text.trim(),
      'year': int.parse(_yearCtrl.text.trim()),
      'vin': _vinCtrl.text.trim().toUpperCase(),
      'nickname': _nickCtrl.text.trim().isEmpty ? null : _nickCtrl.text.trim(),
    };

    try {
      await ref.read(clientRepositoryProvider).createVehicle(data);
      // Refresh the list of vehicles so the home screen updates
      ref.invalidate(myVehiclesProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehicle added successfully!'), backgroundColor: Colors.green),
        );
        context.pop(); // Go back to Home
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Vehicle")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(_error!, style: const TextStyle(color: Colors.red)),
                ),
                
              TextFormField(
                controller: _brandCtrl,
                decoration: const InputDecoration(labelText: 'Brand (e.g. Toyota)', prefixIcon: Icon(Icons.branding_watermark)),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _modelCtrl,
                decoration: const InputDecoration(labelText: 'Model (e.g. Corolla)', prefixIcon: Icon(Icons.car_repair)),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _yearCtrl,
                decoration: const InputDecoration(labelText: 'Year (YYYY)', prefixIcon: Icon(Icons.calendar_today)),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  final y = int.tryParse(v);
                  if (y == null || y < 1900 || y > DateTime.now().year + 1) return 'Invalid year';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _vinCtrl,
                decoration: const InputDecoration(labelText: 'VIN (Vehicle Identification Number)', prefixIcon: Icon(Icons.numbers)),
                textCapitalization: TextCapitalization.characters,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (v.length < 11 || v.length > 17) return 'Length must be 11-17 chars';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _nickCtrl,
                decoration: const InputDecoration(labelText: 'Nickname (Optional)', prefixIcon: Icon(Icons.edit)),
              ),
              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFFFF6B00), // Brand Orange
                  foregroundColor: Colors.white, 
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("SAVE VEHICLE"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
