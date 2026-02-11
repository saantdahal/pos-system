import 'package:bhansa_ghar/online/core/models/website/website_model.dart';
import 'package:bhansa_ghar/online/ui/feature/website/bloc/website_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WebsiteSettingsPage extends StatefulWidget {
  const WebsiteSettingsPage({super.key});

  @override
  State<WebsiteSettingsPage> createState() => _WebsiteSettingsPageState();
}

class _WebsiteSettingsPageState extends State<WebsiteSettingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  late WebsiteData _editingData;
  bool _isDataInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // Use post-frame callback to ensure context is properly set up
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          context.read<WebsiteBloc>().add(const FetchWebsiteDataEvent());
        } catch (e) {
          debugPrint('Error reading WebsiteBloc: $e');
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      context.read<WebsiteBloc>().add(UpdateWebsiteDataEvent(_editingData));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saving website settings...'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Website Settings'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.settings), text: 'Basic'),
            Tab(icon: Icon(Icons.palette), text: 'Branding'),
            Tab(icon: Icon(Icons.info), text: 'Content'),
            Tab(icon: Icon(Icons.share), text: 'Social'),
          ],
        ),
      ),
      body: BlocListener<WebsiteBloc, WebsiteState>(
        listener: (context, state) {
          if (state is WebsiteLoadedState) {
            _editingData = state.websiteData;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Settings saved successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is WebsiteErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<WebsiteBloc, WebsiteState>(
          builder: (context, state) {
            if (state is WebsiteLoadingState) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is WebsiteLoadedState ||
                state is WebsiteUpdatingState ||
                state is WebsiteUpdatedState) {
              // Initialize editing data if needed
              if (state is WebsiteLoadedState && !_isDataInitialized) {
                _editingData = state.websiteData;
                _isDataInitialized = true;
              } else if (state is WebsiteUpdatedState) {
                _editingData = state.websiteData;
              }

              return Form(
                key: _formKey,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBasicTab(),
                    _buildBrandingTab(),
                    _buildContentTab(),
                    _buildSocialTab(),
                  ],
                ),
              );
            } else if (state is WebsiteErrorState) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<WebsiteBloc>().add(
                          const FetchWebsiteDataEvent(),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return const Center(child: Text('No data available'));
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveChanges,
        child: const Icon(Icons.save),
      ),
    );
  }

  Widget _buildBasicTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextFormField(
            initialValue: _editingData.websiteTitle,
            decoration: const InputDecoration(
              labelText: 'Website Title',
              hintText: 'Enter your website title',
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                value?.isEmpty ?? true ? 'Website title is required' : null,
            onChanged: (value) {
              _editingData = _editingData.copyWith(websiteTitle: value);
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: _editingData.websiteDescription,
            decoration: const InputDecoration(
              labelText: 'Website Description',
              hintText: 'Enter a brief description for SEO',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            onChanged: (value) {
              _editingData = _editingData.copyWith(websiteDescription: value);
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: _editingData.websiteKeywords,
            decoration: const InputDecoration(
              labelText: 'SEO Keywords',
              hintText: 'Separate keywords with commas',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              _editingData = _editingData.copyWith(websiteKeywords: value);
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: _editingData.contactEmail,
            decoration: const InputDecoration(
              labelText: 'Contact Email',
              hintText: 'your@email.com',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) {
              _editingData = _editingData.copyWith(contactEmail: value);
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: _editingData.contactPhone,
            decoration: const InputDecoration(
              labelText: 'Contact Phone',
              hintText: '+1 234 567 8900',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              _editingData = _editingData.copyWith(contactPhone: value);
            },
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Enable Newsletter'),
            value: _editingData.enableNewsletter,
            onChanged: (value) {
              setState(() {
                _editingData = _editingData.copyWith(enableNewsletter: value);
              });
            },
          ),
          SwitchListTile(
            title: const Text('Show Menu Online'),
            value: _editingData.showMenuOnline,
            onChanged: (value) {
              setState(() {
                _editingData = _editingData.copyWith(showMenuOnline: value);
              });
            },
          ),
          SwitchListTile(
            title: const Text('Show Reservations Online'),
            value: _editingData.showReservationsOnline,
            onChanged: (value) {
              setState(() {
                _editingData = _editingData.copyWith(
                  showReservationsOnline: value,
                );
              });
            },
          ),
          SwitchListTile(
            title: const Text('Website Active'),
            value: _editingData.isActive,
            onChanged: (value) {
              setState(() {
                _editingData = _editingData.copyWith(isActive: value);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBrandingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextFormField(
            initialValue: _editingData.primaryColor,
            decoration: const InputDecoration(
              labelText: 'Primary Color (Hex)',
              hintText: '#FF6B6B',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.palette),
            ),
            onChanged: (value) {
              _editingData = _editingData.copyWith(primaryColor: value);
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: _editingData.secondaryColor,
            decoration: const InputDecoration(
              labelText: 'Secondary Color (Hex)',
              hintText: '#4ECDC4',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.palette),
            ),
            onChanged: (value) {
              _editingData = _editingData.copyWith(secondaryColor: value);
            },
          ),
          const SizedBox(height: 24),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Note: Upload logo and favicon through admin panel'),
          ),
        ],
      ),
    );
  }

  Widget _buildContentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextFormField(
            initialValue: _editingData.heroTitle,
            decoration: const InputDecoration(
              labelText: 'Hero Title',
              hintText: 'Welcome to our restaurant',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              _editingData = _editingData.copyWith(heroTitle: value);
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: _editingData.heroSubtitle,
            decoration: const InputDecoration(
              labelText: 'Hero Subtitle',
              hintText: 'Delicious food, great service',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              _editingData = _editingData.copyWith(heroSubtitle: value);
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: _editingData.heroCTAButtonText,
            decoration: const InputDecoration(
              labelText: 'CTA Button Text',
              hintText: 'Order Now',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              _editingData = _editingData.copyWith(heroCTAButtonText: value);
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: _editingData.aboutTitle,
            decoration: const InputDecoration(
              labelText: 'About Title',
              hintText: 'About Us',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              _editingData = _editingData.copyWith(aboutTitle: value);
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: _editingData.aboutContent,
            decoration: const InputDecoration(
              labelText: 'About Content',
              hintText: 'Tell your story...',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
            onChanged: (value) {
              _editingData = _editingData.copyWith(aboutContent: value);
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: _editingData.footerText,
            decoration: const InputDecoration(
              labelText: 'Footer Text',
              hintText: 'Copyright © 2024',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              _editingData = _editingData.copyWith(footerText: value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSocialTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextFormField(
            initialValue: _editingData.facebookUrl,
            decoration: const InputDecoration(
              labelText: 'Facebook URL',
              hintText: 'https://facebook.com/yourpage',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.facebook),
            ),
            keyboardType: TextInputType.url,
            onChanged: (value) {
              _editingData = _editingData.copyWith(facebookUrl: value);
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: _editingData.instagramUrl,
            decoration: const InputDecoration(
              labelText: 'Instagram URL',
              hintText: 'https://instagram.com/yourprofile',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.camera_alt),
            ),
            keyboardType: TextInputType.url,
            onChanged: (value) {
              _editingData = _editingData.copyWith(instagramUrl: value);
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: _editingData.twitterUrl,
            decoration: const InputDecoration(
              labelText: 'Twitter URL',
              hintText: 'https://twitter.com/yourhandle',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.tag),
            ),
            keyboardType: TextInputType.url,
            onChanged: (value) {
              _editingData = _editingData.copyWith(twitterUrl: value);
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: _editingData.whatsappNumber,
            decoration: const InputDecoration(
              labelText: 'WhatsApp Number',
              hintText: '+1 234 567 8900',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
            ),
            onChanged: (value) {
              _editingData = _editingData.copyWith(whatsappNumber: value);
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: _editingData.contactWhatsapp,
            decoration: const InputDecoration(
              labelText: 'Contact WhatsApp',
              hintText: '+1 234 567 8900',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              _editingData = _editingData.copyWith(contactWhatsapp: value);
            },
          ),
        ],
      ),
    );
  }
}
