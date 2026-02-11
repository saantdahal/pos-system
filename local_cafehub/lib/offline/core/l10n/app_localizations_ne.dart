// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Nepali (`ne`).
class AppLocalizationsNe extends AppLocalizations {
  AppLocalizationsNe([String locale = 'ne']) : super(locale);

  @override
  String get appTitle => 'Bhansa Ghar';

  @override
  String get settingsTitle => 'सेटिङहरू';

  @override
  String get guidanceTitle => 'एप मार्गदर्शन';

  @override
  String get initialSetup => '१. सुरुवाती सेटअप';

  @override
  String get initialSetupStep1 =>
      'अर्डर अपडेटहरू प्राप्त गर्न सोधिएको बेला नोटिफिकेसन अनुमति दिनुहोस्।';

  @override
  String get initialSetupStep2 =>
      'तपाईंको डिभाइस सेटिङहरूमा यो एपको लागि ब्याट्री सेभरलाई \"कुनै प्रतिबन्ध छैन\" (No Restrictions) मा राख्नुहोस्। यसले सर्भर ब्याकग्राउन्डमा राम्रोसँग चल्ने सुनिश्चित गर्छ।';

  @override
  String get prepareCafe => '२. तपाईंको क्याफे तयार गर्नुहोस्';

  @override
  String get prepareCafeStep1 =>
      'तपाईंको कोटीहरू र मेनु आइटमहरू थप्न उपयुक्त खण्डहरूमा जानुहोस्।';

  @override
  String get prepareCafeStep2 =>
      'सेटिङहरूबाट तपाईंको क्याफे/रेस्टुरेन्टमा उपलब्ध टेबलहरूको संख्या परिभाषित गर्नुहोस्।';

  @override
  String get startServing => '३. सेवा सुरु गर्नुहोस्';

  @override
  String get startServingStep1 =>
      'सुनिश्चित गर्नुहोस् कि एडमिन डिभाइस (यो फोन) र ग्राहकका डिभाइसहरू एउटै वाइफाइ नेटवर्कमा जोडिएका छन्।';

  @override
  String get startServingStep2 =>
      'सेटिङहरूमा जानुहोस् र \"Web Server\" अन गर्नुहोस्।';

  @override
  String get startServingStep3 =>
      'तपाईंको मेनुको लागि QR कोड बनाउन QR खण्डमा जानुहोस्।';

  @override
  String get startServingStep4 =>
      'तपाईं ग्राहकहरूलाई सजिलैसँग जडान गर्न मद्दत गर्नको लागि आफ्नो वाइफाइको QR कोड पनि बनाउन सक्नुहुन्छ।';

  @override
  String get customerExperience => '४. ग्राहक अनुभव';

  @override
  String get customerExperienceStep1 =>
      'ग्राहकहरूले वेब एप खोल्नको लागि मेनु QR कोड स्क्यान गर्छन्।';

  @override
  String get customerExperienceStep2 =>
      'नोट: यदि QR कोडले काम गरेन भने, उनीहरूले सर्भर खण्डमा देखाइएको URL आफ्नो ब्राउजरमा म्यानुअल रूपमा राख्न सक्छन्।';

  @override
  String get customerExperienceStep3 =>
      'ग्राहकहरूले मेनु हेर्न, कार्टमा आइटम थप्न र अर्डर गर्न सक्छन्।';

  @override
  String get customerExperienceStep4 =>
      'उनीहरूले आफ्नो अर्डरको स्थिति पनि रियल-टाइममा ट्रयाक गर्न सक्छन्।';

  @override
  String get orderManagement => '५. अर्डर व्यवस्थापन';

  @override
  String get orderManagementStep1 =>
      'एडमिनहरूले यो डिभाइसमा तुरुन्तै अर्डरहरू प्राप्त गर्छन्।';

  @override
  String get orderManagementStep2 =>
      'यदि स्टक कम छ वा ग्राहकसँग छलफल गर्न चाहनुहुन्छ भने मात्रा समायोजन गर्न नेगोसिएसन फिचर प्रयोग गर्नुहोस्।';

