// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Bhansa Ghar';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get guidanceTitle => 'App Guidance';

  @override
  String get initialSetup => '1. Initial Setup';

  @override
  String get initialSetupStep1 =>
      'Allow Notification Permissions when prompted to receive order updates.';

  @override
  String get initialSetupStep2 =>
      'Set Battery Saver to \"No Restrictions\" for this app in your device settings. This ensures the server runs smoothly in the background.';

  @override
  String get prepareCafe => '2. Prepare Your Cafe';

  @override
  String get prepareCafeStep1 =>
      'Go to the appropriate sections to add your Categories and Menu Items.';

  @override
  String get prepareCafeStep2 =>
      'Define the Number of Tables available in your cafe/restaurant from the Settings.';

  @override
  String get startServing => '3. Start Serving';

  @override
  String get startServingStep1 =>
      'Ensure both the Admin device (this phone) and Customer devices are connected to the SAME WiFi network.';

  @override
  String get startServingStep2 =>
      'Go to Settings and toggle \"Web Server\" to ON.';

  @override
  String get startServingStep3 =>
      'Navigate to the QR Section to generate a QR code for your menu.';

  @override
  String get startServingStep4 =>
      'You can also generate a QR code for your WiFi credentials to help customers connect easily.';

  @override
  String get customerExperience => '4. Customer Experience';

  @override
  String get customerExperienceStep1 =>
      'Customers scan the Menu QR code to open the Web App.';

  @override
  String get customerExperienceStep2 =>
      'Note: If the QR code doesn\'t work, they can manually enter the URL displayed in the Server section into their browser.';

  @override
  String get customerExperienceStep3 =>
      'Customers can browse the menu, add items to cart, and place orders.';

  @override
  String get customerExperienceStep4 =>
      'They can also track the status of their orders in real-time.';

  @override
  String get orderManagement => '5. Order Management';

  @override
  String get orderManagementStep1 =>
      'Admins receive orders instantly on this device.';

  @override
  String get orderManagementStep2 =>
      'Use the Negotiation Feature to adjust quantities if stock is low or initiate a discussion with the customer.';

  @override
  String get welcomeTitle => 'Welcome to Bhansa Ghar';

  @override
  String get welcomeSubtitle =>
      'Follow these steps to set up your digital ordering system.';

  @override
  String get needHelp => 'Need Help?';

  @override
  String get contactSupport =>
      'For additional information or support, please contact:';

  @override
  String get language => 'Language';

  @override
  String get changeLanguage => 'Change Language';

  @override
  String get changeLanguageSubtitle => 'Change language';

  @override
  String get server => 'Server';

  @override
  String get webServer => 'Web Server';

  @override
  String get startingServer => 'Starting server...';

  @override
  String get stoppingServer => 'Stopping server...';

  @override
  String get runningAt => 'Running at';

  @override
  String get serverError => 'Error:';

  @override
  String get serverOffline => 'Server is offline';

  @override
  String get stopServerTitle => 'Stop Server?';

  @override
  String get stopServerMessage =>
      'Are you sure you want to stop the web server? Users will no longer be able to access the menu.';

  @override
  String get cancel => 'Cancel';

  @override
  String get stop => 'Stop';

  @override
  String get guidance => 'Guidance';

  @override
  String get tableManagement => 'Table Management';

  @override
  String get manageTables => 'Manage Tables';

  @override
  String get noTablesConfigured =>
      'No tables configured. Please add tables in settings.';

  @override
  String get tableConfigured => 'table configured';

  @override
  String get tablesConfigured => 'tables configured';

  @override
  String get successfullySetTables => 'Successfully set';

  @override
  String get appearance => 'Appearance';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get currentlyUsingDarkTheme => 'Currently using dark theme';

  @override
  String get currentlyUsingLightTheme => 'Currently using light theme';

  @override
  String get credentials => 'Credentials';

  @override
  String get setupPin => 'Setup PIN';

  @override
  String get setNewPin => 'Set a new 4-digit PIN';

  @override
  String get changePin => 'Change PIN';

  @override
  String get updatePin => 'Update your 4-digit login PIN';

  @override
  String get turnOffPin => 'Turn Off PIN';

  @override
  String get removePinSecurity => 'Remove PIN security';

  @override
  String get turnOffPinTitle => 'Turn Off PIN?';

  @override
  String get turnOffPinMessage =>
      'Are you sure you want to remove the PIN lock? Anyone will be able to access the app.';

  @override
  String get turnOffPinMessageWithBiometric =>
      'Are you sure you want to remove the PIN lock? This will also disable biometric authentication. Anyone will be able to access the app.';

  @override
  String get turnOff => 'Turn Off';

  @override
  String get biometrics => 'Biometrics';

  @override
  String get enableBiometricLogin => 'Enable Biometric Login';

  @override
  String get biometricSubtitle => 'Use fingerprint or Face ID for quick access';

  @override
  String get biometricNotAvailable => 'Not available on this device';

  @override
  String get biometricNotAvailableMessage =>
      'Biometric authentication is not available on this device';

  @override
  String get biometricEnabled => 'Biometric authentication enabled';

  @override
  String get biometricFailed => 'Biometric authentication failed';

  @override
  String get disableBiometricTitle => 'Disable Biometric Authentication?';

  @override
  String get disableBiometricMessage =>
      'You will need to use your PIN to unlock the app.';

  @override
  String get disable => 'Disable';

  @override
  String get biometricDisabled => 'Biometric authentication disabled';

  @override
  String get importExport => 'Import & Export';

  @override
  String get importData => 'Import Data';

  @override
  String get importDataSubtitle => 'Import categories and menu items';

  @override
  String get exportData => 'Export Data';

  @override
  String get exportDataSubtitle => 'Backup categories and menu items';

  @override
  String get fileSavedSuccessfully => 'File saved successfully';

  @override
  String get importedSuccess => 'Imported';

  @override
  String get categoriesAnd => 'categories and';

  @override
  String get menuItems => 'menu items';

  @override
  String get failedToReadFile => 'Failed to read file:';

  @override
  String get shareNotAvailable => 'Share not available:';

  @override
  String get exportSuccessTitle => 'Export it !';

  @override
  String get categories => 'Categories';

  @override
  String get saved => 'Saved';

  @override
  String get share => 'Share';

  @override
  String get importDataTitle => 'Import Data?';

  @override
  String get replaceExistingData => 'This will replace all existing data';

  @override
  String get import => 'Import';

  @override
  String get addNewCategory => 'Add New Category';

  @override
  String get editCategory => 'Edit Category';

  @override
  String get enterCategoryDescription =>
      'Enter a name for the new menu category.';

  @override
  String get categoryName => 'Category Name';

  @override
  String get categoryNameHint => 'e.g., Desserts';

  @override
  String get pleaseEnterCategoryName => 'Please enter a category name';

  @override
  String get save => 'Save';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get admin => 'Admin';

  @override
  String get atAGlance => 'At a Glance';

  @override
  String get activeOrders => 'Active Orders';

  @override
  String get pendingOrders => 'Pending Orders';

  @override
  String get menu => 'Menu';

  @override
  String get orders => 'Orders';

  @override
  String get qrCodes => 'QR Codes';

  @override
  String get settings => 'Settings';

  @override
  String get manageCategories => 'Manage Categories';

  @override
  String get manageCategoriesSubtitle => 'Add or edit menu categories';

  @override
  String get generateQrCodes => 'Generate QR Codes';

  @override
  String get cafeGuestWifi => 'Café Guest Wi-Fi';

  @override
  String get connectCustomersToInternet =>
      'Connect your customers to the internet.';

  @override
  String get digitalMenu => 'Digital Menu';

  @override
  String get linkCustomersToMenu => 'Link customers to your online menu.';

  @override
  String get generateWifiQr => 'Generate WiFi QR';

  @override
  String get generateMenuQr => 'Generate Menu QR';

  @override
  String get foriPhoneiPadUsers => 'For iPhone/iPad Users';

  @override
  String get sslErrorInstructions =>
      'If scanning the QR code shows an SSL error, manually enter this URL in Safari:';

  @override
  String get generateMenuQrFirst =>
      'Generate the Menu QR code first to see the URL';

  @override
  String get pleaseStartServerFirst =>
      'Please start the server first from Settings';

  @override
  String get noQrCodeGenerated => 'No QR Code Generated';

  @override
  String get qrCodeSavedTo => 'QR Code saved to:';

  @override
  String get ok => 'OK';

  @override
  String get errorSavingQrCode => 'Error saving QR Code:';

  @override
  String get errorSharingQrCode => 'Error sharing QR Code:';

  @override
  String get saveAndShareQrCode =>
      'Save and share this QR code. Place it on tables or near the counter for easy access.';

  @override
  String get tapButtonToGenerateQr =>
      'Tap the button above to generate a QR code.';

  @override
  String get wifiQrCode => 'WiFi QR Code';

  @override
  String get enterWifiCredentials => 'Enter your WiFi credentials';

  @override
  String get networkNameSsid => 'Network Name (SSID)';

  @override
  String get networkNameHint => 'e.g., Café WiFi';

  @override
  String get password => 'Password';

  @override
  String get enterWifiPassword => 'Enter WiFi password';

  @override
  String get generate => 'Generate';

  @override
  String get categoryNameEnglish => 'Category Name (English)';

  @override
  String get categoryNameNepali => 'Category Name (Nepali)';

  @override
  String get menuItemNameEnglish => 'Menu Item Name (English)';

  @override
  String get menuItemNameNepali => 'Menu Item Name (Nepali)';

  @override
  String get pleaseEnterBothLanguages => 'Please enter names in both languages';

  @override
  String get categoryNameEnglishHint => 'e.g., Desserts';

  @override
  String get categoryNameNepaliHint => 'e.g., मिठाई';

  @override
  String get menuItemNameEnglishHint => 'e.g., Coffee';

  @override
  String get menuItemNameNepaliHint => 'e.g., कफी';

  @override
  String get noCategoriesYet => 'No categories yet';

  @override
  String get tapPlusToAddCategory =>
      'Tap the \'+\' button to add a new category.';

  @override
  String get deleteCategory => 'Delete Category';

  @override
  String get confirmDeleteCategory => 'Are you sure you want to delete';

  @override
  String get delete => 'Delete';

  @override
  String get menuManagement => 'Menu Management';

  @override
  String get all => 'All';

  @override
  String get noItemsInCategory => 'No items in this category';

  @override
  String get tapPlusToAddItem => 'Tap the \'+\' button to add a new item.';

  @override
  String get unsupportedFileFormat => 'Unsupported file format';

  @override
  String importedCategoriesAndItems(
    Object categoriesCount,
    Object menuItemsCount,
  ) {
    return 'Imported $categoriesCount categories and $menuItemsCount menu items';
  }

  @override
  String get failedToGenerateExcel => 'Failed to generate Excel file';

  @override
  String get failedToExportToExcel => 'Failed to export to Excel';

  @override
  String get fileDoesNotExist => 'File does not exist';

  @override
  String get missingCategoriesSheet => 'Missing \"Categories\" sheet';

  @override
  String get missingMenuItemsSheet => 'Missing \"Menu Items\" sheet';

  @override
  String categoryIdCannotBeEmpty(Object row) {
    return 'Category ID cannot be empty at row $row';
  }

  @override
  String categoryNamesCannotBeEmpty(Object row) {
    return 'Category names cannot be empty at row $row';
  }

  @override
  String menuItemIdCannotBeEmpty(Object row) {
    return 'Menu item ID cannot be empty at row $row';
  }

  @override
  String menuItemNamesCannotBeEmpty(Object row) {
    return 'Menu item names cannot be empty at row $row';
  }

  @override
  String invalidPriceAtRow(Object row) {
    return 'Invalid price for menu item at row $row';
  }

  @override
  String menuItemCategoryCannotBeEmpty(Object row) {
    return 'Menu item category cannot be empty at row $row';
  }

  @override
  String menuItemReferencesNonExistentCategory(
    Object categoryId,
    Object itemName,
  ) {
    return 'Menu item \"$itemName\" references non-existent category ID \"$categoryId\"';
  }

  @override
  String get invalidExcelFormat => 'Invalid Excel format';

  @override
  String get failedToImportFromExcel => 'Failed to import from Excel';

  @override
  String get failedToSaveJsonFile => 'Failed to save JSON file';

  @override
  String get failedToShareFile => 'Failed to share file';

  @override
  String get failedToPickFile => 'Failed to pick file';

  @override
  String get invalidJsonFormat => 'Invalid JSON format';

  @override
  String get failedToImportData => 'Failed to import data';

  @override
  String get missingVersionField => 'Missing version field';

  @override
  String get missingExportDateField => 'Missing exportDate field';

  @override
  String get missingCategoriesField => 'Missing categories field';

  @override
  String get missingMenuItemsField => 'Missing menuItems field';

  @override
  String get categoriesMustBeArray => 'Categories must be an array';

  @override
  String get menuItemsMustBeArray => 'MenuItems must be an array';

  @override
  String get addNewMenuItem => 'Add New Menu Item';

  @override
  String get editMenuItem => 'Edit Menu Item';

  @override
  String get titleEnglish => 'Title (English)';

  @override
  String get titleNepali => 'Title (Nepali)';

  @override
  String get titleEnglishHint => 'e.g. Avocado Toast';

  @override
  String get titleNepaliHint => 'e.g. एभोकाडो टोस्ट';

  @override
  String get image => 'Image';

  @override
  String get price => 'Price';

  @override
  String get priceHint => 'Rs 0.00';

  @override
  String get category => 'Category';

  @override
  String get selectCategory => 'Select a category';

  @override
  String get addItem => 'Add Item';

  @override
  String get clickToUpload => 'Click to upload';

  @override
  String get imageFormatSize => 'PNG or JPG (MAX. 1MB)';

  @override
  String get imageSizeTooLarge => 'Image size must be less than 1MB';

  @override
  String get pleaseEnterMenuItemNames =>
      'Please enter menu item name in both languages';

  @override
  String get pleaseEnterPrice => 'Please enter a price';

  @override
  String get pleaseEnterValidPrice =>
      'Please enter a valid price greater than 0';

  @override
  String get pleaseSelectCategory => 'Please select a category';

  @override
  String get numberOfTables => 'Number of Tables';

  @override
  String get numberOfTablesHint => 'e.g., 10';

  @override
  String get enterNumberOfTables =>
      'Enter the number of tables in your restaurant.';

  @override
  String get tablesWillBeNumbered =>
      'Tables will be numbered as Table 1, Table 2, etc.';

  @override
  String get pleaseEnterValidNumber =>
      'Please enter a valid number greater than 0';

  @override
  String get maximumTablesAllowed => 'Maximum 100 tables allowed';

  @override
  String get selectTable => 'Select Table';

  @override
  String get noTable => 'No Table';

  @override
  String get table => 'Table';

  @override
  String get letsSecureYourAccount => 'Let\'s Secure Your\nAccount';

  @override
  String get pinSetupWelcomeMessage =>
      'To keep your cafe\'s data safe, we\'ll\nguide you through setting up a\nsecure PIN and an option for\nbiometric login.';

  @override
  String get getStarted => 'Get Started';

  @override
  String get createYourPin => 'Create Your PIN';

  @override
  String get enterFourDigitPin => 'Enter a 4-digit PIN';

  @override
  String get confirmYourPin => 'Confirm Your PIN';

  @override
  String get reenterPinToConfirm => 'Re-enter your PIN to confirm';

  @override
  String get pinCreatedSuccessfully => 'PIN Created\nSuccessfully!';

  @override
  String get pinCreatedMessage =>
      'Your account is now secure.\nYou can use this PIN to access\nyour cafe management system.';

  @override
  String get continueButton => 'Continue';

  @override
  String get enterPinToLogin => 'Enter your PIN to login';

  @override
  String get enterPin => 'Enter PIN';

  @override
  String get pleaseEnterFourDigitPin => 'Please enter your 4-digit PIN';

  @override
  String get pinsDoNotMatch => 'PINs do not match. Please try again.';

  @override
  String get verifyOldPin => 'Verify Old PIN';

  @override
  String get enterCurrentPin => 'Enter your current PIN';

  @override
  String get adminAccess => 'Admin Access';

  @override
  String get confirmIdentityToContinue => 'Confirm your identity to continue';

  @override
  String get tapToUnlock => 'Tap to Unlock';

  @override
  String get useFingerprintOrFaceId => 'Use Fingerprint or Face ID';

  @override
  String get retry => 'Retry';

  @override
  String get usePinPassword => 'Use PIN / Password';

  @override
  String get incorrectPin => 'Incorrect PIN';

  @override
  String get failedToVerifyPin => 'Failed to verify PIN';

  @override
  String get failedToSetPin => 'Failed to set PIN';

  @override
  String get failedToDisablePin => 'Failed to disable PIN';

  @override
  String get biometricAuthFailed => 'Biometric authentication failed';

  @override
  String get biometricAuthError => 'Biometric authentication error';

  @override
  String get failedToUpdateBiometric => 'Failed to update biometric setting';

  @override
  String get failedToDisableBiometric => 'Failed to disable biometric';

  @override
  String get brewingSomethingSpecial => 'Brewing up something\nspecial...';

  @override
  String get notifications => 'Notifications';

  @override
  String get markAllAsRead => 'Mark all as read';

  @override
  String get clearAll => 'Clear all';

  @override
  String get errorLoadingNotifications => 'Error loading notifications';

  @override
  String get unknownError => 'Unknown error';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get allCaughtUp => 'You\'re all caught up!';

  @override
  String unreadNotification(int count) {
    return '$count unread notification';
  }

  @override
  String unreadNotifications(int count) {
    return '$count unread notifications';
  }

  @override
  String get notificationRemoved => 'Notification removed';

  @override
  String get clearAllNotifications => 'Clear All Notifications';

  @override
  String get clearAllNotificationsConfirm =>
      'Are you sure you want to clear all notifications? This action cannot be undone.';

  @override
  String get liveOrders => 'Live Orders';

  @override
  String get oldestFirst => 'Oldest First';

  @override
  String get newestFirst => 'Newest First';

  @override
  String get clearAllFilters => 'Clear All';

  @override
  String get noMatchingOrders => 'No matching orders';

  @override
  String get loadMore => 'Load More';

  @override
  String get noOrdersYet => 'No orders yet';

  @override
  String get filterOrders => 'Filter Orders';

  @override
  String get reset => 'Reset';

  @override
  String get sortBy => 'Sort By';

  @override
  String get status => 'Status';

  @override
  String get received => 'Received';

  @override
  String get preparing => 'Preparing';

  @override
  String get ready => 'Ready';

  @override
  String get completed => 'Completed';

  @override
  String get noTablesActive => 'No tables active';

  @override
  String get applyFilters => 'Apply Filters';

  @override
  String orderHash(String id) {
    return 'Order #$id';
  }

  @override
  String get newBadge => 'NEW';

  @override
  String proposed(int quantity) {
    return 'Proposed: $quantity×';
  }

  @override
  String get total => 'Total';

  @override
  String get needsConfirmation => 'Needs Confirmation';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get cancelOrder => 'Cancel Order';

  @override
  String get cancelOrderConfirm =>
      'Are you sure you want to cancel this order?';

  @override
  String get no => 'No';

  @override
  String get yesCancel => 'Yes, Cancel';

  @override
  String get newOrder => 'New Order';

  @override
  String get newOrderReceived => 'New Order Received';

  @override
  String tableOrderMessage(String tableNumber, String items) {
    return 'Table $tableNumber placed a new order: $items';
  }

  @override
  String get unknownTable => 'Unknown';

  @override
  String get voiceAnnouncements => 'Voice Announcements';

  @override
  String get enableVoiceAnnouncements => 'Enable Voice Announcements';

  @override
  String get speechRate => 'Speech Rate';

  @override
  String get volume => 'Volume';

  @override
  String get pitch => 'Pitch';

  @override
  String newOrderAnnouncement(String tableNumber, String items) {
    return 'New order received. Table $tableNumber. Items: $items';
  }

  @override
  String orderReadyAnnouncement(String orderId) {
    return 'Order number $orderId is ready.';
  }

  @override
  String orderCompletedAnnouncement(String orderId) {
    return 'Order number $orderId is completed.';
  }

  @override
  String get enabled => 'Enabled';

  @override
  String get disabled => 'Disabled';

  @override
  String get testVoice => 'Test Voice';

  @override
  String get testVoiceMessage =>
      'This is a test of the voice announcement system.';
}
