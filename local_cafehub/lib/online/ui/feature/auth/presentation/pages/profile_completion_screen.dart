import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bhansa_ghar/online/core/models/profile/profile_request.dart';
import 'package:bhansa_ghar/online/ui/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:bhansa_ghar/online/ui/feature/auth/presentation/bloc/auth_event.dart';
import 'package:bhansa_ghar/online/ui/feature/auth/presentation/bloc/auth_state.dart';
import 'package:bhansa_ghar/online/ui/feature/auth/presentation/widgets/map.dart';

class ProfileCompletionScreen extends StatefulWidget {
  final String email;

  const ProfileCompletionScreen({super.key, required this.email});

  @override
  State<ProfileCompletionScreen> createState() =>
      _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _restaurantNameController =
      TextEditingController();

  double _latitude = 27.7172;
  double _longitude = 85.3240;
  bool _addressSelected = false;

  void _onLocationSelected(double lat, double lng, String address) {
    setState(() {
      _latitude = lat;
      _longitude = lng;
      _addressController.text = address;
      _addressSelected = true;
    });
  }

  void _openMapPicker() {
    showDialog(
      context: context,
      builder: (context) => LocationPicker(
        onLocationSelected: _onLocationSelected,
        initialLat: _latitude,
        initialLng: _longitude,
      ),
    );
  }

  void _onComplete() {
    if (_formKey.currentState!.validate()) {
      if (!_addressSelected) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a location on the map')),
        );
        return;
      }
      final request = ProfileRequest(
        email: widget.email,
        username: _usernameController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        latitude: _latitude,
        longitude: _longitude,
        restaurantName: _restaurantNameController.text,
      );
      context.read<OnlineAuthBloc>().add(ProfileCompletionRequested(request));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnlineAuthBloc, OnlineAuthState>(
      listener: (context, state) {
        if (state is NeedsModeSelection) {
          context.go('/mode-selection');
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Complete Profile')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const Text(
                  'Complete Your Profile',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Username is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                    helperText: 'Required for restaurant owner',
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      value!.isEmpty ? 'Phone number is required' : null,
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_addressSelected)
                      TextFormField(
                        controller: _addressController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Restaurant Address (Selected)',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Address is required' : null,
                      ),
                    if (_addressSelected) const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _openMapPicker,
                      icon: const Icon(Icons.map),
                      label: const Text('Pick Location on Map'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[100],
                        foregroundColor: Colors.blue[900],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _restaurantNameController,
                  decoration: const InputDecoration(
                    labelText: 'Restaurant Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Restaurant name is required' : null,
                ),
                const SizedBox(height: 24),
                BlocBuilder<OnlineAuthBloc, OnlineAuthState>(
                  builder: (context, state) {
                    if (state is AuthLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ElevatedButton(
                      onPressed: _onComplete,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Complete & Go to Dashboard'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _restaurantNameController.dispose();
    super.dispose();
  }
}