  @override
  String get welcomeTitle => 'Bhansa Ghar मा स्वागत छ';

  @override
  String get welcomeSubtitle =>
      'तपाईंको डिजिटल अर्डर प्रणाली सेटअप गर्न यी चरणहरू पालना गर्नुहोस्।';

  @override
  String get needHelp => 'सहयोग चाहिएको छ?';

  @override
  String get contactSupport =>
      'थप जानकारी वा सहयोगको लागि, कृपया सम्पर्क गर्नुहोस्:';

  @override
  String get language => 'भाषा';

  @override
  String get changeLanguage => 'भाषा परिवर्तन गर्नुहोस्';

  @override
  String get changeLanguageSubtitle => 'भाषा परिवर्तन गर्नुहोस्';

  @override
  String get server => 'सर्भर';

  @override
  String get webServer => 'वेब सर्भर';

  @override
  String get startingServer => 'सर्भर सुरु गर्दै...';

  @override
  String get stoppingServer => 'सर्भर बन्द गर्दै...';

  @override
  String get runningAt => 'चलिरहेको छ';

  @override
  String get serverError => 'त्रुटि:';

  @override
  String get serverOffline => 'सर्भर अफलाइन छ';

  @override
  String get stopServerTitle => 'सर्भर बन्द गर्ने?';

  @override
  String get stopServerMessage =>
      'के तपाईं वेब सर्भर बन्द गर्न निश्चित हुनुहुन्छ? प्रयोगकर्ताहरूले अब मेनु पहुँच गर्न सक्नेछैनन्।';

  @override
  String get cancel => 'रद्द गर्नुहोस्';

  @override
  String get stop => 'बन्द गर्नुहोस्';

  @override
  String get guidance => 'मार्गदर्शन';

  @override
  String get tableManagement => 'टेबल व्यवस्थापन';

  @override
  String get manageTables => 'टेबलहरू व्यवस्थापन गर्नुहोस्';

  @override
  String get noTablesConfigured =>
      'कुनै टेबल कन्फिगर गरिएको छैन। कृपया सेटिङमा टेबलहरू थप्नुहोस्।';

  @override
  String get tableConfigured => 'टेबल कन्फिगर गरिएको';

  @override
  String get tablesConfigured => 'टेबलहरू कन्फिगर गरिएका';

  @override
  String get successfullySetTables => 'सफलतापूर्वक सेट गरियो';

  @override
  String get appearance => 'उपस्थिति';

  @override
  String get darkMode => 'डार्क मोड';

  @override
  String get currentlyUsingDarkTheme => 'हाल डार्क थिम प्रयोग गर्दै';

  @override
  String get currentlyUsingLightTheme => 'हाल लाइट थिम प्रयोग गर्दै';

  @override
  String get credentials => 'प्रमाणहरू';

  @override
  String get setupPin => 'PIN सेटअप गर्नुहोस्';

  @override
  String get setNewPin => 'नयाँ ४-अंकको PIN सेट गर्नुहोस्';

  @override
  String get changePin => 'PIN परिवर्तन गर्नुहोस्';

  @override
  String get updatePin => 'तपाईंको ४-अंकको लगइन PIN अपडेट गर्नुहोस्';

  @override
  String get turnOffPin => 'PIN बन्द गर्नुहोस्';

  @override
  String get removePinSecurity => 'PIN सुरक्षा हटाउनुहोस्';

  @override
  String get turnOffPinTitle => 'PIN बन्द गर्ने?';

  @override
  String get turnOffPinMessage =>
      'के तपाईं PIN लक हटाउन निश्चित हुनुहुन्छ? जो कोहीले पनि एप पहुँच गर्न सक्नेछन्।';

  @override
  String get turnOffPinMessageWithBiometric =>
      'के तपाईं PIN लक हटाउन निश्चित हुनुहुन्छ? यसले बायोमेट्रिक प्रमाणीकरण पनि असक्षम गर्नेछ। जो कोहीले पनि एप पहुँच गर्न सक्नेछन्।';

