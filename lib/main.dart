import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/login.dart';
import 'screens/shell.dart';

void main() => runApp(const ManagerApp());

class ManagerApp extends StatefulWidget {
  const ManagerApp({super.key});
  @override
  State<ManagerApp> createState() => _ManagerAppState();
}

class _ManagerAppState extends State<ManagerApp> {
  bool _loggedIn = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TurfBuddie Manager',
      debugShowCheckedModeBanner: false,
      theme: TB.theme(),
      home: _loggedIn
          ? Shell(onLogout: () => setState(() => _loggedIn = false))
          : LoginScreen(onLoggedIn: () => setState(() => _loggedIn = true)),
    );
  }
}
