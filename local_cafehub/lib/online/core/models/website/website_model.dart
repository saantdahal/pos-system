import 'package:json_annotation/json_annotation.dart';

part 'website_model.g.dart';

@JsonSerializable()
class WebsiteData {
  final String id;
  final String? websiteTitle;
  final String? websiteDescription;
  final String? websiteKeywords;
  final String? logo;
  final String? favicon;
  final String primaryColor;
  final String secondaryColor;
  final String? facebookUrl;
  final String? instagramUrl;
  final String? twitterUrl;
  final String? whatsappNumber;
  final String? contactEmail;
  final String? contactPhone;
  final String? contactWhatsapp;
  final String? heroTitle;
  final String? heroSubtitle;
  final String heroCTAButtonText;
  final String? heroCTAButtonLink;
  final String aboutTitle;
  final String? aboutContent;
  final String? aboutImage;
  final String? feature1Title;
  final String? feature1Description;
  final String? feature1Icon;
  final String? feature2Title;
  final String? feature2Description;
  final String? feature2Icon;
  final String? feature3Title;
  final String? feature3Description;
  final String? feature3Icon;
  final bool enableNewsletter;
  final bool enableContactForm;
  final String? footerText;
  final bool isActive;
  final bool showMenuOnline;
  final bool showReservationsOnline;
  final DateTime createdAt;
  final DateTime updatedAt;

  WebsiteData({
    required this.id,
    this.websiteTitle,
    this.websiteDescription,
    this.websiteKeywords,
    this.logo,
    this.favicon,
    required this.primaryColor,
    required this.secondaryColor,
    this.facebookUrl,
    this.instagramUrl,
    this.twitterUrl,
    this.whatsappNumber,
    this.contactEmail,
    this.contactPhone,
    this.contactWhatsapp,
    this.heroTitle,
    this.heroSubtitle,
    this.heroCTAButtonText = 'Order Now',
    this.heroCTAButtonLink,
    this.aboutTitle = 'About Us',
    this.aboutContent,
    this.aboutImage,
    this.feature1Title,
    this.feature1Description,
    this.feature1Icon,
    this.feature2Title,
    this.feature2Description,
    this.feature2Icon,
    this.feature3Title,
    this.feature3Description,
    this.feature3Icon,
    this.enableNewsletter = true,
    this.enableContactForm = true,
    this.footerText,
    this.isActive = true,
    this.showMenuOnline = true,
    this.showReservationsOnline = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WebsiteData.fromJson(Map<String, dynamic> json) =>
      _$WebsiteDataFromJson(json);

  Map<String, dynamic> toJson() => _$WebsiteDataToJson(this);

  WebsiteData copyWith({
    String? id,
    String? websiteTitle,
    String? websiteDescription,
    String? websiteKeywords,
    String? logo,
    String? favicon,
    String? primaryColor,
    String? secondaryColor,
    String? facebookUrl,
    String? instagramUrl,
    String? twitterUrl,
    String? whatsappNumber,
    String? contactEmail,
    String? contactPhone,
    String? contactWhatsapp,
    String? heroTitle,
    String? heroSubtitle,
    String? heroCTAButtonText,
    String? heroCTAButtonLink,
    String? aboutTitle,
    String? aboutContent,
    String? aboutImage,
    String? feature1Title,
    String? feature1Description,
    String? feature1Icon,
    String? feature2Title,
    String? feature2Description,
    String? feature2Icon,
    String? feature3Title,
    String? feature3Description,
    String? feature3Icon,
    bool? enableNewsletter,
    bool? enableContactForm,
    String? footerText,
    bool? isActive,
    bool? showMenuOnline,
    bool? showReservationsOnline,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WebsiteData(
      id: id ?? this.id,
      websiteTitle: websiteTitle ?? this.websiteTitle,
      websiteDescription: websiteDescription ?? this.websiteDescription,
      websiteKeywords: websiteKeywords ?? this.websiteKeywords,
      logo: logo ?? this.logo,
      favicon: favicon ?? this.favicon,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      facebookUrl: facebookUrl ?? this.facebookUrl,
      instagramUrl: instagramUrl ?? this.instagramUrl,
      twitterUrl: twitterUrl ?? this.twitterUrl,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      contactWhatsapp: contactWhatsapp ?? this.contactWhatsapp,
      heroTitle: heroTitle ?? this.heroTitle,
      heroSubtitle: heroSubtitle ?? this.heroSubtitle,
      heroCTAButtonText: heroCTAButtonText ?? this.heroCTAButtonText,
      heroCTAButtonLink: heroCTAButtonLink ?? this.heroCTAButtonLink,
      aboutTitle: aboutTitle ?? this.aboutTitle,
      aboutContent: aboutContent ?? this.aboutContent,
      aboutImage: aboutImage ?? this.aboutImage,
      feature1Title: feature1Title ?? this.feature1Title,
      feature1Description: feature1Description ?? this.feature1Description,
      feature1Icon: feature1Icon ?? this.feature1Icon,
      feature2Title: feature2Title ?? this.feature2Title,
      feature2Description: feature2Description ?? this.feature2Description,
      feature2Icon: feature2Icon ?? this.feature2Icon,
      feature3Title: feature3Title ?? this.feature3Title,
      feature3Description: feature3Description ?? this.feature3Description,
      feature3Icon: feature3Icon ?? this.feature3Icon,
      enableNewsletter: enableNewsletter ?? this.enableNewsletter,
      enableContactForm: enableContactForm ?? this.enableContactForm,
      footerText: footerText ?? this.footerText,
      isActive: isActive ?? this.isActive,
      showMenuOnline: showMenuOnline ?? this.showMenuOnline,
      showReservationsOnline:
          showReservationsOnline ?? this.showReservationsOnline,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