  @override
  String get turnOff => 'बन्द गर्नुहोस्';

  @override
  String get biometrics => 'बायोमेट्रिक्स';

  @override
  String get enableBiometricLogin => 'बायोमेट्रिक लगइन सक्षम गर्नुहोस्';

  @override
  String get biometricSubtitle =>
      'छिटो पहुँचको लागि फिंगरप्रिन्ट वा फेस ID प्रयोग गर्नुहोस्';

  @override
  String get biometricNotAvailable => 'यो उपकरणमा उपलब्ध छैन';

  @override
  String get biometricNotAvailableMessage =>
      'बायोमेट्रिक प्रमाणीकरण यो उपकरणमा उपलब्ध छैन';

  @override
  String get biometricEnabled => 'बायोमेट्रिक प्रमाणीकरण सक्षम गरियो';

  @override
  String get biometricFailed => 'बायोमेट्रिक प्रमाणीकरण असफल भयो';

  @override
  String get disableBiometricTitle => 'बायोमेट्रिक प्रमाणीकरण असक्षम गर्ने?';

  @override
  String get disableBiometricMessage =>
      'तपाईंले एप अनलक गर्न आफ्नो PIN प्रयोग गर्नु पर्नेछ।';

  @override
  String get disable => 'असक्षम गर्नुहोस्';

  @override
  String get biometricDisabled => 'बायोमेट्रिक प्रमाणीकरण असक्षम गरियो';

  @override
  String get importExport => 'आयात र निर्यात';

  @override
  String get importData => 'डेटा आयात गर्नुहोस्';

  @override
  String get importDataSubtitle => 'कोटीहरू र मेनु आइटमहरू आयात गर्नुहोस्';

  @override
  String get exportData => 'डेटा निर्यात गर्नुहोस्';

  @override
  String get exportDataSubtitle => 'कोटीहरू र मेनु आइटमहरू ब्याकअप गर्नुहोस्';

  @override
  String get fileSavedSuccessfully => 'फाइल सफलतापूर्वक सुरक्षित गरियो';

  @override
  String get importedSuccess => 'आयात गरियो';

  @override
  String get categoriesAnd => 'कोटीहरू र';

  @override
  String get menuItems => 'मेनु आइटमहरू';

  @override
  String get failedToReadFile => 'फाइल पढ्न असफल:';

  @override
  String get shareNotAvailable => 'साझेदारी उपलब्ध छैन:';

  @override
  String get exportSuccessTitle => 'निर्यात गर्नुहोस् !';

  @override
  String get categories => 'कोटीहरू';

  @override
  String get saved => 'सुरक्षित गरियो';

  @override
  String get share => 'साझेदारी गर्नुहोस्';

  @override
  String get importDataTitle => 'डेटा आयात गर्ने?';

  @override
  String get replaceExistingData => 'यसले सबै अवस्थित डेटा प्रतिस्थापन गर्नेछ';

  @override
  String get import => 'आयात गर्नुहोस्';

  @override
  String get addNewCategory => 'नयाँ कोटी थप्नुहोस्';

  @override
  String get editCategory => 'कोटी सम्पादन गर्नुहोस्';

  @override
  String get enterCategoryDescription =>
      'नयाँ मेनु कोटीको लागि नाम राख्नुहोस्।';

  @override
  String get categoryName => 'कोटीको नाम';

  @override
  String get categoryNameHint => 'उदाहरण: मिठाई';

  @override
  String get pleaseEnterCategoryName => 'कृपया कोटीको नाम राख्नुहोस्';

  @override
  String get save => 'सुरक्षित गर्नुहोस्';

  @override
  String get welcomeBack => 'फेरि स्वागत छ';

  @override
  String get admin => 'प्रशासक';

  @override
  String get atAGlance => 'एक नजरमा';

