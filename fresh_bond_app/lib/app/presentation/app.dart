import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fresh_bond_app/app/router.dart';
import 'package:fresh_bond_app/core/design/theme/bond_theme.dart';
import 'package:fresh_bond_app/features/auth/presentation/bloc/auth_bloc.dart';

/// The main app widget
class BondApp extends StatelessWidget {
  /// Constructor
  const BondApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Bond',
      debugShowCheckedModeBanner: false,
      theme: BondTheme.lightTheme,
      darkTheme: BondTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.createRouter(),
    );
  }
}
