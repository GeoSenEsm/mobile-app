// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get username => 'Benutzername';

  @override
  String get password => 'Passwort';

  @override
  String get login => 'Anmelden';

  @override
  String get weNeedInformation =>
      'Wir benötigen einige Informationen über dich';

  @override
  String get letsStart => 'Los geht\'s';

  @override
  String get lifeSatisfaction => 'Lebenszufriedenheit';

  @override
  String get stressLevel => 'Stressniveau';

  @override
  String get qualityOfSleep => 'Schlafqualität';

  @override
  String get next => 'Weiter';

  @override
  String get healthCondition => 'Gesundheitszustand';

  @override
  String get medicationUse => 'Medikamenteneinnahme';

  @override
  String get gender => 'Geschlecht';

  @override
  String get ageCategory => 'Alterskategorie';

  @override
  String get employment => 'Beschäftigung';

  @override
  String get education => 'Ausbildung';

  @override
  String get greeneryArea => 'Grünfläche';

  @override
  String get initializeSurveyQuestion => 'Möchtest du die Umfrage starten?';

  @override
  String get start => 'Starten';

  @override
  String get endSurveyQuestion =>
      'Möchtest du die Umfrage beenden?\nDu kannst deine Antworten danach nicht mehr bearbeiten.';

  @override
  String get finish => 'Beenden';

  @override
  String get error => 'Fehler';

  @override
  String get nextSurveyTime =>
      'Verbleibende Zeit bis zum Ende der dringendsten Umfrage';

  @override
  String get surveyDetails => 'Umfragedetails';

  @override
  String get loadingSurveyErrorTryAgainLater =>
      'Die Umfrage konnte nicht geladen werden. Bitte versuche es später erneut.';

  @override
  String get loadingSurveyError =>
      'Diese Umfrage ist derzeit nicht aktiv. Sie ist möglicherweise beendet oder noch nicht verfügbar.';

  @override
  String get answerSubmitError => 'Die Antwort konnte nicht gesendet werden';

  @override
  String get mainPageTransitionError =>
      'Die Antwort wurde erfolgreich an den Server gesendet, aber beim Zurückkehren zur Startseite ist ein Fehler aufgetreten. Versuche, die Anwendung neu zu starten.';

  @override
  String get selectOneOption => 'Wähle eine der Optionen';

  @override
  String get noInternetTryAgain =>
      'Du hast keine Internetverbindung. Versuche es später erneut';

  @override
  String get woman => 'Frau';

  @override
  String get man => 'Mann';

  @override
  String get invalidCredentials => 'Ungültige Anmeldedaten';

  @override
  String get passwordNotEmpty => 'Das Passwort darf nicht leer sein';

  @override
  String passwordTooLong(int max) {
    return 'Das Passwort darf nicht länger als $max Zeichen sein';
  }

  @override
  String get usernameNotEmpty => 'Der Benutzername darf nicht leer sein';

  @override
  String usernameTooLong(int max) {
    return 'Der Benutzername darf nicht länger als $max Zeichen sein';
  }

  @override
  String get hours => 'Stunden';

  @override
  String get minutes => 'Minuten';

  @override
  String get valueNotEmpty => 'Der Wert darf nicht leer sein';

  @override
  String get errorRetry => 'Fehler, erneut versuchen';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nein';

  @override
  String get usedSensor => 'Art des Temperatursensors';

  @override
  String get save => 'Speichern';

  @override
  String get chooseATemperatureSensorYouReceived =>
      'Wähle den Temperatursensor aus, den du erhalten hast';

  @override
  String get noSensor => 'Kein Sensor';

  @override
  String get xiaomiSensor => 'Xiaomi-Sensor';

  @override
  String get settings => 'Einstellungen';

  @override
  String get editSensor => 'Sensor bearbeiten';

  @override
  String get appSettings => 'App-Einstellungen';

  @override
  String get surveyStartBody =>
      'Du kannst die Umfrage jetzt starten. Bist du bereit?';

  @override
  String get surveyFinishBody =>
      'Die Umfrage endet gleich. Los geht\'s!';

  @override
  String get pleaseEnterNumber => 'Bitte gib eine Zahl ein';

  @override
  String get enterNumber => 'Zahl eingeben';

  @override
  String get pleaseEnterValidNumber => 'Bitte gib eine gültige Zahl ein';

  @override
  String get pleaseEnterLeastZeroNumber =>
      'Bitte gib eine Zahl größer oder gleich 0 ein';

  @override
  String get pleaseEnterNumberLessThan1000 =>
      'Bitte gib eine Zahl kleiner als 1000 ein';

  @override
  String get pleaseEnterAnyText => 'Bitte schreibe deine Antwort';

  @override
  String get pleaseEnterShorterText =>
      'Bitte schreibe deine Antwort in weniger als 1000 Zeichen';

  @override
  String get selectAtLeastOneOption => 'Bitte wähle mindestens eine Option aus';

  @override
  String get apiUrl => 'API-URL';

  @override
  String get apiUrlEmptyErrorMessage => 'Die API-URL darf nicht leer sein';

  @override
  String get apiUrlInvalidFormatErrorMessage => 'Ungültiges Format';

  @override
  String get logout => 'Abmelden';

  @override
  String get logountConfirmationQuestion =>
      'Möchtest du dich wirklich abmelden? Alle Daten, die nicht an den Server gesendet wurden, gehen verloren.';

  @override
  String get couldNotLogout =>
      'Abmelden fehlgeschlagen, versuche es später erneut.';

  @override
  String get credentialsExpired =>
      'Dein Token ist abgelaufen, gib das Passwort erneut ein.';

  @override
  String get profile => 'Profil';

  @override
  String get couldNotReachTheServer =>
      'Anfrage konnte nicht gesendet werden, bitte versuche es später erneut.';

  @override
  String get somethingWentWrong =>
      'Etwas ist schiefgelaufen, bitte versuche es später erneut.';

  @override
  String get locationPermissionDenied => 'Standortberechtigung verweigert';

  @override
  String get locationPermissionDeniedMessage =>
      'Die Standortberechtigung ist erforderlich, um die Umfragen auszufüllen. Bitte klicke auf \"Einstellungen öffnen\" und aktiviere die Standortberechtigung.';

  @override
  String get locationBackgroundPermissionDenied =>
      'Standortberechtigung im Hintergrund fehlt';

  @override
  String get locationBackgroundPermissionDeniedMessage =>
      'Es wird empfohlen, die Standortberechtigung im Hintergrund zu aktivieren. Bitte klicke auf \"Einstellungen öffnen\" und wähle dann \"Immer zulassen\".';

  @override
  String get openSettings => 'Einstellungen öffnen';

  @override
  String get close => 'Schließen';

  @override
  String get notifications => 'Benachrichtigungen';

  @override
  String get privacy => 'Datenschutz';

  @override
  String get privacySettings => 'Datenschutzeinstellungen';

  @override
  String get allowTrackLocation => 'Standortverfolgung erlauben';

  @override
  String get timeFrom => 'Uhrzeit von';

  @override
  String get timeTo => 'Uhrzeit bis';

  @override
  String get notifyMeAboutSurveys => 'Über Umfragen benachrichtigen';

  @override
  String get openPrivacyPolicy => 'Datenschutzerklärung öffnen';

  @override
  String get changePassword => 'Passwort ändern';

  @override
  String get currentPassword => 'Aktuelles Passwort';

  @override
  String get newPassword => 'Neues Passwort';

  @override
  String get retypePassword => 'Passwort wiederholen';

  @override
  String get passwordChangedSuccessfully =>
      'Dein Passwort wurde erfolgreich geändert!';

  @override
  String get ok => 'Ok';

  @override
  String get currentPasswordMustNotBeEmpty =>
      'Das aktuelle Passwort darf nicht leer sein';

  @override
  String get minNewPasswordLenError => 'Die Mindestlänge beträgt 8 Zeichen';

  @override
  String get retypePasswordMustBeEqualToNewPassword =>
      'Das neue Passwort stimmt nicht überein';

  @override
  String get iAcceptPrivacyPolicy => 'Ich akzeptiere die Datenschutzerklärung';

  @override
  String get scrollToTheVeryBottom => 'Scrolle bis ganz nach unten';

  @override
  String get loadingImageFailed => 'Das Bild konnte nicht geladen werden';

  @override
  String get multiplePermissionsDenied => 'Berechtigungen fehlen';

  @override
  String get multiplePermissionsDeniedMessage =>
      'Bitte aktiviere die verweigerten Berechtigungen in den Einstellungen deines Geräts unter Berechtigungen.';

  @override
  String get surveyFinishTitle => 'Umfrage abschließen';

  @override
  String get surveyStartTitle => 'Neue Umfrage';

  @override
  String get sensorDataHistory => 'Verlaufsdaten';

  @override
  String get saveReading => 'Messung speichern';

  @override
  String get scanning => 'Suche läuft';

  @override
  String get bluetoothTurnedOff => 'Bluetooth ist ausgeschaltet';

  @override
  String get sensorNotFound => 'Sensor nicht gefunden';

  @override
  String get sensorNotSpecified => 'Sensor nicht angegeben';

  @override
  String get sensorData => 'Sensordaten';

  @override
  String get calendar => 'Kalender';

  @override
  String get day => 'Tag';

  @override
  String get week => 'Woche';

  @override
  String get surveyName => 'Umfragename';

  @override
  String get end => 'Ende';

  @override
  String get sensorHistory => 'Sensorverlauf';

  @override
  String get dateFrom => 'Datum von';

  @override
  String get dateTo => 'Datum bis';

  @override
  String get clearFilters => 'Filter zurücksetzen';

  @override
  String get apply => 'Anwenden';

  @override
  String get thisWeek => 'Diese Woche';

  @override
  String get from => 'Von';

  @override
  String get to => 'Bis';

  @override
  String get date => 'Datum';

  @override
  String get temperature => 'Temperatur';

  @override
  String get humidity => 'Luftfeuchtigkeit';

  @override
  String get sentToServer => 'An den Server gesendet';

  @override
  String get menu => 'Menü';

  @override
  String get map => 'Karte';

  @override
  String get today => 'Heute';

  @override
  String get latidude => 'Breitengrad';

  @override
  String get longitude => 'Längengrad';

  @override
  String get time => 'Zeit';

  @override
  String get theLocationDataHasBeenSubmitedToServer =>
      'Dieser Standort wurde bereits an den Server gesendet';

  @override
  String get theLocationDataHasNotBeenSubmitedToServer =>
      'Dieser Standort wurde noch nicht an den Server gesendet';

  @override
  String get surveyHasBeenComplitedInThisLocation =>
      'An diesem Ort wurde eine Umfrage ausgefüllt';

  @override
  String get enterResponse => 'Antwort eingeben';

  @override
  String get kestrelDrop2 => 'Kestrel Drop 2-Sensor';

  @override
  String get sensorId => 'Sensor-ID';

  @override
  String get serverNotResponding =>
      'Der Server antwortet nicht. Stelle sicher, dass du eine korrekte API-URL angegeben hast. Falls ja, versuche es später erneut.';

  @override
  String get bluetoothRequired =>
      'Schalte Bluetooth ein, um die Umfrage abzuschließen.';

  @override
  String get bluetooth => 'Bluetooth';

  @override
  String get surveyFinished =>
      'Die Umfrage ist beendet. Du kannst sie nicht mehr ausfüllen.';

  @override
  String get sensorMac => 'MAC-Adresse des Sensors';

  @override
  String get sensorIdServerNotFound => 'Sensor-ID auf dem Server nicht gefunden';

  @override
  String get noInternetConnection => 'Keine Internetverbindung';

  @override
  String get betterExperienceTurnOnInternet =>
      'Für eine bessere Erfahrung aktiviere die Internetverbindung';

  @override
  String get loadingMacFailed => 'MAC-Adresse konnte nicht geladen werden';

  @override
  String get sensorNotFoundDialogTitle => 'Sensor nicht gefunden';

  @override
  String get sensorNotFoundDialogContent =>
      'Temperatursensor nicht gefunden. Die Umfrage wird ohne Temperaturdaten gesendet. Bitte stelle sicher, dass du den Sensor bei dir hast und dass sein Akku geladen ist.';

  @override
  String get thanksForCompletingTheSurvey =>
      'Danke, dass du die Umfrage abgeschlossen hast.';

  @override
  String nextSurveyWillAppearIn(String time) {
    return 'Die nächste Umfrage erscheint in $time.';
  }

  @override
  String get nextSurveyIsReadyToComplete =>
      'Die nächste Umfrage ist bereits zum Ausfüllen bereit.';

  @override
  String loginFailedServerRespondedWithStatusCode(int code) {
    return 'Anmeldung fehlgeschlagen. Der Server hat mit Code $code geantwortet. Bitte versuche es später erneut.';
  }

  @override
  String get weWereUnableToDetermineTheServerAvailibility =>
      'Aufgrund bestimmter rechtlicher Einschränkungen müssen wir feststellen, ob du die angegebene API-Adresse verwenden darfst. Wir konnten dies derzeit jedoch nicht überprüfen. Bitte versuche es später erneut.';

  @override
  String get theServerYouProvidedIsNotAllowedInYourLocation =>
      'Der von dir angegebene Server ist an deinem Standort nicht zulässig.';

  @override
  String get help => 'Hilfe';

  @override
  String get contact => 'Kontakt';

  @override
  String get errorLoadingContacts =>
      'Beim Laden der Kontakte ist ein Fehler aufgetreten. Stelle sicher, dass du mit dem Internet verbunden bist, und versuche es später erneut.';

  @override
  String get refreshContacts => 'Aktualisieren';

  @override
  String get noContacts =>
      'Der Studienadministrator hat keine Kontakttelefonnummern definiert.';

  @override
  String get call => 'Anrufen';

  @override
  String get couldNotMakeCall => 'Der Anruf konnte nicht durchgeführt werden.';

  @override
  String get warning => 'Warnung';

  @override
  String get noSensorSelected =>
      'Es ist kein Temperatursensor ausgewählt. Sensordaten werden nach Abschluss der Umfrage nicht gespeichert. Wir empfehlen, in die Einstellungen zu gehen und einen Sensor auszuwählen.';

  @override
  String get continueWithoutSensor => 'Ohne Sensor fortfahren';
}
