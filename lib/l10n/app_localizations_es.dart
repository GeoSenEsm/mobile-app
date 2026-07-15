// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get username => 'Nombre de usuario';

  @override
  String get password => 'Contraseña';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get weNeedInformation => 'Necesitamos algunos datos sobre ti';

  @override
  String get letsStart => 'Empecemos';

  @override
  String get lifeSatisfaction => 'Satisfacción con la vida';

  @override
  String get stressLevel => 'Nivel de estrés';

  @override
  String get qualityOfSleep => 'Calidad del sueño';

  @override
  String get next => 'Siguiente';

  @override
  String get healthCondition => 'Estado de salud';

  @override
  String get medicationUse => 'Uso de medicamentos';

  @override
  String get gender => 'Género';

  @override
  String get ageCategory => 'Categoría de edad';

  @override
  String get employment => 'Empleo';

  @override
  String get education => 'Educación';

  @override
  String get greeneryArea => 'Zona verde';

  @override
  String get initializeSurveyQuestion => '¿Quieres empezar la encuesta?';

  @override
  String get start => 'Empezar';

  @override
  String get endSurveyQuestion =>
      '¿Quieres terminar la encuesta?\nDespués no podrás editar tus respuestas.';

  @override
  String get finish => 'Terminar';

  @override
  String get error => 'Error';

  @override
  String get nextSurveyTime =>
      'Tiempo restante hasta que finalice la encuesta más urgente';

  @override
  String get surveyDetails => 'Detalles de la encuesta';

  @override
  String get loadingSurveyErrorTryAgainLater =>
      'No se pudo cargar la encuesta. Inténtalo de nuevo más tarde.';

  @override
  String get loadingSurveyError =>
      'Esta encuesta no está activa en este momento. Puede que haya terminado o que aún no esté disponible.';

  @override
  String get answerSubmitError => 'No se pudo enviar la respuesta';

  @override
  String get mainPageTransitionError =>
      'La respuesta se envió correctamente al servidor, pero se produjo un error al volver a la página de inicio. Prueba a reiniciar la aplicación.';

  @override
  String get selectOneOption => 'Selecciona una de las opciones';

  @override
  String get noInternetTryAgain =>
      'No tienes conexión a Internet. Inténtalo de nuevo más tarde';

  @override
  String get woman => 'Mujer';

  @override
  String get man => 'Hombre';

  @override
  String get invalidCredentials => 'Credenciales no válidas';

  @override
  String get passwordNotEmpty => 'La contraseña no puede estar vacía';

  @override
  String passwordTooLong(int max) {
    return 'La contraseña no puede tener más de $max caracteres';
  }

  @override
  String get usernameNotEmpty => 'El nombre de usuario no puede estar vacío';

  @override
  String usernameTooLong(int max) {
    return 'El nombre de usuario no puede tener más de $max caracteres';
  }

  @override
  String get hours => 'horas';

  @override
  String get minutes => 'minutos';

  @override
  String get valueNotEmpty => 'El valor no puede estar vacío';

  @override
  String get errorRetry => 'Error, reintentar';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get usedSensor => 'Tipo de sensor de temperatura';

  @override
  String get save => 'Guardar';

  @override
  String get chooseATemperatureSensorYouReceived =>
      'Elige el sensor de temperatura que has recibido';

  @override
  String get noSensor => 'Sin sensor';

  @override
  String get xiaomiSensor => 'Sensor Xiaomi';

  @override
  String get settings => 'Ajustes';

  @override
  String get editSensor => 'Editar sensor';

  @override
  String get appSettings => 'Ajustes de la aplicación';

  @override
  String get surveyStartBody =>
      'Ya puedes empezar la encuesta. ¿Estás listo/a?';

  @override
  String get surveyFinishBody =>
      'La encuesta está a punto de terminar. ¡Vamos allá!';

  @override
  String get pleaseEnterNumber => 'Por favor, introduce un número';

  @override
  String get enterNumber => 'Introduce un número';

  @override
  String get pleaseEnterValidNumber => 'Por favor, introduce un número válido';

  @override
  String get pleaseEnterLeastZeroNumber =>
      'Por favor, introduce un número mayor o igual a 0';

  @override
  String get pleaseEnterNumberLessThan1000 =>
      'Por favor, introduce un número menor que 1000';

  @override
  String get pleaseEnterAnyText => 'Por favor, escribe tu respuesta';

  @override
  String get pleaseEnterShorterText =>
      'Por favor, escribe tu respuesta con menos de 1000 caracteres';

  @override
  String get selectAtLeastOneOption =>
      'Por favor, selecciona al menos una opción';

  @override
  String get apiUrl => 'URL de la API';

  @override
  String get apiUrlEmptyErrorMessage => 'La URL de la API no puede estar vacía';

  @override
  String get apiUrlInvalidFormatErrorMessage => 'Formato no válido';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get logountConfirmationQuestion =>
      '¿Seguro que quieres cerrar sesión? Se perderán todos los datos que no se hayan enviado al servidor.';

  @override
  String get couldNotLogout =>
      'No se pudo cerrar sesión, inténtalo de nuevo más tarde.';

  @override
  String get credentialsExpired =>
      'Tu token ha caducado, vuelve a introducir la contraseña.';

  @override
  String get profile => 'Perfil';

  @override
  String get couldNotReachTheServer =>
      'No se pudo enviar la solicitud, inténtalo de nuevo más tarde.';

  @override
  String get somethingWentWrong =>
      'Algo ha salido mal, inténtalo de nuevo más tarde.';

  @override
  String get locationPermissionDenied => 'Permiso de ubicación denegado';

  @override
  String get locationPermissionDeniedMessage =>
      'Se necesita permiso de ubicación para completar las encuestas. Por favor, pulsa \"Abrir ajustes\" y activa el permiso de ubicación.';

  @override
  String get locationBackgroundPermissionDenied =>
      'Falta permiso de ubicación en segundo plano';

  @override
  String get locationBackgroundPermissionDeniedMessage =>
      'Se recomienda activar el permiso de ubicación en segundo plano. Por favor, pulsa \"Abrir ajustes\" y elige \"Permitir siempre\".';

  @override
  String get openSettings => 'Abrir ajustes';

  @override
  String get close => 'Cerrar';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get privacy => 'Privacidad';

  @override
  String get privacySettings => 'Ajustes de privacidad';

  @override
  String get allowTrackLocation => 'Permitir el seguimiento de la ubicación';

  @override
  String get timeFrom => 'Hora desde';

  @override
  String get timeTo => 'Hora hasta';

  @override
  String get notifyMeAboutSurveys => 'Notificarme sobre las encuestas';

  @override
  String get openPrivacyPolicy => 'Abrir la política de privacidad';

  @override
  String get changePassword => 'Cambiar contraseña';

  @override
  String get currentPassword => 'Contraseña actual';

  @override
  String get newPassword => 'Nueva contraseña';

  @override
  String get retypePassword => 'Repetir contraseña';

  @override
  String get passwordChangedSuccessfully =>
      '¡Tu contraseña se ha cambiado correctamente!';

  @override
  String get ok => 'Ok';

  @override
  String get currentPasswordMustNotBeEmpty =>
      'La contraseña actual no puede estar vacía';

  @override
  String get minNewPasswordLenError => 'La longitud mínima es de 8 caracteres';

  @override
  String get retypePasswordMustBeEqualToNewPassword =>
      'La nueva contraseña no coincide';

  @override
  String get iAcceptPrivacyPolicy => 'Acepto la política de privacidad';

  @override
  String get scrollToTheVeryBottom => 'Desplázate hasta el final';

  @override
  String get loadingImageFailed => 'No se pudo cargar la imagen';

  @override
  String get multiplePermissionsDenied => 'Faltan permisos';

  @override
  String get multiplePermissionsDeniedMessage =>
      'Por favor, activa los permisos denegados en los ajustes de tu dispositivo, en la sección Permisos.';

  @override
  String get surveyFinishTitle => 'Finalizando encuesta';

  @override
  String get surveyStartTitle => 'Nueva encuesta';

  @override
  String get sensorDataHistory => 'Lecturas históricas';

  @override
  String get saveReading => 'Guardar lectura';

  @override
  String get scanning => 'Buscando';

  @override
  String get bluetoothTurnedOff => 'El Bluetooth está apagado';

  @override
  String get sensorNotFound => 'No se detectó el sensor';

  @override
  String get sensorNotSpecified => 'Sensor no especificado';

  @override
  String get sensorData => 'Datos del sensor';

  @override
  String get calendar => 'Calendario';

  @override
  String get day => 'Día';

  @override
  String get week => 'Semana';

  @override
  String get surveyName => 'Nombre de la encuesta';

  @override
  String get end => 'Fin';

  @override
  String get sensorHistory => 'Historial del sensor';

  @override
  String get dateFrom => 'Fecha desde';

  @override
  String get dateTo => 'Fecha hasta';

  @override
  String get clearFilters => 'Borrar filtros';

  @override
  String get apply => 'Aplicar';

  @override
  String get thisWeek => 'Esta semana';

  @override
  String get from => 'Desde';

  @override
  String get to => 'Hasta';

  @override
  String get date => 'Fecha';

  @override
  String get temperature => 'Temperatura';

  @override
  String get humidity => 'Humedad';

  @override
  String get sentToServer => 'Enviado al servidor';

  @override
  String get menu => 'Menú';

  @override
  String get map => 'Mapa';

  @override
  String get today => 'Hoy';

  @override
  String get latidude => 'Latitud';

  @override
  String get longitude => 'Longitud';

  @override
  String get time => 'Hora';

  @override
  String get theLocationDataHasBeenSubmitedToServer =>
      'Esta ubicación ya se ha enviado al servidor';

  @override
  String get theLocationDataHasNotBeenSubmitedToServer =>
      'Esta ubicación aún no se ha enviado al servidor';

  @override
  String get surveyHasBeenComplitedInThisLocation =>
      'Se ha rellenado una encuesta en esta ubicación';

  @override
  String get enterResponse => 'Introducir respuesta';

  @override
  String get kestrelDrop2 => 'Sensor Kestrel Drop 2';

  @override
  String get sensorId => 'ID del sensor';

  @override
  String get serverNotResponding =>
      'El servidor no responde. Asegúrate de haber proporcionado una URL de API correcta. Si es así, inténtalo de nuevo más tarde.';

  @override
  String get bluetoothRequired => 'Activa el Bluetooth para completar la encuesta.';

  @override
  String get bluetooth => 'Bluetooth';

  @override
  String get surveyFinished =>
      'La encuesta ha terminado. Ya no puedes completarla.';

  @override
  String get sensorMac => 'Dirección MAC del sensor';

  @override
  String get sensorIdServerNotFound =>
      'ID del sensor no encontrado en el servidor';

  @override
  String get noInternetConnection => 'Sin conexión a Internet';

  @override
  String get betterExperienceTurnOnInternet =>
      'Para una mejor experiencia, activa la conexión a Internet';

  @override
  String get loadingMacFailed => 'No se pudo cargar la dirección MAC';

  @override
  String get sensorNotFoundDialogTitle => 'Sensor no encontrado';

  @override
  String get sensorNotFoundDialogContent =>
      'Sensor de temperatura no encontrado. La encuesta se enviará sin datos de temperatura. Por favor, asegúrate de tener el sensor contigo y de que la batería esté cargada.';

  @override
  String get thanksForCompletingTheSurvey =>
      'Gracias por completar la encuesta.';

  @override
  String nextSurveyWillAppearIn(String time) {
    return 'La próxima encuesta aparecerá en $time.';
  }

  @override
  String get nextSurveyIsReadyToComplete =>
      'La próxima encuesta ya está lista para completar.';

  @override
  String loginFailedServerRespondedWithStatusCode(int code) {
    return 'Error al iniciar sesión. El servidor respondió con el código $code. Inténtalo de nuevo más tarde.';
  }

  @override
  String get weWereUnableToDetermineTheServerAvailibility =>
      'Debido a ciertas restricciones legales, necesitamos determinar si tienes permiso para usar la dirección de API proporcionada. Sin embargo, no hemos podido verificarlo en este momento. Inténtalo de nuevo más tarde.';

  @override
  String get theServerYouProvidedIsNotAllowedInYourLocation =>
      'El servidor que has proporcionado no está permitido en tu ubicación.';

  @override
  String get help => 'Ayuda';

  @override
  String get contact => 'Contacto';

  @override
  String get errorLoadingContacts =>
      'Se produjo un error al cargar los contactos. Asegúrate de estar conectado a Internet e inténtalo de nuevo más tarde.';

  @override
  String get refreshContacts => 'Actualizar';

  @override
  String get noContacts =>
      'El administrador del estudio no ha definido ningún número de teléfono de contacto.';

  @override
  String get call => 'Llamar';

  @override
  String get couldNotMakeCall => 'No se pudo realizar la llamada.';

  @override
  String get warning => 'Advertencia';

  @override
  String get noSensorSelected =>
      'No se ha seleccionado ningún sensor de temperatura. Los datos del sensor no se guardarán después de completar la encuesta. Te sugerimos que vayas a los ajustes para seleccionar un sensor.';

  @override
  String get continueWithoutSensor => 'Continuar sin sensor';
}
