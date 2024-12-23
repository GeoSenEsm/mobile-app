import 'package:background_fetch/background_fetch.dart';
import 'package:devicelocale/devicelocale.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:survey_frontend/domain/local_services/notification_service.dart';
import 'package:survey_frontend/presentation/backgroud.dart';
import 'package:survey_frontend/presentation/app_styles.dart';
import 'package:survey_frontend/presentation/bindings/accept_privacy_policy_bindings.dart';
import 'package:survey_frontend/presentation/bindings/bindings_options.dart';
import 'package:survey_frontend/presentation/bindings/calendar_bindings.dart';
import 'package:survey_frontend/presentation/bindings/change_password_bindings.dart';
import 'package:survey_frontend/presentation/bindings/home_bindings.dart';
import 'package:survey_frontend/presentation/bindings/initial_bindings.dart';
import 'package:survey_frontend/presentation/bindings/initial_survey_bindings.dart';
import 'package:survey_frontend/presentation/bindings/loading_bindings.dart';
import 'package:survey_frontend/presentation/bindings/login_bindings.dart';
import 'package:survey_frontend/presentation/bindings/logout_confirmation_bindings.dart';
import 'package:survey_frontend/presentation/bindings/notifications_settings_bindings.dart';
import 'package:survey_frontend/presentation/bindings/privacy_settings_bindings.dart';
import 'package:survey_frontend/presentation/bindings/profile_bindings.dart';
import 'package:survey_frontend/presentation/bindings/reinsert_credentials_bindings.dart';
import 'package:survey_frontend/presentation/bindings/sensor_data_bindings.dart';
import 'package:survey_frontend/presentation/bindings/sensor_data_history_bindings.dart';
import 'package:survey_frontend/presentation/bindings/sensors_bindings.dart';
import 'package:survey_frontend/presentation/bindings/menu_bindings.dart';
import 'package:survey_frontend/presentation/bindings/survey_end_bindings.dart';
import 'package:survey_frontend/presentation/bindings/survey_start_bindings.dart';
import 'package:survey_frontend/presentation/bindings/welcome_screen_bindings.dart';
import 'package:survey_frontend/presentation/screens/calendar/calendar_screen.dart';
import 'package:survey_frontend/presentation/screens/calendar/navigation/calendar_navigator_observer.dart';
import 'package:survey_frontend/presentation/screens/change_password_screen.dart';
import 'package:survey_frontend/presentation/screens/home/home_screen.dart';
import 'package:survey_frontend/presentation/screens/initial_survey/initial_survey_screen.dart';
import 'package:survey_frontend/presentation/screens/loading_screen.dart';
import 'package:survey_frontend/presentation/screens/login_screen.dart';
import 'package:survey_frontend/presentation/screens/logout_confirmation_screen.dart';
import 'package:survey_frontend/presentation/screens/notifications_settings_screen.dart';
import 'package:survey_frontend/presentation/screens/password_change_confirmation_screen.dart';
import 'package:survey_frontend/presentation/screens/privacy_policy/screens/accept_privacy_policy_screen.dart';
import 'package:survey_frontend/presentation/screens/privacy_settings_screen.dart';
import 'package:survey_frontend/presentation/screens/profile_screen.dart';
import 'package:survey_frontend/presentation/screens/reinsert_credentials_screen.dart';
import 'package:survey_frontend/presentation/screens/sensor_data/navigation/sensor_navigator_observer.dart';
import 'package:survey_frontend/presentation/screens/sensor_data/sensor_data_screen.dart';
import 'package:survey_frontend/presentation/screens/sensor_data_history/navigation/sensor_data_history_navigator_observer.dart';
import 'package:survey_frontend/presentation/screens/sensor_data_history/sensor_data_history_screen.dart';
import 'package:survey_frontend/presentation/screens/sensors_screen.dart';
import 'package:survey_frontend/presentation/screens/menu/menu_screen.dart';
import 'package:survey_frontend/presentation/screens/survey/survey_end_screen.dart';
import 'package:survey_frontend/presentation/screens/survey/survey_start_screen.dart';
import 'package:survey_frontend/presentation/screens/welcome_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:survey_frontend/presentation/static/routes.dart';
import 'package:survey_frontend/presentation/static/static_variables.dart';

