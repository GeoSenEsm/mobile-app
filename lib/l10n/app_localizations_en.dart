// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get login => 'Login';

  @override
  String get weNeedInformation => 'We need some information about you';

  @override
  String get letsStart => 'Let\'s start';

  @override
  String get lifeSatisfaction => 'Life satisfaction';

  @override
  String get stressLevel => 'Stress level';

  @override
  String get qualityOfSleep => 'Quality of sleep';

  @override
  String get next => 'Next';

  @override
  String get healthCondition => 'Health condition';

  @override
  String get medicationUse => 'Medication use';

  @override
  String get gender => 'Gender';

  @override
  String get ageCategory => 'Age category';

  @override
  String get employment => 'Employment';

  @override
  String get education => 'Education';

  @override
  String get greeneryArea => 'Greenery area';

  @override
  String get initializeSurveyQuestion => 'Do you want to start the survey?';

  @override
  String get start => 'Start';

  @override
  String get endSurveyQuestion =>
      'Do you want to end the survey?\nYou will not be able to edit your answers later.';

  @override
  String get finish => 'Finish';

  @override
  String get error => 'Error';

  @override
  String get nextSurveyTime =>
      'Remaining time until the most urgent survey finishes';

  @override
  String get surveyDetails => 'Survey details';

  @override
  String get loadingSurveyErrorTryAgainLater =>
      'Failed to load the survey. Please try again later.';

  @override
  String get loadingSurveyError => 'Failed to load selected survey';

  @override
  String get answerSubmitError => 'Failed to submit the answer';

  @override
  String get mainPageTransitionError =>
      'The response was successfully sent to the server, but an error occurred while returning to the home page. Try restarting the application.';

  @override
  String get selectOneOption => 'Select one of the options';

  @override
  String get noInternetTryAgain =>
      'You don\'t have an internet connection. Try again later';

  @override
  String get woman => 'Woman';

  @override
  String get man => 'Man';

  @override
  String get invalidCredentials => 'Invalid credentials';

  @override
  String get passwordNotEmpty => 'Password must not be empty';

  @override
  String passwordTooLong(int max) {
    return 'Password must not be longer than $max characters';
  }

  @override
  String get usernameNotEmpty => 'Username must not be empty';

  @override
  String usernameTooLong(int max) {
    return 'Username must not be longer than $max characters';
  }

  @override
  String get hours => 'hours';

  @override
  String get minutes => 'minutes';

  @override
  String get valueNotEmpty => 'Value must not be empty';

  @override
  String get errorRetry => 'Error, retry';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get usedSensor => 'Temperature sensor kind';

  @override
  String get save => 'Save';

  @override
  String get chooseATemperatureSensorYouReceived =>
      'Choose a temperature sensor you\'ve received';

  @override
  String get noSensor => 'No sensor';

  @override
  String get xiaomiSensor => 'Xiaomi sensor';

  @override
  String get settings => 'Settings';

  @override
  String get editSensor => 'Edit sensor';

  @override
  String get appSettings => 'App settings';

  @override
  String get surveyStartBody => 'You can start the survey now. Are you ready?';

  @override
  String get surveyFinishBody => 'Survey is about to end. Let\'s do it!';

  @override
  String get pleaseEnterNumber => 'Please enter a number';

  @override
  String get enterNumber => 'Enter a number';

  @override
  String get pleaseEnterValidNumber => 'Please enter a valid number';

  @override
  String get pleaseEnterLeastZeroNumber =>
      'Please enter a number that is at least 0';

  @override
  String get pleaseEnterNumberLessThan1000 =>
      'Please enter a number less than 1000';

  @override
  String get pleaseEnterAnyText => 'Please write your answer';

  @override
  String get pleaseEnterShorterText =>
      'Please write your answer in less than 1000 characters';

  @override
  String get selectAtLeastOneOption => 'Please select at least one option';

  @override
  String get apiUrl => 'API url';

  @override
  String get apiUrlEmptyErrorMessage => 'API url cannot be empty';

  @override
  String get apiUrlInvalidFormatErrorMessage => 'Invalid format';

  @override
  String get logout => 'Logout';

  @override
  String get logountConfirmationQuestion =>
      'Are you sure you want to log out? All data that has not been uploaded to the server will be lost.';

  @override
  String get couldNotLogout => 'Could not log out, try again later.';

  @override
  String get credentialsExpired => 'Your token has expired, reenter password.';

  @override
  String get profile => 'Profile';

  @override
  String get couldNotReachTheServer =>
      'Failed to send the request, please try again later.';

  @override
  String get somethingWentWrong =>
      'Something went wrong, please try again later.';

  @override
  String get locationPermissionDenied => 'Location permission denied';

  @override
  String get locationPermissionDeniedMessage =>
      'Location permission is required to fill the surveys. Please click \"Open settings\" and enable location permission.';

  @override
  String get locationBackgroundPermissionDenied =>
      'Background location permission missing';

  @override
  String get locationBackgroundPermissionDeniedMessage =>
      'Background location permission is recommended to be enabled. Please click \"Open settings\" and then chose \"Allow all the time\".';

  @override
  String get openSettings => 'Open settings';

  @override
  String get close => 'Close';

  @override
  String get notifications => 'Notifications';

  @override
  String get privacy => 'Privacy';

  @override
  String get privacySettings => 'Privacy settings';

  @override
  String get allowTrackLocation => 'Allow location tracking';

  @override
  String get timeFrom => 'Time from';

  @override
  String get timeTo => 'Time to';

  @override
  String get notifyMeAboutSurveys => 'Notify me about surveys';

  @override
  String get openPrivacyPolicy => 'Open privacy policy';

  @override
  String get changePassword => 'Change password';

  @override
  String get currentPassword => 'Current password';

  @override
  String get newPassword => 'New password';

  @override
  String get retypePassword => 'Retype password';

  @override
  String get passwordChangedSuccessfully =>
      'Your password has been successfully changed!';

  @override
  String get ok => 'Ok';

  @override
  String get currentPasswordMustNotBeEmpty =>
      'Current password must not be empty';

  @override
  String get minNewPasswordLenError => 'The minimum length is 8 characters';

  @override
  String get retypePasswordMustBeEqualToNewPassword =>
      'New password does not match';

  @override
  String get iAcceptPrivacyPolicy => 'I accept privacy policy';

  @override
  String get scrollToTheVeryBottom => 'Scroll to the very bottom';

  @override
  String get loadingImageFailed => 'Could not load the image';

  @override
  String get multiplePermissionsDenied => 'Permissions missing';

  @override
  String get multiplePermissionsDeniedMessage =>
      'Please enable denied permissions in your device settings by going to Permissions in settings.';

  @override
  String get surveyFinishTitle => 'Finishing Survey';

  @override
  String get surveyStartTitle => 'New Survey';

  @override
  String get sensorDataHistory => 'Historical readings';

  @override
  String get saveReading => 'Save reading';

  @override
  String get scanning => 'Scanning';

  @override
  String get bluetoothTurnedOff => 'Bluetooth is turned off';

  @override
  String get sensorNotFound => 'Could not detect sensor';

  @override
  String get sensorNotSpecified => 'Sensor not specified';

  @override
  String get sensorData => 'Sensor data';

  @override
  String get calendar => 'Calendar';

  @override
  String get day => 'Day';

  @override
  String get week => 'Week';

  @override
  String get surveyName => 'Survey name';

  @override
  String get end => 'Finish';

  @override
  String get sensorHistory => 'Sensor history';

  @override
  String get dateFrom => 'Date from';

  @override
  String get dateTo => 'Date to';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get apply => 'Apply';

  @override
  String get thisWeek => 'This week';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get date => 'Date';

  @override
  String get temperature => 'Temperature';

  @override
  String get humidity => 'Humidity';

  @override
  String get sentToServer => 'Sent to the server';

  @override
  String get menu => 'Menu';

  @override
  String get map => 'Map';

  @override
  String get today => 'Today';

  @override
  String get latidude => 'Latitude';

  @override
  String get longitude => 'Longitude';

  @override
  String get time => 'Time';

  @override
  String get theLocationDataHasBeenSubmitedToServer =>
      'This location has already been submitted to the server';

  @override
  String get theLocationDataHasNotBeenSubmitedToServer =>
      'This location has not been submitted to the server yet';

  @override
  String get surveyHasBeenComplitedInThisLocation =>
      'There was a survey filled in this location';

  @override
  String get enterResponse => 'Enter response';

  @override
  String get kestrelDrop2 => 'Kestrel Drop 2 sensor';

  @override
  String get sensorId => 'Sensor id';

  @override
  String get serverNotResponding =>
      'Server is not responding. Make sure, you have provided a correct API url. If so, try again later.';

  @override
  String get bluetoothRequired => 'Turn on bluetooth, to complete the survey.';

  @override
  String get bluetooth => 'Bluetooth';

  @override
  String get surveyFinished =>
      'The survey has finished. You can\'t complete it anymore.';

  @override
  String get sensorMac => 'Sensor\'s MAC adres';

  @override
  String get sensorIdServerNotFound => 'Sensor id not found on the server';

  @override
  String get noInternetConnection => 'No internet connection';

  @override
  String get betterExperienceTurnOnInternet =>
      'For better experience, turn on the internet connection';

  @override
  String get loadingMacFailed => 'Could not load MAC address';

  @override
  String get sensorNotFoundDialogTitle => 'Sensor not found';

  @override
  String get sensorNotFoundDialogContent =>
      'Temperature sensor not found. The survey will be sent without temperature data. Please make sure you have the sensor with you and that it has a charged battery.';

  @override
  String get thanksForCompletingTheSurvey =>
      'Thank you for completing the survey.';

  @override
  String nextSurveyWillAppearIn(String time) {
    return 'Next survey will appear in $time.';
  }

  @override
  String get nextSurveyIsReadyToComplete =>
      'Next survey is already ready to complete.';

  @override
  String loginFailedServerRespondedWithStatusCode(int code) {
    return 'Login failed. The server responded with code $code. Please try again later.';
  }

  @override
  String get weWereUnableToDetermineTheServerAvailibility =>
      'Due to certain legal restrictions, we need to determine whether you are allowed to use the provided API address. However, we were unable to verify this at the moment. Please try again later.';

  @override
  String get theServerYouProvidedIsNotAllowedInYourLocation =>
      'The server you provided is not allowed in your location.';

  @override
  String get help => 'Help';

  @override
  String get contact => 'Contact';

  @override
  String get errorLoadingContacts =>
      'An error occurred while loading contacts. Please make sure you are connected to the Internet and try again later.';

  @override
  String get refreshContacts => 'Refresh';

  @override
  String get noContacts =>
      'The study administrator has not defined any contact phone numbers.';

  @override
  String get call => 'Call';

  @override
  String get couldNotMakeCall => 'The call could not be completed.';

  @override
  String get warning => 'Warning';

  @override
  String get noSensorSelected =>
      'No temperature sensor selected. Sensor data will not be saved after completing the survey. We suggest going to settings to select a sensor.';

  @override
  String get continueWithoutSensor => 'Continue without sensor';
}
