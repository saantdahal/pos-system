import 'package:flutter/material.dart';

typedef OnSocialLinkChanged = void Function(String platform, String url);

class SocialLinkField extends StatefulWidget {
  final String platform;
  final String? url;
  final OnSocialLinkChanged onChanged;
  final IconData icon;

  const SocialLinkField({
    super.key,
    required this.platform,
    this.url,
    required this.onChanged,
    required this.icon,
  });

  @override
  State<SocialLinkField> createState() => _SocialLinkFieldState();
}

class _SocialLinkFieldState extends State<SocialLinkField> {
  late TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.url ?? '');
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  String _getPlatformLabel() {
    switch (widget.platform) {
      case 'facebook':
        return 'Facebook URL';
      case 'instagram':
        return 'Instagram URL';
      case 'twitter':
        return 'Twitter URL';
      case 'whatsapp':
        return 'WhatsApp Number';
      case 'contact_email':
        return 'Contact Email';
      case 'contact_phone':
        return 'Contact Phone';
      case 'contact_whatsapp':
        return 'Contact WhatsApp';
      default:
        return widget.platform.replaceAll('_', ' ').toUpperCase();
    }
  }

  String _getHintText() {
    switch (widget.platform) {
      case 'facebook':
        return 'https://facebook.com/yourpage';
      case 'instagram':
        return 'https://instagram.com/yourprofile';
      case 'twitter':
        return 'https://twitter.com/yourhandle';
      case 'whatsapp':
        return '+1 234 567 8900';
      case 'contact_email':
        return 'your@email.com';
      case 'contact_phone':
      case 'contact_whatsapp':
        return '+1 234 567 8900';
      default:
        return '';
    }
  }

  TextInputType _getKeyboardType() {
    switch (widget.platform) {
      case 'contact_email':
        return TextInputType.emailAddress;
      case 'facebook':
      case 'instagram':
      case 'twitter':
        return TextInputType.url;
      default:
        return TextInputType.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _urlController,
      decoration: InputDecoration(
        labelText: _getPlatformLabel(),
        hintText: _getHintText(),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: Icon(widget.icon),
        suffixIcon: _urlController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _urlController.clear();
                  widget.onChanged(widget.platform, '');
                  setState(() {});
                },
              )
            : null,
      ),
      keyboardType: _getKeyboardType(),
      onChanged: (value) {
        widget.onChanged(widget.platform, value);
        setState(() {});
      },
      validator: (value) {
        if (value == null || value.isEmpty) return null;

        if (widget.platform == 'contact_email') {
          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
          if (!emailRegex.hasMatch(value)) {
            return 'Please enter a valid email address';
          }
        } else if (widget.platform.contains('url') ||
            widget.platform == 'facebook' ||
            widget.platform == 'instagram' ||
            widget.platform == 'twitter') {
          final urlRegex = RegExp(r'^https?://', caseSensitive: false);
          if (!urlRegex.hasMatch(value)) {
            return 'Please enter a valid URL (start with http:// or https://)';
          }
        }
        return null;
      },
    );
  }
}
