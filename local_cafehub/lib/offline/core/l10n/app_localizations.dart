import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ne.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ne'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Bhansa Ghar'**
  String get appTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @guidanceTitle.
  ///
  /// In en, this message translates to:
  /// **'App Guidance'**
  String get guidanceTitle;

  /// No description provided for @initialSetup.
  ///
  /// In en, this message translates to:
  /// **'1. Initial Setup'**
  String get initialSetup;

  /// No description provided for @initialSetupStep1.
  ///
  /// In en, this message translates to:
  /// **'Allow Notification Permissions when prompted to receive order updates.'**
  String get initialSetupStep1;

  /// No description provided for @initialSetupStep2.
  ///
  /// In en, this message translates to:
  /// **'Set Battery Saver to \"No Restrictions\" for this app in your device settings. This ensures the server runs smoothly in the background.'**
  String get initialSetupStep2;

  /// No description provided for @prepareCafe.
  ///
  /// In en, this message translates to:
  /// **'2. Prepare Your Cafe'**
  String get prepareCafe;

  /// No description provided for @prepareCafeStep1.
  ///
  /// In en, this message translates to:
  /// **'Go to the appropriate sections to add your Categories and Menu Items.'**
  String get prepareCafeStep1;

  /// No description provided for @prepareCafeStep2.
  ///
  /// In en, this message translates to:
  /// **'Define the Number of Tables available in your cafe/restaurant from the Settings.'**
  String get prepareCafeStep2;

  /// No description provided for @startServing.
  ///
  /// In en, this message translates to:
  /// **'3. Start Serving'**
  String get startServing;

  /// No description provided for @startServingStep1.
  ///
  /// In en, this message translates to:
  /// **'Ensure both the Admin device (this phone) and Customer devices are connected to the SAME WiFi network.'**
  String get startServingStep1;

  /// No description provided for @startServingStep2.
  ///
  /// In en, this message translates to:
  /// **'Go to Settings and toggle \"Web Server\" to ON.'**
  String get startServingStep2;

  /// No description provided for @startServingStep3.
  ///
  /// In en, this message translates to:
  /// **'Navigate to the QR Section to generate a QR code for your menu.'**
  String get startServingStep3;

  /// No description provided for @startServingStep4.
  ///
  /// In en, this message translates to:
  /// **'You can also generate a QR code for your WiFi credentials to help customers connect easily.'**
  String get startServingStep4;

  /// No description provided for @customerExperience.
  ///
  /// In en, this message translates to:
  /// **'4. Customer Experience'**
  String get customerExperience;

  /// No description provided for @customerExperienceStep1.
  ///
  /// In en, this message translates to:
  /// **'Customers scan the Menu QR code to open the Web App.'**
  String get customerExperienceStep1;

  /// No description provided for @customerExperienceStep2.
  ///
  /// In en, this message translates to:
  /// **'Note: If the QR code doesn\'t work, they can manually enter the URL displayed in the Server section into their browser.'**
  String get customerExperienceStep2;

  /// No description provided for @customerExperienceStep3.
  ///
  /// In en, this message translates to:
  /// **'Customers can browse the menu, add items to cart, and place orders.'**
  String get customerExperienceStep3;

  /// No description provided for @customerExperienceStep4.
  ///
  /// In en, this message translates to:
  /// **'They can also track the status of their orders in real-time.'**
  String get customerExperienceStep4;

  /// No description provided for @orderManagement.
  ///
  /// In en, this message translates to:
  /// **'5. Order Management'**
  String get orderManagement;

  /// No description provided for @orderManagementStep1.
  ///
  /// In en, this message translates to:
  /// **'Admins receive orders instantly on this device.'**
  String get orderManagementStep1;

  /// No description provided for @orderManagementStep2.
  ///
  /// In en, this message translates to:
  /// **'Use the Negotiation Feature to adjust quantities if stock is low or initiate a discussion with the customer.'**
  String get orderManagementStep2;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Bhansa Ghar'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Follow these steps to set up your digital ordering system.'**
  String get welcomeSubtitle;

  /// No description provided for @needHelp.
  ///
  /// In en, this message translates to:
  /// **'Need Help?'**
  String get needHelp;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'For additional information or support, please contact:'**
  String get contactSupport;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @changeLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get changeLanguageSubtitle;

  /// No description provided for @server.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get server;

  /// No description provided for @webServer.
  ///
  /// In en, this message translates to:
  /// **'Web Server'**
  String get webServer;

  /// No description provided for @startingServer.
  ///
  /// In en, this message translates to:
  /// **'Starting server...'**
  String get startingServer;

  /// No description provided for @stoppingServer.
  ///
  /// In en, this message translates to:
  /// **'Stopping server...'**
  String get stoppingServer;

  /// No description provided for @runningAt.
  ///
  /// In en, this message translates to:
  /// **'Running at'**
  String get runningAt;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Error:'**
  String get serverError;

  /// No description provided for @serverOffline.
  ///
  /// In en, this message translates to:
  /// **'Server is offline'**
  String get serverOffline;

  /// No description provided for @stopServerTitle.
  ///
  /// In en, this message translates to:
  /// **'Stop Server?'**
  String get stopServerTitle;

  /// No description provided for @stopServerMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to stop the web server? Users will no longer be able to access the menu.'**
  String get stopServerMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @guidance.
  ///
  /// In en, this message translates to:
  /// **'Guidance'**
  String get guidance;

  /// No description provided for @tableManagement.
  ///
  /// In en, this message translates to:
  /// **'Table Management'**
  String get tableManagement;

  /// No description provided for @manageTables.
  ///
  /// In en, this message translates to:
  /// **'Manage Tables'**
  String get manageTables;

  /// No description provided for @noTablesConfigured.
  ///
  /// In en, this message translates to:
  /// **'No tables configured. Please add tables in settings.'**
  String get noTablesConfigured;

  /// No description provided for @tableConfigured.
  ///
  /// In en, this message translates to:
  /// **'table configured'**
  String get tableConfigured;

  /// No description provided for @tablesConfigured.
  ///
  /// In en, this message translates to:
  /// **'tables configured'**
  String get tablesConfigured;

  /// No description provided for @successfullySetTables.
  ///
  /// In en, this message translates to:
  /// **'Successfully set'**
  String get successfullySetTables;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @currentlyUsingDarkTheme.
  ///
  /// In en, this message translates to:
  /// **'Currently using dark theme'**
  String get currentlyUsingDarkTheme;

  /// No description provided for @currentlyUsingLightTheme.
  ///
  /// In en, this message translates to:
  /// **'Currently using light theme'**
  String get currentlyUsingLightTheme;

  /// No description provided for @credentials.
  ///
  /// In en, this message translates to:
  /// **'Credentials'**
  String get credentials;

  /// No description provided for @setupPin.
  ///
  /// In en, this message translates to:
  /// **'Setup PIN'**
  String get setupPin;

  /// No description provided for @setNewPin.
  ///
  /// In en, this message translates to:
  /// **'Set a new 4-digit PIN'**
  String get setNewPin;

  /// No description provided for @changePin.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get changePin;

  /// No description provided for @updatePin.
  ///
  /// In en, this message translates to:
  /// **'Update your 4-digit login PIN'**
  String get updatePin;

  /// No description provided for @turnOffPin.
  ///
  /// In en, this message translates to:
  /// **'Turn Off PIN'**
  String get turnOffPin;

  /// No description provided for @removePinSecurity.
  ///
  /// In en, this message translates to:
  /// **'Remove PIN security'**
  String get removePinSecurity;

  /// No description provided for @turnOffPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn Off PIN?'**
  String get turnOffPinTitle;

  /// No description provided for @turnOffPinMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove the PIN lock? Anyone will be able to access the app.'**
  String get turnOffPinMessage;

  /// No description provided for @turnOffPinMessageWithBiometric.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove the PIN lock? This will also disable biometric authentication. Anyone will be able to access the app.'**
  String get turnOffPinMessageWithBiometric;

  /// No description provided for @turnOff.
  ///
  /// In en, this message translates to:
  /// **'Turn Off'**
  String get turnOff;

  /// No description provided for @biometrics.
  ///
  /// In en, this message translates to:
  /// **'Biometrics'**
  String get biometrics;

  /// No description provided for @enableBiometricLogin.
  ///
  /// In en, this message translates to:
  /// **'Enable Biometric Login'**
  String get enableBiometricLogin;

  /// No description provided for @biometricSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint or Face ID for quick access'**
  String get biometricSubtitle;

  /// No description provided for @biometricNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not available on this device'**
  String get biometricNotAvailable;

  /// No description provided for @biometricNotAvailableMessage.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication is not available on this device'**
  String get biometricNotAvailableMessage;

  /// No description provided for @biometricEnabled.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication enabled'**
  String get biometricEnabled;

  /// No description provided for @biometricFailed.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication failed'**
  String get biometricFailed;

  /// No description provided for @disableBiometricTitle.
  ///
  /// In en, this message translates to:
  /// **'Disable Biometric Authentication?'**
  String get disableBiometricTitle;

  /// No description provided for @disableBiometricMessage.
  ///
  /// In en, this message translates to:
  /// **'You will need to use your PIN to unlock the app.'**
  String get disableBiometricMessage;

  /// No description provided for @disable.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get disable;

  /// No description provided for @biometricDisabled.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication disabled'**
  String get biometricDisabled;

  /// No description provided for @importExport.
  ///
  /// In en, this message translates to:
  /// **'Import & Export'**
  String get importExport;

  /// No description provided for @importData.
  ///
  /// In en, this message translates to:
  /// **'Import Data'**
  String get importData;

  /// No description provided for @importDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Import categories and menu items'**
  String get importDataSubtitle;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// No description provided for @exportDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Backup categories and menu items'**
  String get exportDataSubtitle;

  /// No description provided for @fileSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'File saved successfully'**
  String get fileSavedSuccessfully;

  /// No description provided for @importedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Imported'**
  String get importedSuccess;

  /// No description provided for @categoriesAnd.
  ///
  /// In en, this message translates to:
  /// **'categories and'**
  String get categoriesAnd;

  /// No description provided for @menuItems.
  ///
  /// In en, this message translates to:
  /// **'menu items'**
  String get menuItems;

  /// No description provided for @failedToReadFile.
  ///
  /// In en, this message translates to:
  /// **'Failed to read file:'**
  String get failedToReadFile;

  /// No description provided for @shareNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Share not available:'**
  String get shareNotAvailable;

  /// No description provided for @exportSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Export it !'**
  String get exportSuccessTitle;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @importDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Data?'**
  String get importDataTitle;

  /// No description provided for @replaceExistingData.
  ///
  /// In en, this message translates to:
  /// **'This will replace all existing data'**
  String get replaceExistingData;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @addNewCategory.
  ///
  /// In en, this message translates to:
  /// **'Add New Category'**
  String get addNewCategory;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get editCategory;

  /// No description provided for @enterCategoryDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter a name for the new menu category.'**
  String get enterCategoryDescription;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get categoryName;

  /// No description provided for @categoryNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Desserts'**
  String get categoryNameHint;

  /// No description provided for @pleaseEnterCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a category name'**
  String get pleaseEnterCategoryName;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @atAGlance.
  ///
  /// In en, this message translates to:
  /// **'At a Glance'**
  String get atAGlance;

  /// No description provided for @activeOrders.
  ///
  /// In en, this message translates to:
  /// **'Active Orders'**
  String get activeOrders;

  /// No description provided for @pendingOrders.
  ///
  /// In en, this message translates to:
  /// **'Pending Orders'**
  String get pendingOrders;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @qrCodes.
  ///
  /// In en, this message translates to:
  /// **'QR Codes'**
  String get qrCodes;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @manageCategories.
  ///
  /// In en, this message translates to:
  /// **'Manage Categories'**
  String get manageCategories;

  /// No description provided for @manageCategoriesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add or edit menu categories'**
  String get manageCategoriesSubtitle;

  /// No description provided for @generateQrCodes.
  ///
  /// In en, this message translates to:
  /// **'Generate QR Codes'**
  String get generateQrCodes;

  /// No description provided for @cafeGuestWifi.
  ///
  /// In en, this message translates to:
  /// **'Café Guest Wi-Fi'**
  String get cafeGuestWifi;

  /// No description provided for @connectCustomersToInternet.
  ///
  /// In en, this message translates to:
  /// **'Connect your customers to the internet.'**
  String get connectCustomersToInternet;

  /// No description provided for @digitalMenu.
  ///
  /// In en, this message translates to:
  /// **'Digital Menu'**
  String get digitalMenu;

  /// No description provided for @linkCustomersToMenu.
  ///
  /// In en, this message translates to:
  /// **'Link customers to your online menu.'**
  String get linkCustomersToMenu;

  /// No description provided for @generateWifiQr.
  ///
  /// In en, this message translates to:
  /// **'Generate WiFi QR'**
  String get generateWifiQr;

  /// No description provided for @generateMenuQr.
  ///
  /// In en, this message translates to:
  /// **'Generate Menu QR'**
  String get generateMenuQr;

  /// No description provided for @foriPhoneiPadUsers.
  ///
  /// In en, this message translates to:
  /// **'For iPhone/iPad Users'**
  String get foriPhoneiPadUsers;

  /// No description provided for @sslErrorInstructions.
  ///
  /// In en, this message translates to:
  /// **'If scanning the QR code shows an SSL error, manually enter this URL in Safari:'**
  String get sslErrorInstructions;

  /// No description provided for @generateMenuQrFirst.
  ///
  /// In en, this message translates to:
  /// **'Generate the Menu QR code first to see the URL'**
  String get generateMenuQrFirst;

  /// No description provided for @pleaseStartServerFirst.
  ///
  /// In en, this message translates to:
  /// **'Please start the server first from Settings'**
  String get pleaseStartServerFirst;

  /// No description provided for @noQrCodeGenerated.
  ///
  /// In en, this message translates to:
  /// **'No QR Code Generated'**
  String get noQrCodeGenerated;

  /// No description provided for @qrCodeSavedTo.
  ///
  /// In en, this message translates to:
  /// **'QR Code saved to:'**
  String get qrCodeSavedTo;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @errorSavingQrCode.
  ///
  /// In en, this message translates to:
  /// **'Error saving QR Code:'**
  String get errorSavingQrCode;

  /// No description provided for @errorSharingQrCode.
  ///
  /// In en, this message translates to:
  /// **'Error sharing QR Code:'**
  String get errorSharingQrCode;

  /// No description provided for @saveAndShareQrCode.
  ///
  /// In en, this message translates to:
  /// **'Save and share this QR code. Place it on tables or near the counter for easy access.'**
  String get saveAndShareQrCode;

  /// No description provided for @tapButtonToGenerateQr.
  ///
  /// In en, this message translates to:
  /// **'Tap the button above to generate a QR code.'**
  String get tapButtonToGenerateQr;

  /// No description provided for @wifiQrCode.
  ///
  /// In en, this message translates to:
  /// **'WiFi QR Code'**
  String get wifiQrCode;

  /// No description provided for @enterWifiCredentials.
  ///
  /// In en, this message translates to:
  /// **'Enter your WiFi credentials'**
  String get enterWifiCredentials;

  /// No description provided for @networkNameSsid.
  ///
  /// In en, this message translates to:
  /// **'Network Name (SSID)'**
  String get networkNameSsid;

  /// No description provided for @networkNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Café WiFi'**
  String get networkNameHint;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterWifiPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter WiFi password'**
  String get enterWifiPassword;

  /// No description provided for @generate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get generate;

  /// No description provided for @categoryNameEnglish.
  ///
  /// In en, this message translates to:
  /// **'Category Name (English)'**
  String get categoryNameEnglish;

  /// No description provided for @categoryNameNepali.
  ///
  /// In en, this message translates to:
  /// **'Category Name (Nepali)'**
  String get categoryNameNepali;

  /// No description provided for @menuItemNameEnglish.
  ///
  /// In en, this message translates to:
  /// **'Menu Item Name (English)'**
  String get menuItemNameEnglish;

  /// No description provided for @menuItemNameNepali.
  ///
  /// In en, this message translates to:
  /// **'Menu Item Name (Nepali)'**
  String get menuItemNameNepali;

  /// No description provided for @pleaseEnterBothLanguages.
  ///
  /// In en, this message translates to:
  /// **'Please enter names in both languages'**
  String get pleaseEnterBothLanguages;

  /// No description provided for @categoryNameEnglishHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Desserts'**
  String get categoryNameEnglishHint;

  /// No description provided for @categoryNameNepaliHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., मिठाई'**
  String get categoryNameNepaliHint;

  /// No description provided for @menuItemNameEnglishHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Coffee'**
  String get menuItemNameEnglishHint;

  /// No description provided for @menuItemNameNepaliHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., कफी'**
  String get menuItemNameNepaliHint;

  /// No description provided for @noCategoriesYet.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get noCategoriesYet;

  /// No description provided for @tapPlusToAddCategory.
  ///
  /// In en, this message translates to:
  /// **'Tap the \'+\' button to add a new category.'**
  String get tapPlusToAddCategory;

  /// No description provided for @deleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Delete Category'**
  String get deleteCategory;

  /// No description provided for @confirmDeleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete'**
  String get confirmDeleteCategory;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @menuManagement.
  ///
  /// In en, this message translates to:
  /// **'Menu Management'**
  String get menuManagement;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @noItemsInCategory.
  ///
  /// In en, this message translates to:
  /// **'No items in this category'**
  String get noItemsInCategory;

  /// No description provided for @tapPlusToAddItem.
  ///
  /// In en, this message translates to:
  /// **'Tap the \'+\' button to add a new item.'**
  String get tapPlusToAddItem;

  /// No description provided for @unsupportedFileFormat.
  ///
  /// In en, this message translates to:
  /// **'Unsupported file format'**
  String get unsupportedFileFormat;

  /// No description provided for @importedCategoriesAndItems.
  ///
  /// In en, this message translates to:
  /// **'Imported {categoriesCount} categories and {menuItemsCount} menu items'**
  String importedCategoriesAndItems(
    Object categoriesCount,
    Object menuItemsCount,
  );

  /// No description provided for @failedToGenerateExcel.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate Excel file'**
  String get failedToGenerateExcel;

  /// No description provided for @failedToExportToExcel.
  ///
  /// In en, this message translates to:
  /// **'Failed to export to Excel'**
  String get failedToExportToExcel;

  /// No description provided for @fileDoesNotExist.
  ///
  /// In en, this message translates to:
  /// **'File does not exist'**
  String get fileDoesNotExist;

  /// No description provided for @missingCategoriesSheet.
  ///
  /// In en, this message translates to:
  /// **'Missing \"Categories\" sheet'**
  String get missingCategoriesSheet;

  /// No description provided for @missingMenuItemsSheet.
  ///
  /// In en, this message translates to:
  /// **'Missing \"Menu Items\" sheet'**
  String get missingMenuItemsSheet;

  /// No description provided for @categoryIdCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Category ID cannot be empty at row {row}'**
  String categoryIdCannotBeEmpty(Object row);

  /// No description provided for @categoryNamesCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Category names cannot be empty at row {row}'**
  String categoryNamesCannotBeEmpty(Object row);

  /// No description provided for @menuItemIdCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Menu item ID cannot be empty at row {row}'**
  String menuItemIdCannotBeEmpty(Object row);

  /// No description provided for @menuItemNamesCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Menu item names cannot be empty at row {row}'**
  String menuItemNamesCannotBeEmpty(Object row);

  /// No description provided for @invalidPriceAtRow.
  ///
  /// In en, this message translates to:
  /// **'Invalid price for menu item at row {row}'**
  String invalidPriceAtRow(Object row);

  /// No description provided for @menuItemCategoryCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Menu item category cannot be empty at row {row}'**
  String menuItemCategoryCannotBeEmpty(Object row);

  /// No description provided for @menuItemReferencesNonExistentCategory.
  ///
  /// In en, this message translates to:
  /// **'Menu item \"{itemName}\" references non-existent category ID \"{categoryId}\"'**
  String menuItemReferencesNonExistentCategory(
    Object categoryId,
    Object itemName,
  );

  /// No description provided for @invalidExcelFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid Excel format'**
  String get invalidExcelFormat;

  /// No description provided for @failedToImportFromExcel.
  ///
  /// In en, this message translates to:
  /// **'Failed to import from Excel'**
  String get failedToImportFromExcel;

  /// No description provided for @failedToSaveJsonFile.
  ///
  /// In en, this message translates to:
  /// **'Failed to save JSON file'**
  String get failedToSaveJsonFile;

  /// No description provided for @failedToShareFile.
  ///
  /// In en, this message translates to:
  /// **'Failed to share file'**
  String get failedToShareFile;

  /// No description provided for @failedToPickFile.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick file'**
  String get failedToPickFile;

  /// No description provided for @invalidJsonFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid JSON format'**
  String get invalidJsonFormat;

  /// No description provided for @failedToImportData.
  ///
  /// In en, this message translates to:
  /// **'Failed to import data'**
  String get failedToImportData;

  /// No description provided for @missingVersionField.
  ///
  /// In en, this message translates to:
  /// **'Missing version field'**
  String get missingVersionField;

  /// No description provided for @missingExportDateField.
  ///
  /// In en, this message translates to:
  /// **'Missing exportDate field'**
  String get missingExportDateField;

  /// No description provided for @missingCategoriesField.
  ///
  /// In en, this message translates to:
  /// **'Missing categories field'**
  String get missingCategoriesField;

  /// No description provided for @missingMenuItemsField.
  ///
  /// In en, this message translates to:
  /// **'Missing menuItems field'**
  String get missingMenuItemsField;

  /// No description provided for @categoriesMustBeArray.
  ///
  /// In en, this message translates to:
  /// **'Categories must be an array'**
  String get categoriesMustBeArray;

  /// No description provided for @menuItemsMustBeArray.
  ///
  /// In en, this message translates to:
  /// **'MenuItems must be an array'**
  String get menuItemsMustBeArray;

  /// No description provided for @addNewMenuItem.
  ///
  /// In en, this message translates to:
  /// **'Add New Menu Item'**
  String get addNewMenuItem;

  /// No description provided for @editMenuItem.
  ///
  /// In en, this message translates to:
  /// **'Edit Menu Item'**
  String get editMenuItem;

  /// No description provided for @titleEnglish.
  ///
  /// In en, this message translates to:
  /// **'Title (English)'**
  String get titleEnglish;

  /// No description provided for @titleNepali.
  ///
  /// In en, this message translates to:
  /// **'Title (Nepali)'**
  String get titleNepali;

  /// No description provided for @titleEnglishHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Avocado Toast'**
  String get titleEnglishHint;

  /// No description provided for @titleNepaliHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. एभोकाडो टोस्ट'**
  String get titleNepaliHint;

  /// No description provided for @image.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get image;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @priceHint.
  ///
  /// In en, this message translates to:
  /// **'Rs 0.00'**
  String get priceHint;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select a category'**
  String get selectCategory;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItem;

  /// No description provided for @clickToUpload.
  ///
  /// In en, this message translates to:
  /// **'Click to upload'**
  String get clickToUpload;

  /// No description provided for @imageFormatSize.
  ///
  /// In en, this message translates to:
  /// **'PNG or JPG (MAX. 1MB)'**
  String get imageFormatSize;

  /// No description provided for @imageSizeTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Image size must be less than 1MB'**
  String get imageSizeTooLarge;

  /// No description provided for @pleaseEnterMenuItemNames.
  ///
  /// In en, this message translates to:
  /// **'Please enter menu item name in both languages'**
  String get pleaseEnterMenuItemNames;

  /// No description provided for @pleaseEnterPrice.
  ///
  /// In en, this message translates to:
  /// **'Please enter a price'**
  String get pleaseEnterPrice;

  /// No description provided for @pleaseEnterValidPrice.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid price greater than 0'**
  String get pleaseEnterValidPrice;

  /// No description provided for @pleaseSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get pleaseSelectCategory;

  /// No description provided for @numberOfTables.
  ///
  /// In en, this message translates to:
  /// **'Number of Tables'**
  String get numberOfTables;

  /// No description provided for @numberOfTablesHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 10'**
  String get numberOfTablesHint;

  /// No description provided for @enterNumberOfTables.
  ///
  /// In en, this message translates to:
  /// **'Enter the number of tables in your restaurant.'**
  String get enterNumberOfTables;

  /// No description provided for @tablesWillBeNumbered.
  ///
  /// In en, this message translates to:
  /// **'Tables will be numbered as Table 1, Table 2, etc.'**
  String get tablesWillBeNumbered;

  /// No description provided for @pleaseEnterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number greater than 0'**
  String get pleaseEnterValidNumber;

  /// No description provided for @maximumTablesAllowed.
  ///
  /// In en, this message translates to:
  /// **'Maximum 100 tables allowed'**
  String get maximumTablesAllowed;

  /// No description provided for @selectTable.
  ///
  /// In en, this message translates to:
  /// **'Select Table'**
  String get selectTable;

  /// No description provided for @noTable.
  ///
  /// In en, this message translates to:
  /// **'No Table'**
  String get noTable;

  /// No description provided for @table.
  ///
  /// In en, this message translates to:
  /// **'Table'**
  String get table;

  /// No description provided for @letsSecureYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Secure Your\nAccount'**
  String get letsSecureYourAccount;

  /// No description provided for @pinSetupWelcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'To keep your cafe\'s data safe, we\'ll\nguide you through setting up a\nsecure PIN and an option for\nbiometric login.'**
  String get pinSetupWelcomeMessage;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @createYourPin.
  ///
  /// In en, this message translates to:
  /// **'Create Your PIN'**
  String get createYourPin;

  /// No description provided for @enterFourDigitPin.
  ///
  /// In en, this message translates to:
  /// **'Enter a 4-digit PIN'**
  String get enterFourDigitPin;

  /// No description provided for @confirmYourPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm Your PIN'**
  String get confirmYourPin;

  /// No description provided for @reenterPinToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your PIN to confirm'**
  String get reenterPinToConfirm;

  /// No description provided for @pinCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'PIN Created\nSuccessfully!'**
  String get pinCreatedSuccessfully;

  /// No description provided for @pinCreatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your account is now secure.\nYou can use this PIN to access\nyour cafe management system.'**
  String get pinCreatedMessage;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @enterPinToLogin.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN to login'**
  String get enterPinToLogin;

  /// No description provided for @enterPin.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get enterPin;

  /// No description provided for @pleaseEnterFourDigitPin.
  ///
  /// In en, this message translates to:
  /// **'Please enter your 4-digit PIN'**
  String get pleaseEnterFourDigitPin;

  /// No description provided for @pinsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'PINs do not match. Please try again.'**
  String get pinsDoNotMatch;

  /// No description provided for @verifyOldPin.
  ///
  /// In en, this message translates to:
  /// **'Verify Old PIN'**
  String get verifyOldPin;

  /// No description provided for @enterCurrentPin.
  ///
  /// In en, this message translates to:
  /// **'Enter your current PIN'**
  String get enterCurrentPin;

  /// No description provided for @adminAccess.
  ///
  /// In en, this message translates to:
  /// **'Admin Access'**
  String get adminAccess;

  /// No description provided for @confirmIdentityToContinue.
  ///
  /// In en, this message translates to:
  /// **'Confirm your identity to continue'**
  String get confirmIdentityToContinue;

  /// No description provided for @tapToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Tap to Unlock'**
  String get tapToUnlock;

  /// No description provided for @useFingerprintOrFaceId.
  ///
  /// In en, this message translates to:
  /// **'Use Fingerprint or Face ID'**
  String get useFingerprintOrFaceId;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @usePinPassword.
  ///
  /// In en, this message translates to:
  /// **'Use PIN / Password'**
  String get usePinPassword;

  /// No description provided for @incorrectPin.
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN'**
  String get incorrectPin;

  /// No description provided for @failedToVerifyPin.
  ///
  /// In en, this message translates to:
  /// **'Failed to verify PIN'**
  String get failedToVerifyPin;

  /// No description provided for @failedToSetPin.
  ///
  /// In en, this message translates to:
  /// **'Failed to set PIN'**
  String get failedToSetPin;

  /// No description provided for @failedToDisablePin.
  ///
  /// In en, this message translates to:
  /// **'Failed to disable PIN'**
  String get failedToDisablePin;

  /// No description provided for @biometricAuthFailed.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication failed'**
  String get biometricAuthFailed;

  /// No description provided for @biometricAuthError.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication error'**
  String get biometricAuthError;

  /// No description provided for @failedToUpdateBiometric.
  ///
  /// In en, this message translates to:
  /// **'Failed to update biometric setting'**
  String get failedToUpdateBiometric;

  /// No description provided for @failedToDisableBiometric.
  ///
  /// In en, this message translates to:
  /// **'Failed to disable biometric'**
  String get failedToDisableBiometric;

  /// No description provided for @brewingSomethingSpecial.
  ///
  /// In en, this message translates to:
  /// **'Brewing up something\nspecial...'**
  String get brewingSomethingSpecial;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsRead;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @errorLoadingNotifications.
  ///
  /// In en, this message translates to:
  /// **'Error loading notifications'**
  String get errorLoadingNotifications;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @allCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up!'**
  String get allCaughtUp;

  /// No description provided for @unreadNotification.
  ///
  /// In en, this message translates to:
  /// **'{count} unread notification'**
  String unreadNotification(int count);

  /// No description provided for @unreadNotifications.
  ///
  /// In en, this message translates to:
  /// **'{count} unread notifications'**
  String unreadNotifications(int count);

  /// No description provided for @notificationRemoved.
  ///
  /// In en, this message translates to:
  /// **'Notification removed'**
  String get notificationRemoved;

  /// No description provided for @clearAllNotifications.
  ///
  /// In en, this message translates to:
  /// **'Clear All Notifications'**
  String get clearAllNotifications;

  /// No description provided for @clearAllNotificationsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all notifications? This action cannot be undone.'**
  String get clearAllNotificationsConfirm;

  /// No description provided for @liveOrders.
  ///
  /// In en, this message translates to:
  /// **'Live Orders'**
  String get liveOrders;

  /// No description provided for @oldestFirst.
  ///
  /// In en, this message translates to:
  /// **'Oldest First'**
  String get oldestFirst;

  /// No description provided for @newestFirst.
  ///
  /// In en, this message translates to:
  /// **'Newest First'**
  String get newestFirst;

  /// No description provided for @clearAllFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAllFilters;

  /// No description provided for @noMatchingOrders.
  ///
  /// In en, this message translates to:
  /// **'No matching orders'**
  String get noMatchingOrders;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load More'**
  String get loadMore;

  /// No description provided for @noOrdersYet.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get noOrdersYet;

  /// No description provided for @filterOrders.
  ///
  /// In en, this message translates to:
  /// **'Filter Orders'**
  String get filterOrders;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get sortBy;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @received.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get received;

  /// No description provided for @preparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get preparing;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ready;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @noTablesActive.
  ///
  /// In en, this message translates to:
  /// **'No tables active'**
  String get noTablesActive;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @orderHash.
  ///
  /// In en, this message translates to:
  /// **'Order #{id}'**
  String orderHash(String id);

  /// No description provided for @newBadge.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get newBadge;

  /// No description provided for @proposed.
  ///
  /// In en, this message translates to:
  /// **'Proposed: {quantity}×'**
  String proposed(int quantity);

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @needsConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Needs Confirmation'**
  String get needsConfirmation;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @cancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Cancel Order'**
  String get cancelOrder;

  /// No description provided for @cancelOrderConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this order?'**
  String get cancelOrderConfirm;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @yesCancel.
  ///
  /// In en, this message translates to:
  /// **'Yes, Cancel'**
  String get yesCancel;

  /// No description provided for @newOrder.
  ///
  /// In en, this message translates to:
  /// **'New Order'**
  String get newOrder;

  /// No description provided for @newOrderReceived.
  ///
  /// In en, this message translates to:
  /// **'New Order Received'**
  String get newOrderReceived;

  /// No description provided for @tableOrderMessage.
  ///
  /// In en, this message translates to:
  /// **'Table {tableNumber} placed a new order: {items}'**
  String tableOrderMessage(String tableNumber, String items);

  /// No description provided for @unknownTable.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownTable;

  /// No description provided for @voiceAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'Voice Announcements'**
  String get voiceAnnouncements;

  /// No description provided for @enableVoiceAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'Enable Voice Announcements'**
  String get enableVoiceAnnouncements;

  /// No description provided for @speechRate.
  ///
  /// In en, this message translates to:
  /// **'Speech Rate'**
  String get speechRate;

  /// No description provided for @volume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volume;

  /// No description provided for @pitch.
  ///
  /// In en, this message translates to:
  /// **'Pitch'**
  String get pitch;

  /// No description provided for @newOrderAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'New order received. Table {tableNumber}. Items: {items}'**
  String newOrderAnnouncement(String tableNumber, String items);

  /// No description provided for @orderReadyAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Order number {orderId} is ready.'**
  String orderReadyAnnouncement(String orderId);

  /// No description provided for @orderCompletedAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Order number {orderId} is completed.'**
  String orderCompletedAnnouncement(String orderId);

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @testVoice.
  ///
  /// In en, this message translates to:
  /// **'Test Voice'**
  String get testVoice;

  /// No description provided for @testVoiceMessage.
  ///
  /// In en, this message translates to:
  /// **'This is a test of the voice announcement system.'**
  String get testVoiceMessage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ne'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ne':
      return AppLocalizationsNe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