void main() async {
  await initSentry();
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterBluePlus.isSupported;
  await FlutterBluePlus.adapterState.first;
  await NotificationService.initialize();
  await GetStorage.init();
  final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
  InitialBindings().dependencies();
  await prepareWorkManager();
  StaticVariables.lang = await _getCurrentLocale();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(GetMaterialApp(
    title: 'UrbEaT',
    navigatorObservers: [routeObserver, SensorNavigatorObserver(), CalendarNavigatorObserver(), SensorDataHistoryNavigatorObserver()],
    debugShowCheckedModeBanner: false,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: Locale(StaticVariables.lang, ''),
    initialBinding: InitialBindings(),
    theme: AppStyles.lightTheme,
    initialRoute: Routes.home,
    getPages: [
      GetPage(
          name: Routes.login,
          page: () => const LoginScreen(),
          binding: LoginBindings()),
      GetPage(
          name: Routes.home,
          page: () => const HomeScreen(),
          binding: HomeBindings()),
      GetPage(
        name: '/surveystart',
        page: () => SurveyStartScreen(),
        binding: SurveyStartBindings(),
      ),
      GetPage(
          name: Routes.welcome,
          page: () => const WelcomeScreen(),
          binding: WelcomeScreenBindings()),
      GetPage(
          name: '/submitSurvey',
          page: () => const SurveyEndScreen(),
          binding: SurveyEndBindings()),
      GetPage(
          name: Routes.loading,
          page: () => const LoadingScreen(),
          binding: LoadingBindings()),
      GetPage(
          name: Routes.initialSurveyQuestions,
          page: () => InitialSurveyScreen(),
          binding: InitialSurveyBindings()),
      GetPage(
          name: Routes.sensors,
          page: () => const SensorsScreen(),
          binding: SensorsBindings()),
      GetPage(
          name: Routes.settings,
          page: () => const MenuScreen(),
          binding: MenuBindings()),
      GetPage(
        name: Routes.logoutConfirmation,
        page: () => LogoutConfirmationScreen(),
        binding: LogoutConfirmationBindings(),
      ),
      GetPage(
        name: Routes.reinsertCredentials,
        page: () => const ReinsertCredentialsScreen(),
        binding: ReinsertCredentialsBindings(),
      ),
      GetPage(
        name: Routes.profile,
        page: () => const ProfileScreen(),
        binding: ProfileBindings(),
      ),
      GetPage(
          name: Routes.privacySettings,
          page: () => const PrivacySettingsScreen(),
          binding: PrivacySettingsBindings()),
      GetPage(
          name: Routes.notifications,
          page: () => const NotificationsSettingsScreen(),
          binding: NotificationsSettingsBindings()),
      GetPage(
          name: Routes.changePassword,
          page: () => const ChangePasswordScreen(),
          binding: ChangePasswordBindings()),
      GetPage(
          name: Routes.changePasswordConfirmation,
          page: () => const PasswordChangeConfirmationScreen()),
      GetPage(
          name: Routes.acceptPrivacyPolicy,
          page: () => const AcceptPrivacyPolicyScreen(),
          binding: AcceptPrivacyPolicyBindings()),
      GetPage(
          name: Routes.sensorDataScreen,
          page: () => const SensorDataScreen(),
          binding: SensorDataBindings()),
      GetPage(
          name: Routes.calendar,
          page: () => const CalendarScreen(),
          binding: CalendarBindings()),
                GetPage(
          name: Routes.sensorDataHistory,
          page: () => const SensorDataHistoryScreen(),
          binding: SensorDataHistoryBindings())
    ],
  ));
}

Future<BindingOptions> _getBindingOptions() async {
  return BindingOptions(
      locationAlwaysGranted: await Permission.locationAlways.status.isGranted);
}

Future<String> _getCurrentLocale() async {
  final fullLocale = await Devicelocale.currentLocale;
  var locale = fullLocale!.split('-')[0];
  List<String> supportedLocalesCodes = AppLocalizations.supportedLocales
      .map((locale) => locale.languageCode)
      .toList();
  if (!supportedLocalesCodes.contains(locale)) {
    locale = 'en';
  }
  return locale;
}

Future<void> prepareWorkManager() async {
  await BackgroundFetch.configure(
      BackgroundFetchConfig(
          minimumFetchInterval: 20,
          stopOnTerminate: false,
          startOnBoot: true,
          enableHeadless: true),
      backgroundTask);
  await BackgroundFetch.registerHeadlessTask(backgroundHeadlessTask);
}

void backgroundHeadlessTask(HeadlessTask task) async {
  backgroundTask(task.taskId);
}
