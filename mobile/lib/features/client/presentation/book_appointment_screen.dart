
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/client_repository.dart';
import 'client_providers.dart';

class BookAppointmentScreen extends ConsumerStatefulWidget {
  final String mechanicId;
  final String mechanicName;

  const BookAppointmentScreen({
    super.key, 
    required this.mechanicId, 
    required this.mechanicName
  });

  @override
  ConsumerState<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends ConsumerState<BookAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  
  int? _selectedVehicleId;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  
  bool _isLoading = false;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedVehicleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a vehicle")));
      return;
    }
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select date and time")));
      return;
    }

    setState(() => _isLoading = true);

    // Combine Date and Time
    final dt = DateTime(
      _selectedDate!.year, 
      _selectedDate!.month, 
      _selectedDate!.day,
      _selectedTime!.hour, 
      _selectedTime!.minute
    );

    try {
      final req = {
        'mechanic_id': int.parse(widget.mechanicId),
        'vehicle_id': _selectedVehicleId,
        'description': _descController.text,
        'scheduled_date': dt.toIso8601String(),
      };
      
      await ref.read(clientRepositoryProvider).createServiceRequest(req);
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text("Request Sent!"),
            content: const Text("The mechanic has received your request."),
            actions: [
              TextButton(onPressed: () {
                context.pop(); // Close dialog
                context.go('/home'); // Go home
              }, child: const Text("OK"))
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehiclesAsync = ref.watch(myVehiclesProvider);

    return Scaffold(
      appBar: AppBar(title: Text("Book with ${widget.mechanicName}")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text("Select Your Vehicle", style: TextStyle(fontWeight: FontWeight.bold)),
              vehiclesAsync.when(
                data: (vehicles) {
                  if (vehicles.isEmpty) return const Text("No vehicles. Add one first!");
                  return DropdownButtonFormField<int>(
                    value: _selectedVehicleId,
                    items: vehicles.map<DropdownMenuItem<int>>((v) {
                      return DropdownMenuItem(
                        value: v['id'],
                        child: Text("${v['brand']} ${v['model']} (${v['year']})"),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedVehicleId = val),
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (e, s) => Text("Error loading vehicles: $e"),
              ),
              const SizedBox(height: 20),

              const Text("Select Date & Time", style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_today),
                      label: Text(_selectedDate == null 
                        ? "Pick Date" 
                        : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickTime,
                      icon: const Icon(Icons.access_time),
                      label: Text(_selectedTime == null 
                        ? "Pick Time" 
                        : _selectedTime!.format(context)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: "Problem Description",
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                validator: (v) => v == null || v.isEmpty ? "Please describe the issue" : null,
              ),
              
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B00),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text("SEND REQUEST"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