  @override
  String get activeOrders => 'सक्रिय अर्डरहरू';

  @override
  String get pendingOrders => 'बाँकी अर्डरहरू';

  @override
  String get menu => 'मेनु';

  @override
  String get orders => 'अर्डरहरू';

  @override
  String get qrCodes => 'QR कोडहरू';

  @override
  String get settings => 'सेटिङहरू';

  @override
  String get manageCategories => 'कोटीहरू व्यवस्थापन गर्नुहोस्';

  @override
  String get manageCategoriesSubtitle =>
      'मेनु कोटीहरू थप्नुहोस् वा सम्पादन गर्नुहोस्';

  @override
  String get generateQrCodes => 'QR कोडहरू उत्पन्न गर्नुहोस्';

  @override
  String get cafeGuestWifi => 'क्याफे अतिथि Wi-Fi';

  @override
  String get connectCustomersToInternet =>
      'आफ्ना ग्राहकहरूलाई इन्टरनेटमा जोड्नुहोस्।';

  @override
  String get digitalMenu => 'डिजिटल मेनु';

  @override
  String get linkCustomersToMenu =>
      'ग्राहकहरूलाई तपाईंको अनलाइन मेनुमा जोड्नुहोस्।';

  @override
  String get generateWifiQr => 'WiFi QR उत्पन्न गर्नुहोस्';

  @override
  String get generateMenuQr => 'मेनु QR उत्पन्न गर्नुहोस्';

  @override
  String get foriPhoneiPadUsers => 'iPhone/iPad प्रयोगकर्ताहरूको लागि';

  @override
  String get sslErrorInstructions =>
      'यदि QR कोड स्क्यान गर्दा SSL त्रुटि देखियो भने, Safari मा यो URL म्यानुअल राख्नुहोस्:';

  @override
  String get generateMenuQrFirst =>
      'URL हेर्न पहिले मेनु QR कोड उत्पन्न गर्नुहोस्';

  @override
  String get pleaseStartServerFirst =>
      'कृपया पहिले सेटिङबाट सर्भर सुरु गर्नुहोस्';

  @override
  String get noQrCodeGenerated => 'कुनै QR कोड उत्पन्न गरिएको छैन';

  @override
  String get qrCodeSavedTo => 'QR कोड यहाँ सुरक्षित गरियो:';

  @override
  String get ok => 'ठिक छ';

  @override
  String get errorSavingQrCode => 'QR कोड सुरक्षित गर्न त्रुटि:';

  @override
  String get errorSharingQrCode => 'QR कोड साझेदारी गर्न त्रुटि:';

  @override
  String get saveAndShareQrCode =>
      'यो QR कोड सुरक्षित र साझेदारी गर्नुहोस्। सजिलो पहुँचको लागि यसलाई टेबलमा वा काउन्टर नजिक राख्नुहोस्।';

  @override
  String get tapButtonToGenerateQr =>
      'QR कोड उत्पन्न गर्न माथिको बटन थिच्नुहोस्।';

  @override
  String get wifiQrCode => 'WiFi QR कोड';

  @override
  String get enterWifiCredentials => 'आफ्नो WiFi प्रमाणहरू राख्नुहोस्';

  @override
  String get networkNameSsid => 'नेटवर्क नाम (SSID)';

  @override
  String get networkNameHint => 'उदाहरण: क्याफे WiFi';

  @override
  String get password => 'पासवर्ड';

  @override
  String get enterWifiPassword => 'WiFi पासवर्ड राख्नुहोस्';

  @override
  String get generate => 'उत्पन्न गर्नुहोस्';

  @override
  String get categoryNameEnglish => 'कोटीको नाम (अंग्रेजी)';

  @override
  String get categoryNameNepali => 'कोटीको नाम (नेपाली)';

  @override
  String get menuItemNameEnglish => 'मेनु वस्तुको नाम (अंग्रेजी)';

  @override
  String get menuItemNameNepali => 'मेनु वस्तुको नाम (नेपाली)';

