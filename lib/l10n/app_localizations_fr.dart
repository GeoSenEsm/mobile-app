// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get username => 'Nom d\'utilisateur';

  @override
  String get password => 'Mot de passe';

  @override
  String get login => 'Connexion';

  @override
  String get weNeedInformation =>
      'Nous avons besoin de quelques informations à ton sujet';

  @override
  String get letsStart => 'Commençons';

  @override
  String get lifeSatisfaction => 'Satisfaction dans la vie';

  @override
  String get stressLevel => 'Niveau de stress';

  @override
  String get qualityOfSleep => 'Qualité du sommeil';

  @override
  String get next => 'Suivant';

  @override
  String get healthCondition => 'État de santé';

  @override
  String get medicationUse => 'Prise de médicaments';

  @override
  String get gender => 'Genre';

  @override
  String get ageCategory => 'Catégorie d\'âge';

  @override
  String get employment => 'Emploi';

  @override
  String get education => 'Éducation';

  @override
  String get greeneryArea => 'Espace vert';

  @override
  String get initializeSurveyQuestion =>
      'Veux-tu commencer le questionnaire ?';

  @override
  String get start => 'Commencer';

  @override
  String get endSurveyQuestion =>
      'Veux-tu terminer le questionnaire ?\nTu ne pourras plus modifier tes réponses par la suite.';

  @override
  String get finish => 'Terminer';

  @override
  String get error => 'Erreur';

  @override
  String get nextSurveyTime =>
      'Temps restant avant la fin du questionnaire le plus urgent';

  @override
  String get surveyDetails => 'Détails du questionnaire';

  @override
  String get loadingSurveyErrorTryAgainLater =>
      'Échec du chargement du questionnaire. Veuillez réessayer plus tard.';

  @override
  String get loadingSurveyError =>
      'Ce questionnaire n\'est pas actif actuellement. Il est peut-être terminé ou pas encore disponible.';

  @override
  String get answerSubmitError => 'Échec de l\'envoi de la réponse';

  @override
  String get mainPageTransitionError =>
      'La réponse a été envoyée avec succès au serveur, mais une erreur s\'est produite lors du retour à la page d\'accueil. Essaie de redémarrer l\'application.';

  @override
  String get selectOneOption => 'Sélectionne une des options';

  @override
  String get noInternetTryAgain =>
      'Tu n\'as pas de connexion Internet. Réessaie plus tard';

  @override
  String get woman => 'Femme';

  @override
  String get man => 'Homme';

  @override
  String get invalidCredentials => 'Identifiants invalides';

  @override
  String get passwordNotEmpty => 'Le mot de passe ne doit pas être vide';

  @override
  String passwordTooLong(int max) {
    return 'Le mot de passe ne doit pas dépasser $max caractères';
  }

  @override
  String get usernameNotEmpty => 'Le nom d\'utilisateur ne doit pas être vide';

  @override
  String usernameTooLong(int max) {
    return 'Le nom d\'utilisateur ne doit pas dépasser $max caractères';
  }

  @override
  String get hours => 'heures';

  @override
  String get minutes => 'minutes';

  @override
  String get valueNotEmpty => 'La valeur ne doit pas être vide';

  @override
  String get errorRetry => 'Erreur, réessayer';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get usedSensor => 'Type de capteur de température';

  @override
  String get save => 'Enregistrer';

  @override
  String get chooseATemperatureSensorYouReceived =>
      'Choisis le capteur de température que tu as reçu';

  @override
  String get noSensor => 'Aucun capteur';

  @override
  String get xiaomiSensor => 'Capteur Xiaomi';

  @override
  String get settings => 'Paramètres';

  @override
  String get editSensor => 'Modifier le capteur';

  @override
  String get appSettings => 'Paramètres de l\'application';

  @override
  String get surveyStartBody =>
      'Tu peux commencer le questionnaire maintenant. Prêt(e) ?';

  @override
  String get surveyFinishBody =>
      'Le questionnaire va bientôt se terminer. C\'est parti !';

  @override
  String get pleaseEnterNumber => 'Veuillez saisir un nombre';

  @override
  String get enterNumber => 'Saisis un nombre';

  @override
  String get pleaseEnterValidNumber => 'Veuillez saisir un nombre valide';

  @override
  String get pleaseEnterLeastZeroNumber =>
      'Veuillez saisir un nombre supérieur ou égal à 0';

  @override
  String get pleaseEnterNumberLessThan1000 =>
      'Veuillez saisir un nombre inférieur à 1000';

  @override
  String get pleaseEnterAnyText => 'Veuillez écrire ta réponse';

  @override
  String get pleaseEnterShorterText =>
      'Veuillez écrire ta réponse en moins de 1000 caractères';

  @override
  String get selectAtLeastOneOption =>
      'Veuillez sélectionner au moins une option';

  @override
  String get apiUrl => 'URL de l\'API';

  @override
  String get apiUrlEmptyErrorMessage => 'L\'URL de l\'API ne peut pas être vide';

  @override
  String get apiUrlInvalidFormatErrorMessage => 'Format invalide';

  @override
  String get logout => 'Déconnexion';

  @override
  String get logountConfirmationQuestion =>
      'Es-tu sûr(e) de vouloir te déconnecter ? Toutes les données non envoyées au serveur seront perdues.';

  @override
  String get couldNotLogout =>
      'Impossible de se déconnecter, réessaie plus tard.';

  @override
  String get credentialsExpired =>
      'Ton jeton a expiré, saisis à nouveau ton mot de passe.';

  @override
  String get profile => 'Profil';

  @override
  String get couldNotReachTheServer =>
      'Échec de l\'envoi de la requête, veuillez réessayer plus tard.';

  @override
  String get somethingWentWrong =>
      'Une erreur s\'est produite, veuillez réessayer plus tard.';

  @override
  String get locationPermissionDenied => 'Autorisation de localisation refusée';

  @override
  String get locationPermissionDeniedMessage =>
      'L\'autorisation de localisation est nécessaire pour remplir les questionnaires. Veuillez cliquer sur \"Ouvrir les paramètres\" et activer l\'autorisation de localisation.';

  @override
  String get locationBackgroundPermissionDenied =>
      'Autorisation de localisation en arrière-plan manquante';

  @override
  String get locationBackgroundPermissionDeniedMessage =>
      'Il est recommandé d\'activer l\'autorisation de localisation en arrière-plan. Veuillez cliquer sur \"Ouvrir les paramètres\" puis choisir \"Toujours autoriser\".';

  @override
  String get openSettings => 'Ouvrir les paramètres';

  @override
  String get close => 'Fermer';

  @override
  String get notifications => 'Notifications';

  @override
  String get privacy => 'Confidentialité';

  @override
  String get privacySettings => 'Paramètres de confidentialité';

  @override
  String get allowTrackLocation => 'Autoriser le suivi de la localisation';

  @override
  String get timeFrom => 'Heure de début';

  @override
  String get timeTo => 'Heure de fin';

  @override
  String get notifyMeAboutSurveys => 'Me notifier des questionnaires';

  @override
  String get openPrivacyPolicy => 'Ouvrir la politique de confidentialité';

  @override
  String get changePassword => 'Changer le mot de passe';

  @override
  String get currentPassword => 'Mot de passe actuel';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get retypePassword => 'Confirmer le mot de passe';

  @override
  String get passwordChangedSuccessfully =>
      'Ton mot de passe a été modifié avec succès !';

  @override
  String get ok => 'Ok';

  @override
  String get currentPasswordMustNotBeEmpty =>
      'Le mot de passe actuel ne doit pas être vide';

  @override
  String get minNewPasswordLenError =>
      'La longueur minimale est de 8 caractères';

  @override
  String get retypePasswordMustBeEqualToNewPassword =>
      'Le nouveau mot de passe ne correspond pas';

  @override
  String get iAcceptPrivacyPolicy => 'J\'accepte la politique de confidentialité';

  @override
  String get scrollToTheVeryBottom => 'Fais défiler jusqu\'en bas';

  @override
  String get loadingImageFailed => 'Impossible de charger l\'image';

  @override
  String get multiplePermissionsDenied => 'Autorisations manquantes';

  @override
  String get multiplePermissionsDeniedMessage =>
      'Veuillez activer les autorisations refusées dans les paramètres de ton appareil, dans la section Autorisations.';

  @override
  String get surveyFinishTitle => 'Fin du questionnaire';

  @override
  String get surveyStartTitle => 'Nouveau questionnaire';

  @override
  String get sensorDataHistory => 'Relevés historiques';

  @override
  String get saveReading => 'Enregistrer le relevé';

  @override
  String get scanning => 'Recherche en cours';

  @override
  String get bluetoothTurnedOff => 'Le Bluetooth est désactivé';

  @override
  String get sensorNotFound => 'Capteur introuvable';

  @override
  String get sensorNotSpecified => 'Capteur non spécifié';

  @override
  String get sensorData => 'Données du capteur';

  @override
  String get calendar => 'Calendrier';

  @override
  String get day => 'Jour';

  @override
  String get week => 'Semaine';

  @override
  String get surveyName => 'Nom du questionnaire';

  @override
  String get end => 'Fin';

  @override
  String get sensorHistory => 'Historique du capteur';

  @override
  String get dateFrom => 'Date de début';

  @override
  String get dateTo => 'Date de fin';

  @override
  String get clearFilters => 'Effacer les filtres';

  @override
  String get apply => 'Appliquer';

  @override
  String get thisWeek => 'Cette semaine';

  @override
  String get from => 'De';

  @override
  String get to => 'À';

  @override
  String get date => 'Date';

  @override
  String get temperature => 'Température';

  @override
  String get humidity => 'Humidité';

  @override
  String get sentToServer => 'Envoyé au serveur';

  @override
  String get menu => 'Menu';

  @override
  String get map => 'Carte';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get latidude => 'Latitude';

  @override
  String get longitude => 'Longitude';

  @override
  String get time => 'Heure';

  @override
  String get theLocationDataHasBeenSubmitedToServer =>
      'Cette position a déjà été envoyée au serveur';

  @override
  String get theLocationDataHasNotBeenSubmitedToServer =>
      'Cette position n\'a pas encore été envoyée au serveur';

  @override
  String get surveyHasBeenComplitedInThisLocation =>
      'Un questionnaire a été rempli à cet endroit';

  @override
  String get enterResponse => 'Saisir la réponse';

  @override
  String get kestrelDrop2 => 'Capteur Kestrel Drop 2';

  @override
  String get sensorId => 'ID du capteur';

  @override
  String get serverNotResponding =>
      'Le serveur ne répond pas. Assure-toi d\'avoir saisi une URL d\'API correcte. Si c\'est le cas, réessaie plus tard.';

  @override
  String get bluetoothRequired =>
      'Active le Bluetooth pour compléter le questionnaire.';

  @override
  String get bluetooth => 'Bluetooth';

  @override
  String get surveyFinished =>
      'Le questionnaire est terminé. Tu ne peux plus le compléter.';

  @override
  String get sensorMac => 'Adresse MAC du capteur';

  @override
  String get sensorIdServerNotFound =>
      'ID du capteur introuvable sur le serveur';

  @override
  String get noInternetConnection => 'Pas de connexion Internet';

  @override
  String get betterExperienceTurnOnInternet =>
      'Pour une meilleure expérience, active la connexion Internet';

  @override
  String get loadingMacFailed => 'Impossible de charger l\'adresse MAC';

  @override
  String get sensorNotFoundDialogTitle => 'Capteur introuvable';

  @override
  String get sensorNotFoundDialogContent =>
      'Capteur de température introuvable. Le questionnaire sera envoyé sans les données de température. Assure-toi d\'avoir le capteur avec toi et que sa batterie est chargée.';

  @override
  String get thanksForCompletingTheSurvey =>
      'Merci d\'avoir complété le questionnaire.';

  @override
  String nextSurveyWillAppearIn(String time) {
    return 'Le prochain questionnaire apparaîtra dans $time.';
  }

  @override
  String get nextSurveyIsReadyToComplete =>
      'Le prochain questionnaire est déjà prêt à être complété.';

  @override
  String loginFailedServerRespondedWithStatusCode(int code) {
    return 'Échec de la connexion. Le serveur a répondu avec le code $code. Veuillez réessayer plus tard.';
  }

  @override
  String get weWereUnableToDetermineTheServerAvailibility =>
      'En raison de certaines restrictions légales, nous devons déterminer si tu es autorisé(e) à utiliser l\'adresse API fournie. Cependant, nous n\'avons pas pu le vérifier pour le moment. Veuillez réessayer plus tard.';

  @override
  String get theServerYouProvidedIsNotAllowedInYourLocation =>
      'Le serveur que tu as fourni n\'est pas autorisé dans ta région.';

  @override
  String get help => 'Aide';

  @override
  String get contact => 'Contact';

  @override
  String get errorLoadingContacts =>
      'Une erreur s\'est produite lors du chargement des contacts. Assure-toi d\'être connecté(e) à Internet et réessaie plus tard.';

  @override
  String get refreshContacts => 'Actualiser';

  @override
  String get noContacts =>
      'L\'administrateur de l\'étude n\'a défini aucun numéro de téléphone de contact.';

  @override
  String get call => 'Appeler';

  @override
  String get couldNotMakeCall => 'L\'appel n\'a pas pu être passé.';

  @override
  String get warning => 'Avertissement';

  @override
  String get noSensorSelected =>
      'Aucun capteur de température sélectionné. Les données du capteur ne seront pas enregistrées après avoir complété le questionnaire. Nous te suggérons d\'aller dans les paramètres pour sélectionner un capteur.';

  @override
  String get continueWithoutSensor => 'Continuer sans capteur';
}
