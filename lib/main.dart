import 'package:flutter/material.dart';
import './screens/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cricket Scorer',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        focusColor: Colors.black,
        highlightColor: Colors.grey[50],
        splashColor: Colors.grey[50],
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.black,
          selectionColor: Colors.grey,
          selectionHandleColor: Colors.black,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 2),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black12, width: 1),
          ),
        ),
        dropdownMenuTheme: const DropdownMenuThemeData(
          inputDecorationTheme: InputDecorationTheme(
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 2),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black12, width: 1),
            ),
          ),
          menuStyle: MenuStyle(
            backgroundColor: WidgetStatePropertyAll(Colors.white),
            surfaceTintColor: WidgetStatePropertyAll(Colors.white),
            shadowColor: WidgetStatePropertyAll(Colors.black12),
            elevation: WidgetStatePropertyAll(2),
          ),
          textStyle: TextStyle(color: Colors.black),
        ),
      ),
      home: HomeScreen(),
    );
  }
}