  @override
  String get pleaseEnterBothLanguages => 'कृपया दुवै भाषामा नाम राख्नुहोस्';

  @override
  String get categoryNameEnglishHint => 'उदाहरण: Desserts';

  @override
  String get categoryNameNepaliHint => 'उदाहरण: मिठाई';

  @override
  String get menuItemNameEnglishHint => 'उदाहरण: Coffee';

  @override
  String get menuItemNameNepaliHint => 'उदाहरण: कफी';

  @override
  String get noCategoriesYet => 'अहिलेसम्म कुनै कोटी छैन';

  @override
  String get tapPlusToAddCategory => 'नयाँ कोटी थप्न \'+\' बटन थिच्नुहोस्।';

  @override
  String get deleteCategory => 'कोटी मेटाउनुहोस्';

  @override
  String get confirmDeleteCategory => 'के तपाईं मेटाउन निश्चित हुनुहुन्छ';

  @override
  String get delete => 'मेटाउनुहोस्';

  @override
  String get menuManagement => 'मेनु व्यवस्थापन';

  @override
  String get all => 'सबै';

  @override
  String get noItemsInCategory => 'यो कोटीमा कुनै वस्तु छैन';

  @override
  String get tapPlusToAddItem => 'नयाँ वस्तु थप्न \'+\' बटन थिच्नुहोस्।';

  @override
  String get unsupportedFileFormat => 'असमर्थित फाइल ढाँचा';

  @override
  String importedCategoriesAndItems(
    Object categoriesCount,
    Object menuItemsCount,
  ) {
    return '$categoriesCount कोटीहरू र $menuItemsCount मेनु वस्तुहरू आयात गरियो';
  }

  @override
  String get failedToGenerateExcel => 'Excel फाइल उत्पन्न गर्न असफल';

  @override
  String get failedToExportToExcel => 'Excel मा निर्यात गर्न असफल';

  @override
  String get fileDoesNotExist => 'फाइल अवस्थित छैन';

  @override
  String get missingCategoriesSheet => '\"Categories\" पाना हराइरहेको छ';

  @override
  String get missingMenuItemsSheet => '\"Menu Items\" पाना हराइरहेको छ';

  @override
  String categoryIdCannotBeEmpty(Object row) {
    return 'कोटी ID पङ्क्ति $row मा खाली हुन सक्दैन';
  }

  @override
  String categoryNamesCannotBeEmpty(Object row) {
    return 'कोटी नामहरू पङ्क्ति $row मा खाली हुन सक्दैन';
  }

  @override
  String menuItemIdCannotBeEmpty(Object row) {
    return 'मेनु वस्तु ID पङ्क्ति $row मा खाली हुन सक्दैन';
  }

  @override
  String menuItemNamesCannotBeEmpty(Object row) {
    return 'मेनु वस्तु नामहरू पङ्क्ति $row मा खाली हुन सक्दैन';
  }

  @override
  String invalidPriceAtRow(Object row) {
    return 'पङ्क्ति $row मा मेनु वस्तुको लागि अवैध मूल्य';
  }

  @override
  String menuItemCategoryCannotBeEmpty(Object row) {
    return 'मेनु वस्तु कोटी पङ्क्ति $row मा खाली हुन सक्दैन';
  }

  @override
  String menuItemReferencesNonExistentCategory(
    Object categoryId,
    Object itemName,
  ) {
    return 'मेनु वस्तु \"$itemName\" अवस्थित नभएको कोटी ID \"$categoryId\" सन्दर्भ गर्दछ';
  }

  @override
  String get invalidExcelFormat => 'अवैध Excel ढाँचा';

  @override
  String get failedToImportFromExcel => 'Excel बाट आयात गर्न असफल';

  @override
  String get failedToSaveJsonFile => 'JSON फाइल सुरक्षित गर्न असफल';

  @override
  String get failedToShareFile => 'फाइल साझेदारी गर्न असफल';

  @override
  String get failedToPickFile => 'फाइल छनोट गर्न असफल';

