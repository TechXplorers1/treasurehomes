import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/booking_provider.dart';

class BookingPage extends ConsumerStatefulWidget {
  final String serviceId;
  final String serviceName;
  final double price;

  const BookingPage({
    super.key,
    required this.serviceId,
    required this.serviceName,
    required this.price,
  });

  @override
  ConsumerState<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends ConsumerState<BookingPage> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date')),
      );
      return;
    }
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time')),
      );
      return;
    }

    // Combine date and time
    final bookingDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    await ref
        .read(bookingStateProvider.notifier)
        .createBooking(
          serviceId: widget.serviceId,
          serviceName: widget.serviceName,
          bookingDate: bookingDateTime,
          address: _addressController.text,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
          price: widget.price,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(bookingStateProvider, (previous, next) {
      next.whenOrNull(
        error: (err, st) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $err')));
        },
        data: (_) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Booking Confirmed!')));
          if (context.canPop()) {
            context.pop(); // Pop booking page
            context.pop(); // Pop service details page -> Go back to home
            // Ideally navigate explicitly to 'My Bookings' tab
            context.go('/bookings');
          }
        },
      );
    });

    final isLoading = ref.watch(bookingStateProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: Text('Book ${widget.serviceName}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Date',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _selectedDate == null
                      ? 'Pick a date'
                      : DateFormat('MMM dd, yyyy').format(_selectedDate!),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (date != null && mounted) {
                    setState(() {
                      _selectedDate = date;
                    });
                  }
                },
              ),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Select Time',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _selectedTime == null
                      ? 'Pick a time'
                      : _selectedTime!.format(context),
                ),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null && mounted) {
                    setState(() {
                      _selectedTime = time;
                    });
                  }
                },
              ),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Service Address',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  hintText: 'Enter your address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty
                    ? 'Address is required'
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                'Additional Notes (Optional)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  hintText: 'Add any special instructions or notes',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Price:',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    '\$${widget.price}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submitBooking,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Confirm Booking'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
