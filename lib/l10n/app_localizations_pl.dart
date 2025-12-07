// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get username => 'Nazwa użytkownika';

  @override
  String get password => 'Hasło';

  @override
  String get login => 'Zaloguj się';

  @override
  String get weNeedInformation => 'Potrzebujemy kilku informacji o Tobie';

  @override
  String get letsStart => 'Zaczynamy';

  @override
  String get lifeSatisfaction => 'Zadowolenie z życia';

  @override
  String get stressLevel => 'Poziom stresu';

  @override
  String get qualityOfSleep => 'Jakość snu';

  @override
  String get next => 'Dalej';

  @override
  String get healthCondition => 'Stan zdrowia';

  @override
  String get medicationUse => 'Zażywane leki';

  @override
  String get gender => 'Płeć';

  @override
  String get ageCategory => 'Kategoria wiekowa';

  @override
  String get employment => 'Zatrudnienie';

  @override
  String get education => 'Wykształcenie';

  @override
  String get greeneryArea => 'Tereny zielone';

  @override
  String get initializeSurveyQuestion =>
      'Czy chcesz rozpocząć wypełnianie ankiety?';

  @override
  String get start => 'Rozpoczęcie';

  @override
  String get endSurveyQuestion =>
      'Czy na pewno chcesz zakończyć ankietę?\nNie będziesz mógł potem edytować odpowiedzi.';

  @override
  String get finish => 'Zakończ';

  @override
  String get error => 'Błąd';

  @override
  String get nextSurveyTime =>
      'Pozostały czas do zakończenia najbliższej ankiety';

  @override
  String get surveyDetails => 'Szczegóły ankiety';

  @override
  String get loadingSurveyErrorTryAgainLater =>
      'Nie udało się załadować ankiet. Spróbuj ponownie później.';

  @override
  String get loadingSurveyError => 'Nie udało się załadować wybranej ankiety';

  @override
  String get answerSubmitError => 'Nie udało się przesłać odpowiedzi';

  @override
  String get mainPageTransitionError =>
      'Pomyślnie przesłano odpowiedź na serwer, ale wystąpił błąd podczas powrotu na stronę główną. Spróbuj ponownie uruchomić aplikację.';

  @override
  String get selectOneOption => 'Wybierz jedną z opcji';

  @override
  String get noInternetTryAgain =>
      'Nie masz połączenia z internetem. Spróbuj ponownie później.';

  @override
  String get woman => 'Kobieta';

  @override
  String get man => 'Mężczyzna';

  @override
  String get invalidCredentials => 'Nieprawidłowe dane logowania';

  @override
  String get passwordNotEmpty => 'Hasło nie może być puste';

  @override
  String passwordTooLong(int max) {
    return 'Hasło nie może być dłuższe niż $max znaków';
  }

  @override
  String get usernameNotEmpty => 'Nazwa użytkownika nie może być pusta';

  @override
  String usernameTooLong(int max) {
    return 'Nazwa użytkownika nie może być dłuższa niż $max znaków';
  }

  @override
  String get hours => 'Godzin';

  @override
  String get minutes => 'Minut';

  @override
  String get valueNotEmpty => 'Wartość nie może być pusta';

  @override
  String get errorRetry => 'Błąd, spróbuj ponownie';

  @override
  String get yes => 'Tak';

  @override
  String get no => 'Nie';

  @override
  String get usedSensor => 'Rodzaj czujnika temperatury';

  @override
  String get save => 'Zapisz';

  @override
  String get chooseATemperatureSensorYouReceived =>
      'Wybierz otrzymany przez Ciebie czujnik temperatury';

  @override
  String get noSensor => 'Brak czujnika';

  @override
  String get xiaomiSensor => 'Czujnik Xiaomi';

  @override
  String get settings => 'Ustawienia';

  @override
  String get editSensor => 'Edytuj czujnik';

  @override
  String get appSettings => 'Ustawienia aplikacji';

  @override
  String get surveyStartBody => 'Możesz już rozpocząć ankiete. Jesteś gotów?';

  @override
  String get surveyFinishBody => 'Ankieta zaraz się skończy. Do dzieła!';

  @override
  String get pleaseEnterNumber => 'Proszę wpisać liczbę';

  @override
  String get enterNumber => 'Wpisz liczbę';

  @override
  String get pleaseEnterValidNumber => 'Proszę wpisać poprawną liczbę';

  @override
  String get pleaseEnterLeastZeroNumber =>
      'Proszę wpisać liczbę liczbę większą lub równą 0';

  @override
  String get pleaseEnterNumberLessThan1000 =>
      'Proszę wpisać liczbę mniejszą od 1000';

  @override
  String get pleaseEnterAnyText => 'Proszę uzupełnić odpowiedź';

  @override
  String get pleaseEnterShorterText => 'Odpowiedź ma więcej niż 1000 znaków';

  @override
  String get selectAtLeastOneOption => 'Proszę wybrać przynajmniej jedną opcję';

  @override
  String get apiUrl => 'Adres API';

  @override
  String get apiUrlEmptyErrorMessage => 'Adres API nie może być pusty';

  @override
  String get apiUrlInvalidFormatErrorMessage => 'Niepoprawny format';

  @override
  String get logout => 'Wyloguj się';

  @override
  String get logountConfirmationQuestion =>
      'Czy na pewno chcesz się wylogować? Wszystkie dane, które nie zostały przesłane na serwer, zostaną utracone';

  @override
  String get couldNotLogout =>
      'Nie udało się wylogować, spróbuj ponownie później.';

  @override
  String get credentialsExpired =>
      'Twój token wygasł, ponownie wprowadź hasło.';

  @override
  String get profile => 'Profil';

  @override
  String get couldNotReachTheServer =>
      'Nie udało się wysłać żądania, spróbuj ponownie później.';

  @override
  String get somethingWentWrong =>
      'Coś poszło nie tak, spróbuj ponownie później.';

  @override
  String get locationPermissionDenied => 'Odmowa dostępu do lokalizacji';

  @override
  String get locationPermissionDeniedMessage =>
      'Dostęp do lokalizacji jest wymagany aby wypełnić ankietę. Proszę nacisnąć \"Otwórz ustawienia\" i włączyć uprawnienia lokalizacji.';

  @override
  String get locationBackgroundPermissionDenied =>
      'Brak uprawnień do lokalizacji w tle';

  @override
  String get locationBackgroundPermissionDeniedMessage =>
      'Zalecane jest włączenie uprawnienia na dostęp do lokalizacji w tle. Proszę kliknąć \"Otwórz ustawienia\" a następnie wybrać \"Zawsze zezwalaj\".';

  @override
  String get openSettings => 'Otwórz ustawienia';

  @override
  String get close => 'Zamknij';

  @override
  String get notifications => 'Powiadomienia';

  @override
  String get privacy => 'Prywatność';

  @override
  String get privacySettings => 'Ustawienia prywatności';

  @override
  String get allowTrackLocation => 'Zezwalaj na śledzenie lokalizacji';

  @override
  String get timeFrom => 'Godzina od';

  @override
  String get timeTo => 'Godzina do';

  @override
  String get notifyMeAboutSurveys => 'Powiadom mnie o ankietach';

  @override
  String get openPrivacyPolicy => 'Otwórz politykę prywatności';

  @override
  String get changePassword => 'Zmiana hasła';

  @override
  String get currentPassword => 'Aktualne hasło';

  @override
  String get newPassword => 'Nowe hasło';

  @override
  String get retypePassword => 'Powtórz hasło';

  @override
  String get passwordChangedSuccessfully =>
      'Twoje hasło zostało pomyślnie zmienione!';

  @override
  String get ok => 'Ok';

  @override
  String get currentPasswordMustNotBeEmpty =>
      'Aktualne hasło nie może być puste';

  @override
  String get minNewPasswordLenError => 'Minimalna długość wynosi 8 znaków';

  @override
  String get retypePasswordMustBeEqualToNewPassword =>
      'Źle przepisane nowe hasło';

  @override
  String get iAcceptPrivacyPolicy => 'Akceptuję politykę prywatności';

  @override
  String get scrollToTheVeryBottom => 'Przewiń na sam dół';

  @override
  String get loadingImageFailed => 'Nie udało się załadować zdjęcia';

  @override
  String get multiplePermissionsDenied => 'Brakuje uprawnień';

  @override
  String get multiplePermissionsDeniedMessage =>
      'Włącz brakujące uprawnienia w ustawieniach urządzenia. Przejdź do Uprawnienia i włącz odrzucone.';

  @override
  String get surveyFinishTitle => 'Koniec Ankiety';

  @override
  String get surveyStartTitle => 'Nowa Ankieta';

  @override
  String get sensorDataHistory => 'Historyczne odczyty';

  @override
  String get saveReading => 'Zapisz odczyt';

  @override
  String get scanning => 'Skanowanie';

  @override
  String get bluetoothTurnedOff => 'Bluetooth jest wyłączony';

  @override
  String get sensorNotFound => 'Nie znaleziono czujnika';

  @override
  String get sensorNotSpecified => 'Nie wybrano czujnika';

  @override
  String get sensorData => 'Dane z czujnika';

  @override
  String get calendar => 'Kalendarz';

  @override
  String get day => 'Dzień';

  @override
  String get week => 'Tydzień';

  @override
  String get surveyName => 'Nazwa ankiety';

  @override
  String get end => 'Zakończenie';

  @override
  String get sensorHistory => 'Historia czujnika';

  @override
  String get dateFrom => 'Data od';

  @override
  String get dateTo => 'Data do';

  @override
  String get clearFilters => 'Wyczyść filtry';

  @override
  String get apply => 'Zastosuj';

  @override
  String get thisWeek => 'Ten tydzień';

  @override
  String get from => 'Od';

  @override
  String get to => 'Do';

  @override
  String get date => 'Data';

  @override
  String get temperature => 'Temperatura';

  @override
  String get humidity => 'Wilgotność';

  @override
  String get sentToServer => 'Przesłano na serwer';

  @override
  String get menu => 'Menu';

  @override
  String get map => 'Mapa';

  @override
  String get today => 'Dzisiaj';

  @override
  String get latidude => 'Szerokość geograficzna';

  @override
  String get longitude => 'Długość geograficzna';

  @override
  String get time => 'Czas';

  @override
  String get theLocationDataHasBeenSubmitedToServer =>
      'Ta lokalizacja została wysłana na serwer';

  @override
  String get theLocationDataHasNotBeenSubmitedToServer =>
      'Ta lokalizacja nie została jeszcze wysłana na serwer';

  @override
  String get surveyHasBeenComplitedInThisLocation =>
      'W tym miejscu wypełniono ankietę';

  @override
  String get enterResponse => 'Podaj odpowiedź';

  @override
  String get kestrelDrop2 => 'Czujnik Kestrel Drop 2';

  @override
  String get sensorId => 'Id sensora';

  @override
  String get serverNotResponding =>
      'Serwer nie odpowiada. Upewnij się, że podałeś poprawny adres API. Jeśli tak, spróbuj ponownie później.';

  @override
  String get bluetoothRequired => 'Włącz bluetooth, aby wypełnić ankietę.';

  @override
  String get bluetooth => 'Bluetooth';

  @override
  String get surveyFinished =>
      'Ankieta zakończyła się. Nie można jej już wypełnić.';

  @override
  String get sensorMac => 'Adres MAC czujnika';

  @override
  String get sensorIdServerNotFound =>
      'Id czujnika nie zostało znalezione na serwerze';

  @override
  String get noInternetConnection => 'Brak połączenia z internetem';

  @override
  String get betterExperienceTurnOnInternet =>
      'Dla lepszego doświadczenia z użytkowania, proszę włączyć połączenie z internetem';

  @override
  String get loadingMacFailed => 'Błąd ładowania adresu MAC';

  @override
  String get sensorNotFoundDialogTitle => 'Nie znaleziono czujnika';

  @override
  String get sensorNotFoundDialogContent =>
      'Nie znaleziono czujnika temparatury. Anketa zostanie wysłana bez danych o temperaturze. Upewnij się, że masz przy sobie czujnik, oraz że ma on nałądowaną baterię.';

  @override
  String get thanksForCompletingTheSurvey =>
      'Dziękujemy za wypełnienie ankiety.';

  @override
  String nextSurveyWillAppearIn(String time) {
    return 'Następna ankieta pojawi się za $time';
  }

  @override
  String get nextSurveyIsReadyToComplete =>
      'Kolejna ankieta jest już gotowa do wypełnienia.';

  @override
  String loginFailedServerRespondedWithStatusCode(int code) {
    return 'Nie udało się zalogować. Server odpowiedział kodem $code. Spróbój ponownie później.';
  }

  @override
  String get weWereUnableToDetermineTheServerAvailibility =>
      'Z powodu pewnych ograniczeń prawnych musimy ustalić, czy możesz korzystać z podanego adresu API. Niestety, w tej chwili nie udało nam się tego zweryfikować. Spróbuj ponownie później.';

  @override
  String get theServerYouProvidedIsNotAllowedInYourLocation =>
      'Serwer, który podałeś, jest niedozwolony w Twojej lokalizacji.';

  @override
  String get help => 'Pomoc';

  @override
  String get contact => 'Kontakt';

  @override
  String get errorLoadingContacts =>
      'Wystąpił błąd podczas ładowania kontaktów. Upewnij się, że masz połączenie z Internetem i spróbój ponownie później.';

  @override
  String get refreshContacts => 'Odśwież';

  @override
  String get noContacts =>
      'Administrator badania nie zdefiniował żadnych numerów telefonu do kontaktu.';

  @override
  String get call => 'Zadzwoń';

  @override
  String get couldNotMakeCall => 'Nie udało się wykonać połączenia.';

  @override
  String get warning => 'Ostrzeżenie';

  @override
  String get noSensorSelected =>
      'Nie wybrano czujnika temperatury. Dane sensoryczne nie zostaną zapisane po wypełnieniu ankiety. Sugerujemy przejście do ustawień, aby wybrać czujnik.';

  @override
  String get continueWithoutSensor => 'Kontunuuj bez czujnika';
}
