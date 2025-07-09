import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_zh.dart';

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
    Locale('pl'),
    Locale('zh')
  ];

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @weNeedInformation.
  ///
  /// In en, this message translates to:
  /// **'We need some information about you'**
  String get weNeedInformation;

  /// No description provided for @letsStart.
  ///
  /// In en, this message translates to:
  /// **'Let\'s start'**
  String get letsStart;

  /// No description provided for @lifeSatisfaction.
  ///
  /// In en, this message translates to:
  /// **'Life satisfaction'**
  String get lifeSatisfaction;

  /// No description provided for @stressLevel.
  ///
  /// In en, this message translates to:
  /// **'Stress level'**
  String get stressLevel;

  /// No description provided for @qualityOfSleep.
  ///
  /// In en, this message translates to:
  /// **'Quality of sleep'**
  String get qualityOfSleep;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @healthCondition.
  ///
  /// In en, this message translates to:
  /// **'Health condition'**
  String get healthCondition;

  /// No description provided for @medicationUse.
  ///
  /// In en, this message translates to:
  /// **'Medication use'**
  String get medicationUse;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @ageCategory.
  ///
  /// In en, this message translates to:
  /// **'Age category'**
  String get ageCategory;

  /// No description provided for @employment.
  ///
  /// In en, this message translates to:
  /// **'Employment'**
  String get employment;

  /// No description provided for @education.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get education;

  /// No description provided for @greeneryArea.
  ///
  /// In en, this message translates to:
  /// **'Greenery area'**
  String get greeneryArea;

  /// No description provided for @initializeSurveyQuestion.
  ///
  /// In en, this message translates to:
  /// **'Do you want to start the survey?'**
  String get initializeSurveyQuestion;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @endSurveyQuestion.
  ///
  /// In en, this message translates to:
  /// **'Do you want to end the survey?\nYou will not be able to edit your answers later.'**
  String get endSurveyQuestion;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @nextSurveyTime.
  ///
  /// In en, this message translates to:
  /// **'Remaining time until the most urgent survey finishes'**
  String get nextSurveyTime;

  /// No description provided for @surveyDetails.
  ///
  /// In en, this message translates to:
  /// **'Survey details'**
  String get surveyDetails;

  /// No description provided for @loadingSurveyErrorTryAgainLater.
  ///
  /// In en, this message translates to:
  /// **'Failed to load the survey. Please try again later.'**
  String get loadingSurveyErrorTryAgainLater;

  /// No description provided for @loadingSurveyError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load selected survey'**
  String get loadingSurveyError;

  /// No description provided for @answerSubmitError.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit the answer'**
  String get answerSubmitError;

  /// No description provided for @mainPageTransitionError.
  ///
  /// In en, this message translates to:
  /// **'The response was successfully sent to the server, but an error occurred while returning to the home page. Try restarting the application.'**
  String get mainPageTransitionError;

  /// No description provided for @selectOneOption.
  ///
  /// In en, this message translates to:
  /// **'Select one of the options'**
  String get selectOneOption;

  /// No description provided for @noInternetTryAgain.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have an internet connection. Try again later'**
  String get noInternetTryAgain;

  /// No description provided for @woman.
  ///
  /// In en, this message translates to:
  /// **'Woman'**
  String get woman;

  /// No description provided for @man.
  ///
  /// In en, this message translates to:
  /// **'Man'**
  String get man;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials'**
  String get invalidCredentials;

  /// No description provided for @passwordNotEmpty.
  ///
  /// In en, this message translates to:
  /// **'Password must not be empty'**
  String get passwordNotEmpty;

  /// No description provided for @passwordTooLong.
  ///
  /// In en, this message translates to:
  /// **'Password must not be longer than {max} characters'**
  String passwordTooLong(int max);

  /// No description provided for @usernameNotEmpty.
  ///
  /// In en, this message translates to:
  /// **'Username must not be empty'**
  String get usernameNotEmpty;

  /// No description provided for @usernameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Username must not be longer than {max} characters'**
  String usernameTooLong(int max);

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hours;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutes;

  /// No description provided for @valueNotEmpty.
  ///
  /// In en, this message translates to:
  /// **'Value must not be empty'**
  String get valueNotEmpty;

  /// No description provided for @errorRetry.
  ///
  /// In en, this message translates to:
  /// **'Error, retry'**
  String get errorRetry;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @usedSensor.
  ///
  /// In en, this message translates to:
  /// **'Temperature sensor kind'**
  String get usedSensor;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @chooseATemperatureSensorYouReceived.
  ///
  /// In en, this message translates to:
  /// **'Choose a temperature sensor you\'ve received'**
  String get chooseATemperatureSensorYouReceived;

  /// No description provided for @noSensor.
  ///
  /// In en, this message translates to:
  /// **'No sensor'**
  String get noSensor;

  /// No description provided for @xiaomiSensor.
  ///
  /// In en, this message translates to:
  /// **'Xiaomi sensor'**
  String get xiaomiSensor;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @editSensor.
  ///
  /// In en, this message translates to:
  /// **'Edit sensor'**
  String get editSensor;

  /// No description provided for @appSettings.
  ///
  /// In en, this message translates to:
  /// **'App settings'**
  String get appSettings;

  /// No description provided for @surveyStartBody.
  ///
  /// In en, this message translates to:
  /// **'You can start the survey now. Are you ready?'**
  String get surveyStartBody;

  /// No description provided for @surveyFinishBody.
  ///
  /// In en, this message translates to:
  /// **'Survey is about to end. Let\'s do it!'**
  String get surveyFinishBody;

  /// No description provided for @pleaseEnterNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a number'**
  String get pleaseEnterNumber;

  /// No description provided for @enterNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a number'**
  String get enterNumber;

  /// No description provided for @pleaseEnterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get pleaseEnterValidNumber;

  /// No description provided for @pleaseEnterLeastZeroNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a number that is at least 0'**
  String get pleaseEnterLeastZeroNumber;

  /// No description provided for @pleaseEnterNumberLessThan1000.
  ///
  /// In en, this message translates to:
  /// **'Please enter a number less than 1000'**
  String get pleaseEnterNumberLessThan1000;

  /// No description provided for @pleaseEnterAnyText.
  ///
  /// In en, this message translates to:
  /// **'Please write your answer'**
  String get pleaseEnterAnyText;

  /// No description provided for @pleaseEnterShorterText.
  ///
  /// In en, this message translates to:
  /// **'Please write your answer in less than 1000 characters'**
  String get pleaseEnterShorterText;

  /// No description provided for @selectAtLeastOneOption.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one option'**
  String get selectAtLeastOneOption;

  /// No description provided for @apiUrl.
  ///
  /// In en, this message translates to:
  /// **'API url'**
  String get apiUrl;

  /// No description provided for @apiUrlEmptyErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'API url cannot be empty'**
  String get apiUrlEmptyErrorMessage;

  /// No description provided for @apiUrlInvalidFormatErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Invalid format'**
  String get apiUrlInvalidFormatErrorMessage;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logountConfirmationQuestion.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out? All data that has not been uploaded to the server will be lost.'**
  String get logountConfirmationQuestion;

  /// No description provided for @couldNotLogout.
  ///
  /// In en, this message translates to:
  /// **'Could not log out, try again later.'**
  String get couldNotLogout;

  /// No description provided for @credentialsExpired.
  ///
  /// In en, this message translates to:
  /// **'Your token has expired, reenter password.'**
  String get credentialsExpired;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @couldNotReachTheServer.
  ///
  /// In en, this message translates to:
  /// **'Failed to send the request, please try again later.'**
  String get couldNotReachTheServer;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong, please try again later.'**
  String get somethingWentWrong;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied'**
  String get locationPermissionDenied;

  /// No description provided for @locationPermissionDeniedMessage.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required to fill the surveys. Please click \"Open settings\" and enable location permission.'**
  String get locationPermissionDeniedMessage;

  /// No description provided for @locationBackgroundPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Background location permission missing'**
  String get locationBackgroundPermissionDenied;

  /// No description provided for @locationBackgroundPermissionDeniedMessage.
  ///
  /// In en, this message translates to:
  /// **'Background location permission is recommended to be enabled. Please click \"Open settings\" and then chose \"Allow all the time\".'**
  String get locationBackgroundPermissionDeniedMessage;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @privacySettings.
  ///
  /// In en, this message translates to:
  /// **'Privacy settings'**
  String get privacySettings;

  /// No description provided for @allowTrackLocation.
  ///
  /// In en, this message translates to:
  /// **'Allow location tracking'**
  String get allowTrackLocation;

  /// No description provided for @timeFrom.
  ///
  /// In en, this message translates to:
  /// **'Time from'**
  String get timeFrom;

  /// No description provided for @timeTo.
  ///
  /// In en, this message translates to:
  /// **'Time to'**
  String get timeTo;

  /// No description provided for @notifyMeAboutSurveys.
  ///
  /// In en, this message translates to:
  /// **'Notify me about surveys'**
  String get notifyMeAboutSurveys;

  /// No description provided for @openPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Open privacy policy'**
  String get openPrivacyPolicy;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @retypePassword.
  ///
  /// In en, this message translates to:
  /// **'Retype password'**
  String get retypePassword;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Your password has been successfully changed!'**
  String get passwordChangedSuccessfully;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get ok;

  /// No description provided for @currentPasswordMustNotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Current password must not be empty'**
  String get currentPasswordMustNotBeEmpty;

  /// No description provided for @minNewPasswordLenError.
  ///
  /// In en, this message translates to:
  /// **'The minimum length is 8 characters'**
  String get minNewPasswordLenError;

  /// No description provided for @retypePasswordMustBeEqualToNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New password does not match'**
  String get retypePasswordMustBeEqualToNewPassword;

  /// No description provided for @iAcceptPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'I accept privacy policy'**
  String get iAcceptPrivacyPolicy;

  /// No description provided for @scrollToTheVeryBottom.
  ///
  /// In en, this message translates to:
  /// **'Scroll to the very bottom'**
  String get scrollToTheVeryBottom;

  /// No description provided for @loadingImageFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load the image'**
  String get loadingImageFailed;

  /// No description provided for @multiplePermissionsDenied.
  ///
  /// In en, this message translates to:
  /// **'Permissions missing'**
  String get multiplePermissionsDenied;

  /// No description provided for @multiplePermissionsDeniedMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enable denied permissions in your device settings by going to Permissions in settings.'**
  String get multiplePermissionsDeniedMessage;

  /// No description provided for @surveyFinishTitle.
  ///
  /// In en, this message translates to:
  /// **'Finishing Survey'**
  String get surveyFinishTitle;

  /// No description provided for @surveyStartTitle.
  ///
  /// In en, this message translates to:
  /// **'New Survey'**
  String get surveyStartTitle;

  /// No description provided for @sensorDataHistory.
  ///
  /// In en, this message translates to:
  /// **'Historical readings'**
  String get sensorDataHistory;

  /// No description provided for @saveReading.
  ///
  /// In en, this message translates to:
  /// **'Save reading'**
  String get saveReading;

  /// No description provided for @scanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning'**
  String get scanning;

  /// No description provided for @bluetoothTurnedOff.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth is turned off'**
  String get bluetoothTurnedOff;

  /// No description provided for @sensorNotFound.
  ///
  /// In en, this message translates to:
  /// **'Could not detect sensor'**
  String get sensorNotFound;

  /// No description provided for @sensorNotSpecified.
  ///
  /// In en, this message translates to:
  /// **'Sensor not specified'**
  String get sensorNotSpecified;

  /// No description provided for @sensorData.
  ///
  /// In en, this message translates to:
  /// **'Sensor data'**
  String get sensorData;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @surveyName.
  ///
  /// In en, this message translates to:
  /// **'Survey name'**
  String get surveyName;

  /// No description provided for @end.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get end;

  /// No description provided for @sensorHistory.
  ///
  /// In en, this message translates to:
  /// **'Sensor history'**
  String get sensorHistory;

  /// No description provided for @dateFrom.
  ///
  /// In en, this message translates to:
  /// **'Date from'**
  String get dateFrom;

  /// No description provided for @dateTo.
  ///
  /// In en, this message translates to:
  /// **'Date to'**
  String get dateTo;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @humidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get humidity;

  /// No description provided for @sentToServer.
  ///
  /// In en, this message translates to:
  /// **'Sent to the server'**
  String get sentToServer;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @latidude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get latidude;

  /// No description provided for @longitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get longitude;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @theLocationDataHasBeenSubmitedToServer.
  ///
  /// In en, this message translates to:
  /// **'This location has already been submitted to the server'**
  String get theLocationDataHasBeenSubmitedToServer;

  /// No description provided for @theLocationDataHasNotBeenSubmitedToServer.
  ///
  /// In en, this message translates to:
  /// **'This location has not been submitted to the server yet'**
  String get theLocationDataHasNotBeenSubmitedToServer;

  /// No description provided for @surveyHasBeenComplitedInThisLocation.
  ///
  /// In en, this message translates to:
  /// **'There was a survey filled in this location'**
  String get surveyHasBeenComplitedInThisLocation;

  /// No description provided for @enterResponse.
  ///
  /// In en, this message translates to:
  /// **'Enter response'**
  String get enterResponse;

  /// No description provided for @kestrelDrop2.
  ///
  /// In en, this message translates to:
  /// **'Kestrel Drop 2 sensor'**
  String get kestrelDrop2;

  /// No description provided for @sensorId.
  ///
  /// In en, this message translates to:
  /// **'Sensor id'**
  String get sensorId;

  /// No description provided for @serverNotResponding.
  ///
  /// In en, this message translates to:
  /// **'Server is not responding. Make sure, you have provided a correct API url. If so, try again later.'**
  String get serverNotResponding;

  /// No description provided for @bluetoothRequired.
  ///
  /// In en, this message translates to:
  /// **'Turn on bluetooth, to complete the survey.'**
  String get bluetoothRequired;

  /// No description provided for @bluetooth.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth'**
  String get bluetooth;

  /// No description provided for @surveyFinished.
  ///
  /// In en, this message translates to:
  /// **'The survey has finished. You can\'t complete it anymore.'**
  String get surveyFinished;

  /// No description provided for @sensorMac.
  ///
  /// In en, this message translates to:
  /// **'Sensor\'s MAC adres'**
  String get sensorMac;

  /// No description provided for @sensorIdServerNotFound.
  ///
  /// In en, this message translates to:
  /// **'Sensor id not found on the server'**
  String get sensorIdServerNotFound;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternetConnection;

  /// No description provided for @betterExperienceTurnOnInternet.
  ///
  /// In en, this message translates to:
  /// **'For better experience, turn on the internet connection'**
  String get betterExperienceTurnOnInternet;

  /// No description provided for @loadingMacFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load MAC address'**
  String get loadingMacFailed;

  /// No description provided for @sensorNotFoundDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Sensor not found'**
  String get sensorNotFoundDialogTitle;

  /// No description provided for @sensorNotFoundDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Temperature sensor not found. The survey will be sent without temperature data. Please make sure you have the sensor with you and that it has a charged battery.'**
  String get sensorNotFoundDialogContent;

  /// No description provided for @thanksForCompletingTheSurvey.
  ///
  /// In en, this message translates to:
  /// **'Thank you for completing the survey.'**
  String get thanksForCompletingTheSurvey;

  /// No description provided for @nextSurveyWillAppearIn.
  ///
  /// In en, this message translates to:
  /// **'Next survey will appear in {time}.'**
  String nextSurveyWillAppearIn(String time);

  /// No description provided for @nextSurveyIsReadyToComplete.
  ///
  /// In en, this message translates to:
  /// **'Next survey is already ready to complete.'**
  String get nextSurveyIsReadyToComplete;

  /// No description provided for @loginFailedServerRespondedWithStatusCode.
  ///
  /// In en, this message translates to:
  /// **'Login failed. The server responded with code {code}. Please try again later.'**
  String loginFailedServerRespondedWithStatusCode(int code);

  /// No description provided for @weWereUnableToDetermineTheServerAvailibility.
  ///
  /// In en, this message translates to:
  /// **'Due to certain legal restrictions, we need to determine whether you are allowed to use the provided API address. However, we were unable to verify this at the moment. Please try again later.'**
  String get weWereUnableToDetermineTheServerAvailibility;

  /// No description provided for @theServerYouProvidedIsNotAllowedInYourLocation.
  ///
  /// In en, this message translates to:
  /// **'The server you provided is not allowed in your location.'**
  String get theServerYouProvidedIsNotAllowedInYourLocation;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @errorLoadingContacts.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading contacts. Please make sure you are connected to the Internet and try again later.'**
  String get errorLoadingContacts;

  /// No description provided for @refreshContacts.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refreshContacts;

  /// No description provided for @noContacts.
  ///
  /// In en, this message translates to:
  /// **'The study administrator has not defined any contact phone numbers.'**
  String get noContacts;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @couldNotMakeCall.
  ///
  /// In en, this message translates to:
  /// **'The call could not be completed.'**
  String get couldNotMakeCall;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @noSensorSelected.
  ///
  /// In en, this message translates to:
  /// **'No temperature sensor selected. Sensor data will not be saved after completing the survey. We suggest going to settings to select a sensor.'**
  String get noSensorSelected;

  /// No description provided for @continueWithoutSensor.
  ///
  /// In en, this message translates to:
  /// **'Continue without sensor'**
  String get continueWithoutSensor;
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
      <String>['en', 'pl', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pl':
      return AppLocalizationsPl();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