  @override
  String get invalidJsonFormat => 'अवैध JSON ढाँचा';

  @override
  String get failedToImportData => 'डेटा आयात गर्न असफल';

  @override
  String get missingVersionField => 'संस्करण फिल्ड हराइरहेको छ';

  @override
  String get missingExportDateField => 'निर्यात मिति फिल्ड हराइरहेको छ';

  @override
  String get missingCategoriesField => 'कोटीहरू फिल्ड हराइरहेको छ';

  @override
  String get missingMenuItemsField => 'मेनु वस्तुहरू फिल्ड हराइरहेको छ';

  @override
  String get categoriesMustBeArray => 'कोटीहरू एरे हुनुपर्छ';

  @override
  String get menuItemsMustBeArray => 'मेनु वस्तुहरू एरे हुनुपर्छ';

  @override
  String get addNewMenuItem => 'नयाँ मेनु वस्तु थप्नुहोस्';

  @override
  String get editMenuItem => 'मेनु वस्तु सम्पादन गर्नुहोस्';

  @override
  String get titleEnglish => 'शीर्षक (अंग्रेजी)';

  @override
  String get titleNepali => 'शीर्षक (नेपाली)';

  @override
  String get titleEnglishHint => 'उदाहरण: Avocado Toast';

  @override
  String get titleNepaliHint => 'उदाहरण: एभोकाडो टोस्ट';

  @override
  String get image => 'तस्बिर';

  @override
  String get price => 'मूल्य';

  @override
  String get priceHint => 'रु ०.००';

  @override
  String get category => 'कोटी';

  @override
  String get selectCategory => 'कोटी छनोट गर्नुहोस्';

  @override
  String get addItem => 'वस्तु थप्नुहोस्';

  @override
  String get clickToUpload => 'अपलोड गर्न क्लिक गर्नुहोस्';

  @override
  String get imageFormatSize => 'PNG वा JPG (अधिकतम १MB)';

  @override
  String get imageSizeTooLarge => 'तस्बिर आकार १MB भन्दा कम हुनुपर्छ';

  @override
  String get pleaseEnterMenuItemNames =>
      'कृपया दुवै भाषामा मेनु वस्तुको नाम राख्नुहोस्';

  @override
  String get pleaseEnterPrice => 'कृपया मूल्य राख्नुहोस्';

  @override
  String get pleaseEnterValidPrice =>
      'कृपया ० भन्दा बढी मान्य मूल्य राख्नुहोस्';

  @override
  String get pleaseSelectCategory => 'कृपया कोटी छनोट गर्नुहोस्';

  @override
  String get numberOfTables => 'टेबलहरूको संख्या';

  @override
  String get numberOfTablesHint => 'उदाहरण: १०';

  @override
  String get enterNumberOfTables =>
      'आफ्नो रेस्टुरेन्टमा टेबलहरूको संख्या राख्नुहोस्।';

  @override
  String get tablesWillBeNumbered =>
      'टेबलहरूलाई टेबल १, टेबल २, आदि क्रमांकित गरिनेछ।';

  @override
  String get pleaseEnterValidNumber =>
      'कृपया ० भन्दा बढी मान्य संख्या राख्नुहोस्';

  @override
  String get maximumTablesAllowed => 'अधिकतम १०० टेबलहरू अनुमति छ';

  @override
  String get selectTable => 'टेबल छनोट गर्नुहोस्';

  @override
  String get noTable => 'कुनै टेबल छैन';

  @override
  String get table => 'टेबल';

  @override
  String get letsSecureYourAccount => 'आफ्नो खाता\nसुरक्षित गरौं';

  @override
  String get pinSetupWelcomeMessage =>
      'तपाईंको क्याफेको डेटा सुरक्षित राख्न,\nहामी तपाईंलाई सुरक्षित PIN र\nबायोमेट्रिक लगइनको विकल्प\nसेटअप गर्न मार्गदर्शन गर्नेछौं।';

