import 'package:flutter/material.dart';

class AppStyles {
  static const Color backgroundSecondary = Color.fromARGB(255, 244, 244, 244);
  static const Color onBackgroundSecondary = Colors.white;
  static final MaterialColor _primaryColor =
      MaterialColor(const Color.fromRGBO(165, 214, 35, 0.46).value, const {});
  static final MaterialColor _primaryColorDisabled = MaterialColor(
    const Color.fromRGBO(165, 214, 35, 0.2).value,
    const {},
  );
  static const Color _appNameColor = Color.fromARGB(255, 61, 68, 79);
  static const Color _appNameColorDisabled = Color.fromARGB(150, 61, 68, 79);
  static const Color primaryDark = Color.fromARGB(255, 117, 161, 0);
  static const Color primary = Color.fromARGB(255, 165, 214, 35);

  static ThemeData lightTheme = ThemeData(
      scaffoldBackgroundColor: Colors.white,
      primaryColor: primary,
      primaryColorLight: const Color.fromARGB(117, 166, 214, 35),
      primaryColorDark: primaryDark,
      cardColor: const Color.fromARGB(255, 252, 176, 64),
      indicatorColor: const Color(0xFFCE7B00),
      hintColor: const Color.fromARGB(255, 230, 166, 72),
      highlightColor: const Color(0xFFCE7B00),
      unselectedWidgetColor: Colors.white,
      fontFamily: 'Roboto',
      shadowColor: Colors.black,
      textTheme: const TextTheme(bodyLarge: TextStyle(fontSize: 20)),
      radioTheme: const RadioThemeData(
          fillColor: WidgetStatePropertyAll(_appNameColor)),
      dialogTheme: DialogTheme(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          )),
      checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primary;
        }

        return Colors.transparent;
      })),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _appNameColor
      ),
      datePickerTheme: DatePickerThemeData(
          backgroundColor: onBackgroundSecondary,
          todayForegroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }

            return _appNameColor;
          }),
          todayBackgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return _primaryColor;
            }

            return Colors.transparent;
          }),
          dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return _primaryColor;
            }

            return Colors.transparent;
          })),
      textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
              foregroundColor: WidgetStateProperty.resolveWith((states) {
                return primaryDark;
              }),
              overlayColor: WidgetStatePropertyAll(_primaryColor))),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: onBackgroundSecondary,
        hourMinuteTextColor: _appNameColor,
        dialHandColor: _primaryColor,
        dialBackgroundColor: backgroundSecondary,
        entryModeIconColor: primaryDark,
        hourMinuteColor: _primaryColor,
        cancelButtonStyle: ButtonStyle(
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              return primaryDark;
            }),
            overlayColor: WidgetStatePropertyAll(_primaryColor)),
        confirmButtonStyle: ButtonStyle(
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              return primaryDark;
            }),
            overlayColor: WidgetStatePropertyAll(_primaryColor)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryDark;
          }
          return Colors.grey;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary;
          }
          return Colors.grey.shade400;
        }),
      ),
      appBarTheme: const AppBarTheme(
          color: Colors.white,
          titleTextStyle: TextStyle(
            color: _appNameColor,
            fontSize: 25,
          )),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return _primaryColorDisabled;
          }
          return _primaryColor;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return _appNameColorDisabled;
          }
          return _appNameColor;
        }),
        textStyle: WidgetStateProperty.resolveWith((states) {
          return const TextStyle(
              color: _appNameColor, fontWeight: FontWeight.bold, fontSize: 18);
        }),
        elevation: WidgetStateProperty.resolveWith((states) {
          return 0;
        }),
      )),
      outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
              foregroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.disabled)) {
                  return _appNameColorDisabled;
                }
                return _appNameColor;
              }),
              side: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.disabled)) {
                  return const BorderSide(
                      color: _appNameColorDisabled, width: 2);
                }

                return const BorderSide(color: _appNameColor, width: 2);
              }),
              overlayColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.disabled)) {
                  return backgroundSecondary;
                }

                return _primaryColor;
              }),
              textStyle: const WidgetStatePropertyAll(
                  TextStyle(fontWeight: FontWeight.bold, fontSize: 18)))),
      inputDecorationTheme: InputDecorationTheme(
          labelStyle: const TextStyle(color: _appNameColor),
          enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black, width: 1.0),
              borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: AppStyles._primaryColor,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.red,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.red,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(10),
          )),
      dropdownMenuTheme: DropdownMenuThemeData(menuStyle:
          MenuStyle(backgroundColor: WidgetStateProperty.resolveWith((states) {
        return Colors.white;
      }))));
}
