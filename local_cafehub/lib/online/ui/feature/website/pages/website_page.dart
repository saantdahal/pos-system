import 'package:bhansa_ghar/online/core/models/website/website_model.dart';
import 'package:bhansa_ghar/online/ui/feature/website/bloc/website_bloc.dart';
import 'package:bhansa_ghar/online/ui/feature/website/widgets/color_picker_field.dart';
import 'package:bhansa_ghar/online/ui/feature/website/widgets/feature_block_card.dart';
import 'package:bhansa_ghar/online/ui/feature/website/widgets/image_upload_field.dart';
import 'package:bhansa_ghar/online/ui/feature/website/widgets/social_link_field.dart';
import 'package:bhansa_ghar/online/ui/feature/website/widgets/website_validation.dart';
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
  bool _hasUnsavedChanges = false;

  // Image upload states
  String? _logoUploadingError;
  String? _faviconUploadingError;
  String? _aboutImageUploadingError;
  bool _isLogoUploading = false;
  bool _isFaviconUploading = false;
  bool _isAboutImageUploading = false;
  double _logoUploadProgress = 0.0;
  double _faviconUploadProgress = 0.0;
  double _aboutImageUploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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

  void _markAsChanged() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      context.read<WebsiteBloc>().add(UpdateWebsiteDataEvent(_editingData));
      setState(() {
        _hasUnsavedChanges = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saving website settings...'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _resetChanges() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Changes?'),
        content: const Text(
          'Are you sure you want to discard all unsaved changes?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<WebsiteBloc>().add(
                const ResetWebsiteToDefaultEvent(),
              );
              setState(() {
                _hasUnsavedChanges = false;
              });
            },
            child: const Text('Reset'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_hasUnsavedChanges) {
          final shouldLeave = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Unsaved Changes'),
              content: const Text(
                'You have unsaved changes. Do you want to leave?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Leave'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ),
          );
          return shouldLeave ?? false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Website Settings'),
          elevation: 0,
          actions: [
            if (_hasUnsavedChanges)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Unsaved Changes',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.info), text: 'Basic'),
              Tab(icon: Icon(Icons.palette), text: 'Branding'),
              Tab(icon: Icon(Icons.article), text: 'Content'),
              Tab(icon: Icon(Icons.share), text: 'Contact'),
              Tab(icon: Icon(Icons.settings), text: 'Settings'),
            ],
          ),
        ),
        body: BlocListener<WebsiteBloc, WebsiteState>(
          listener: (context, state) {
            if (state is WebsiteLoadedState) {
              _editingData = state.websiteData;
              setState(() {
                _isDataInitialized = true;
                _hasUnsavedChanges = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings saved successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is WebsiteUpdatedState) {
              _editingData = state.websiteData;
              setState(() {
                _hasUnsavedChanges = false;
              });
            } else if (state is WebsiteImageUploadedState) {
              _editingData = state.websiteData;
              setState(() {
                _hasUnsavedChanges = true;
                if (state.imageType == 'logo') {
                  _isLogoUploading = false;
                } else if (state.imageType == 'favicon') {
                  _isFaviconUploading = false;
                } else if (state.imageType == 'about_image') {
                  _isAboutImageUploading = false;
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${state.imageType} uploaded successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is WebsiteImageUploadingState) {
              setState(() {
                if (state.imageType == 'logo') {
                  _isLogoUploading = true;
                  _logoUploadProgress = state.progress;
                } else if (state.imageType == 'favicon') {
                  _isFaviconUploading = true;
                  _faviconUploadProgress = state.progress;
                } else if (state.imageType == 'about_image') {
                  _isAboutImageUploading = true;
                  _aboutImageUploadProgress = state.progress;
                }
              });
            } else if (state is WebsiteErrorState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message.replaceAll('\n', ' ')),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 4),
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
                  state is WebsiteUpdatedState ||
                  state is WebsiteImageUploadingState ||
                  state is WebsiteImageUploadedState ||
                  state is WebsiteSectionUpdatedState) {
                // Initialize editing data if needed
                if (state is WebsiteLoadedState && !_isDataInitialized) {
                  _editingData = state.websiteData;
                  _isDataInitialized = true;
                }

                return Form(
                  key: _formKey,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildBasicInfoTab(),
                      _buildBrandingTab(),
                      _buildContentTab(),
                      _buildContactTab(),
                      _buildSettingsTab(),
                    ],
                  ),
                );
              } else if (state is WebsiteErrorState) {
                return Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          margin: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.public,
                                size: 64,
                                color: Colors.grey.withValues(alpha: 0.4),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                state.message,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF1A1A1A),
                                  height: 1.6,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 220,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Check if error is about no restaurant
                              if (state.message.contains('Restaurant')) {
                                // Navigate to restaurant setup
                                Navigator.of(
                                  context,
                                ).pushNamed('/restaurant-setup');
                              } else {
                                // Retry loading
                                context.read<WebsiteBloc>().add(
                                  const FetchWebsiteDataEvent(),
                                );
                              }
                            },
                            icon: Icon(
                              state.message.contains('Restaurant')
                                  ? Icons.add
                                  : Icons.refresh,
                            ),
                            label: Text(
                              state.message.contains('Restaurant')
                                  ? 'Create Restaurant'
                                  : 'Retry',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6B35),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 14,
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return const Center(child: Text('No data available'));
            },
          ),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (_hasUnsavedChanges)
              FloatingActionButton(
                onPressed: _resetChanges,
                mini: true,
                backgroundColor: Colors.red,
                child: const Icon(Icons.close),
              ),
            const SizedBox(height: 8),
            FloatingActionButton(
              onPressed: _saveChanges,
              child: const Icon(Icons.save),
            ),
          ],
        ),
      ),
    );
  }

  // ================== TABS ==================

  Widget _buildBasicInfoTab() {
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
              prefixIcon: Icon(Icons.title),
            ),
            validator: WebsiteValidation.validateWebsiteTitle,
            onChanged: (value) {
              _editingData = _editingData.copyWith(websiteTitle: value);
              _markAsChanged();
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: _editingData.websiteDescription,
            decoration: const InputDecoration(
              labelText: 'Website Description',
              hintText: 'Enter a brief description for SEO',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description),
            ),
            maxLines: 3,
            validator: (value) => WebsiteValidation.validateContent(value),
            onChanged: (value) {
              _editingData = _editingData.copyWith(websiteDescription: value);
              _markAsChanged();
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: _editingData.websiteKeywords,
            decoration: const InputDecoration(
              labelText: 'SEO Keywords',
              hintText: 'Separate keywords with commas',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.tag),
            ),
            validator: (value) => WebsiteValidation.validateContent(value),
            onChanged: (value) {
              _editingData = _editingData.copyWith(websiteKeywords: value);
              _markAsChanged();
            },
          ),
          const SizedBox(height: 24),
          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Additional Information',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          // Hero Section
          TextFormField(
            initialValue: _editingData.heroTitle,
            decoration: const InputDecoration(
              labelText: 'Hero Title',
              hintText: 'Welcome to our restaurant',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.image),
            ),
            onChanged: (value) {
              _editingData = _editingData.copyWith(heroTitle: value);
              _markAsChanged();
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
            maxLines: 2,
            onChanged: (value) {
              _editingData = _editingData.copyWith(heroSubtitle: value);
              _markAsChanged();
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: _editingData.heroCTAButtonText,
            decoration: const InputDecoration(
              labelText: 'CTA Button Text',
              hintText: 'Order Now',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.touch_app),
            ),
            onChanged: (value) {
              _editingData = _editingData.copyWith(heroCTAButtonText: value);
              _markAsChanged();
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: _editingData.heroCTAButtonLink,
            decoration: const InputDecoration(
              labelText: 'CTA Button Link (Optional)',
              hintText: 'https://example.com/order',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.link),
            ),
            validator: WebsiteValidation.validateUrl,
            onChanged: (value) {
              _editingData = _editingData.copyWith(heroCTAButtonLink: value);
              _markAsChanged();
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildBrandingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Colors Section
          ColorPickerField(
            label: 'Primary Color',
            currentColorHex: _editingData.primaryColor,
            onColorChanged: (colorHex) {
              _editingData = _editingData.copyWith(primaryColor: colorHex);
              _markAsChanged();
            },
          ),
          const SizedBox(height: 24),
          ColorPickerField(
            label: 'Secondary Color',
            currentColorHex: _editingData.secondaryColor,
            onColorChanged: (colorHex) {
              _editingData = _editingData.copyWith(secondaryColor: colorHex);
              _markAsChanged();
            },
          ),
          const SizedBox(height: 32),
          // Images Section
          Text(
            'Branding Images',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          ImageUploadField(
            label: 'Logo',
            currentImageUrl: _editingData.logo,
            onImageSelected: (file) async {
              context.read<WebsiteBloc>().add(
                UploadWebsiteImageEvent(imageFile: file, imageType: 'logo'),
              );
            },
            isUploading: _isLogoUploading,
            uploadProgress: _logoUploadProgress,
            errorMessage: _logoUploadingError,
          ),
          const SizedBox(height: 24),
          ImageUploadField(
            label: 'Favicon',
            currentImageUrl: _editingData.favicon,
            onImageSelected: (file) async {
              context.read<WebsiteBloc>().add(
                UploadWebsiteImageEvent(imageFile: file, imageType: 'favicon'),
              );
            },
            isUploading: _isFaviconUploading,
            uploadProgress: _faviconUploadProgress,
            errorMessage: _faviconUploadingError,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildContentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // About Section
          Text('About Section', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: _editingData.aboutTitle,
            decoration: const InputDecoration(
              labelText: 'About Title',
              hintText: 'About Us',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.info),
            ),
            onChanged: (value) {
              _editingData = _editingData.copyWith(aboutTitle: value);
              _markAsChanged();
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
            maxLines: 6,
            validator: (value) => WebsiteValidation.validateContent(value),
            onChanged: (value) {
              _editingData = _editingData.copyWith(aboutContent: value);
              _markAsChanged();
            },
          ),
          const SizedBox(height: 16),
          ImageUploadField(
            label: 'About Image',
            currentImageUrl: _editingData.aboutImage,
            onImageSelected: (file) async {
              context.read<WebsiteBloc>().add(
                UploadWebsiteImageEvent(
                  imageFile: file,
                  imageType: 'about_image',
                ),
              );
            },
            isUploading: _isAboutImageUploading,
            uploadProgress: _aboutImageUploadProgress,
            errorMessage: _aboutImageUploadingError,
          ),
          const SizedBox(height: 32),
          // Features Section
          Text('Features', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          FeatureBlockCard(
            featureIndex: 0,
            title: _editingData.feature1Title,
            description: _editingData.feature1Description,
            icon: _editingData.feature1Icon,
            onFeatureChanged: (index, title, description, icon) {
              _editingData = _editingData.copyWith(
                feature1Title: title,
                feature1Description: description,
                feature1Icon: icon,
              );
              _markAsChanged();
            },
          ),
          const SizedBox(height: 16),
          FeatureBlockCard(
            featureIndex: 1,
            title: _editingData.feature2Title,
            description: _editingData.feature2Description,
            icon: _editingData.feature2Icon,
            onFeatureChanged: (index, title, description, icon) {
              _editingData = _editingData.copyWith(
                feature2Title: title,
                feature2Description: description,
                feature2Icon: icon,
              );
              _markAsChanged();
            },
          ),
          const SizedBox(height: 16),
          FeatureBlockCard(
            featureIndex: 2,
            title: _editingData.feature3Title,
            description: _editingData.feature3Description,
            icon: _editingData.feature3Icon,
            onFeatureChanged: (index, title, description, icon) {
              _editingData = _editingData.copyWith(
                feature3Title: title,
                feature3Description: description,
                feature3Icon: icon,
              );
              _markAsChanged();
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildContactTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Contact Information
          Text(
            'Contact Information',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          SocialLinkField(
            platform: 'contact_email',
            url: _editingData.contactEmail,
            icon: Icons.email,
            onChanged: (platform, url) {
              _editingData = _editingData.copyWith(contactEmail: url);
              _markAsChanged();
            },
          ),
          const SizedBox(height: 16),
          SocialLinkField(
            platform: 'contact_phone',
            url: _editingData.contactPhone,
            icon: Icons.phone,
            onChanged: (platform, url) {
              _editingData = _editingData.copyWith(contactPhone: url);
              _markAsChanged();
            },
          ),
          const SizedBox(height: 16),
          SocialLinkField(
            platform: 'contact_whatsapp',
            url: _editingData.contactWhatsapp,
            icon: Icons.message,
            onChanged: (platform, url) {
              _editingData = _editingData.copyWith(contactWhatsapp: url);
              _markAsChanged();
            },
          ),
          const SizedBox(height: 32),
          // Social Media Links
          Text('Social Media', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          SocialLinkField(
            platform: 'facebook',
            url: _editingData.facebookUrl,
            icon: Icons.facebook,
            onChanged: (platform, url) {
              _editingData = _editingData.copyWith(facebookUrl: url);
              _markAsChanged();
            },
          ),
          const SizedBox(height: 16),
          SocialLinkField(
            platform: 'instagram',
            url: _editingData.instagramUrl,
            icon: Icons.camera_alt,
            onChanged: (platform, url) {
              _editingData = _editingData.copyWith(instagramUrl: url);
              _markAsChanged();
            },
          ),
          const SizedBox(height: 16),
          SocialLinkField(
            platform: 'twitter',
            url: _editingData.twitterUrl,
            icon: Icons.tag,
            onChanged: (platform, url) {
              _editingData = _editingData.copyWith(twitterUrl: url);
              _markAsChanged();
            },
          ),
          const SizedBox(height: 16),
          SocialLinkField(
            platform: 'whatsapp',
            url: _editingData.whatsappNumber,
            icon: Icons.phone,
            onChanged: (platform, url) {
              _editingData = _editingData.copyWith(whatsappNumber: url);
              _markAsChanged();
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Feature Toggles
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Website Active'),
                  subtitle: const Text('Enable or disable your website'),
                  value: _editingData.isActive,
                  onChanged: (value) {
                    setState(() {
                      _editingData = _editingData.copyWith(isActive: value);
                      _markAsChanged();
                    });
                  },
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Show Menu Online'),
                  subtitle: const Text(
                    'Allow customers to view menu on website',
                  ),
                  value: _editingData.showMenuOnline,
                  onChanged: (value) {
                    setState(() {
                      _editingData = _editingData.copyWith(
                        showMenuOnline: value,
                      );
                      _markAsChanged();
                    });
                  },
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Show Reservations Online'),
                  subtitle: const Text('Allow customers to book tables online'),
                  value: _editingData.showReservationsOnline,
                  onChanged: (value) {
                    setState(() {
                      _editingData = _editingData.copyWith(
                        showReservationsOnline: value,
                      );
                      _markAsChanged();
                    });
                  },
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Enable Newsletter'),
                  subtitle: const Text('Allow customers to subscribe'),
                  value: _editingData.enableNewsletter,
                  onChanged: (value) {
                    setState(() {
                      _editingData = _editingData.copyWith(
                        enableNewsletter: value,
                      );
                      _markAsChanged();
                    });
                  },
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Enable Contact Form'),
                  subtitle: const Text('Allow customers to contact you'),
                  value: _editingData.enableContactForm,
                  onChanged: (value) {
                    setState(() {
                      _editingData = _editingData.copyWith(
                        enableContactForm: value,
                      );
                      _markAsChanged();
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Footer Text
          Text(
            'Footer Settings',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: _editingData.footerText,
            decoration: const InputDecoration(
              labelText: 'Footer Text',
              hintText: 'Copyright © 2024 Your Restaurant Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description),
            ),
            maxLines: 3,
            onChanged: (value) {
              _editingData = _editingData.copyWith(footerText: value);
              _markAsChanged();
            },
          ),
          const SizedBox(height: 32),
          // Additional Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📋 Website Information',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _infoRow('Created', _editingData.createdAt.toString()),
                _infoRow('Last Updated', _editingData.updatedAt.toString()),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