  @override
  String get getStarted => 'सुरु गरौं';

  @override
  String get createYourPin => 'आफ्नो PIN बनाउनुहोस्';

  @override
  String get enterFourDigitPin => '४-अंकको PIN राख्नुहोस्';

  @override
  String get confirmYourPin => 'आफ्नो PIN पुष्टि गर्नुहोस्';

  @override
  String get reenterPinToConfirm => 'पुष्टि गर्न आफ्नो PIN पुन: राख्नुहोस्';

  @override
  String get pinCreatedSuccessfully => 'PIN सफलतापूर्वक\nबनाइयो!';

  @override
  String get pinCreatedMessage =>
      'तपाईंको खाता अब सुरक्षित छ।\nतपाईं यो PIN प्रयोग गरेर\nआफ्नो क्याफे व्यवस्थापन प्रणाली\nपहुँच गर्न सक्नुहुन्छ।';

  @override
  String get continueButton => 'जारी राख्नुहोस्';

  @override
  String get enterPinToLogin => 'लगइन गर्न आफ्नो PIN राख्नुहोस्';

  @override
  String get enterPin => 'PIN राख्नुहोस्';

  @override
  String get pleaseEnterFourDigitPin => 'कृपया आफ्नो ४-अंकको PIN राख्नुहोस्';

  @override
  String get pinsDoNotMatch => 'PIN मेल खाएन। कृपया फेरि प्रयास गर्नुहोस्।';

  @override
  String get verifyOldPin => 'पुरानो PIN प्रमाणित गर्नुहोस्';

  @override
  String get enterCurrentPin => 'आफ्नो हालको PIN राख्नुहोस्';

  @override
  String get adminAccess => 'प्रशासक पहुँच';

  @override
  String get confirmIdentityToContinue =>
      'जारी राख्न आफ्नो पहिचान पुष्टि गर्नुहोस्';

  @override
  String get tapToUnlock => 'अनलक गर्न ट्याप गर्नुहोस्';

  @override
  String get useFingerprintOrFaceId =>
      'फिंगरप्रिन्ट वा फेस ID प्रयोग गर्नुहोस्';

  @override
  String get retry => 'पुन: प्रयास गर्नुहोस्';

  @override
  String get usePinPassword => 'PIN / पासवर्ड प्रयोग गर्नुहोस्';

  @override
  String get incorrectPin => 'गलत PIN';

  @override
  String get failedToVerifyPin => 'PIN प्रमाणित गर्न असफल';

  @override
  String get failedToSetPin => 'PIN सेट गर्न असफल';

  @override
  String get failedToDisablePin => 'PIN असक्षम गर्न असफल';

  @override
  String get biometricAuthFailed => 'बायोमेट्रिक प्रमाणीकरण असफल';

  @override
  String get biometricAuthError => 'बायोमेट्रिक प्रमाणीकरण त्रुटि';

  @override
  String get failedToUpdateBiometric => 'बायोमेट्रिक सेटिङ अपडेट गर्न असफल';

  @override
  String get failedToDisableBiometric => 'बायोमेट्रिक असक्षम गर्न असफल';

  @override
  String get brewingSomethingSpecial => 'केही विशेष\nतयार गर्दैछौं...';

  @override
  String get notifications => 'सूचनाहरू';

  @override
  String get markAllAsRead => 'सबैलाई पढिसकेको चिन्ह लगाउनुहोस्';

  @override
  String get clearAll => 'सबै हटाउनुहोस्';

  @override
  String get errorLoadingNotifications => 'सूचनाहरू लोड गर्न त्रुटि';

  @override
  String get unknownError => 'अज्ञात त्रुटि';

  @override
  String get noNotifications => 'कुनै सूचना छैन';

  @override
  String get allCaughtUp => 'तपाईं सबै अपडेट हुनुहुन्छ!';

  @override
  String unreadNotification(int count) {
    return '$count नपढिएको सूचना';
  }

  @override
  String unreadNotifications(int count) {
    return '$count नपढिएका सूचनाहरू';
  }

  @override
  String get notificationRemoved => 'सूचना हटाइयो';

  @override
  String get clearAllNotifications => 'सबै सूचनाहरू हटाउनुहोस्';

  @override
  String get clearAllNotificationsConfirm =>
      'के तपाईं सबै सूचनाहरू हटाउन चाहनुहुन्छ? यो कार्य पूर्वावस्थामा फर्काउन सकिंदैन।';

  @override
  String get liveOrders => 'जारी अर्डरहरू';

  @override
  String get oldestFirst => 'पुरानो पहिले';

  @override
  String get newestFirst => 'नयाँ पहिले';

  @override
  String get clearAllFilters => 'सबै हटाउनुहोस्';

  @override
  String get noMatchingOrders => 'कुनै मिल्दो अर्डर छैन';

  @override
  String get loadMore => 'थप लोड गर्नुहोस्';

  @override
  String get noOrdersYet => 'अहिलेसम्म कुनै अर्डर छैन';

  @override
  String get filterOrders => 'अर्डर छान्नुहोस्';

  @override
  String get reset => 'रिसेट गर्नुहोस्';

  @override
  String get sortBy => 'क्रमबद्ध गर्नुहोस्';

  @override
  String get status => 'स्थिति';

  @override
  String get received => 'प्राप्त भयो';

  @override
  String get preparing => 'तयार गर्दै';

  @override
  String get ready => 'तयार छ';

  @override
  String get completed => 'पूरा भयो';

  @override
  String get noTablesActive => 'कुनै टेबल सक्रिय छैन';

  @override
  String get applyFilters => 'फिल्टर लागू गर्नुहोस्';

  @override
  String orderHash(String id) {
    return 'अर्डर #$id';
  }

  @override
  String get newBadge => 'नयाँ';

  @override
  String proposed(int quantity) {
    return 'प्रस्तावित: $quantity×';
  }

  @override
  String get total => 'जम्मा';

  @override
  String get needsConfirmation => 'पुष्टि आवश्यक छ';

  @override
  String get cancelled => 'रद्द गरियो';

  @override
  String get cancelOrder => 'अर्डर रद्द गर्नुहोस्';

  @override
  String get cancelOrderConfirm => 'के तपाईं यो अर्डर रद्द गर्न चाहनुहुन्छ?';

  @override
  String get no => 'होइन';

  @override
  String get yesCancel => 'हो, रद्द गर्नुहोस्';

  @override
  String get newOrder => 'नयाँ अर्डर';

  @override
  String get newOrderReceived => 'नयाँ अर्डर प्राप्त भयो';

  @override
  String tableOrderMessage(String tableNumber, String items) {
    return 'टेबल $tableNumber ले नयाँ अर्डर राख्यो: $items';
  }

  @override
  String get unknownTable => 'अज्ञात';

  @override
  String get voiceAnnouncements => 'आवाज घोषणाहरू';

  @override
  String get enableVoiceAnnouncements => 'आवाज घोषणाहरू सक्षम गर्नुहोस्';

  @override
  String get speechRate => 'बोल्ने गति';

  @override
  String get volume => 'भोल्युम';

  @override
  String get pitch => 'पिच';

  @override
  String newOrderAnnouncement(String tableNumber, String items) {
    return 'नयाँ अर्डर प्राप्त भयो। टेबल $tableNumber। $items';
  }

  @override
  String orderReadyAnnouncement(String orderId) {
    return 'अर्डर नम्बर $orderId तयार छ।';
  }

  @override
  String orderCompletedAnnouncement(String orderId) {
    return 'अर्डर नम्बर $orderId पूरा भयो।';
  }

  @override
  String get enabled => 'सक्षम';

  @override
  String get disabled => 'असक्षम';

  @override
  String get testVoice => 'आवाज परीक्षण गर्नुहोस्';

  @override
  String get testVoiceMessage => 'यो आवाज घोषणा प्रणालीको परीक्षण हो।';
}
