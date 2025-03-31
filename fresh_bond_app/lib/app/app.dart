import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fresh_bond_app/app/router.dart';
import 'package:fresh_bond_app/app/theme.dart';
import 'package:fresh_bond_app/core/design/bond_design_system.dart';
import 'package:fresh_bond_app/features/auth/domain/blocs/auth_bloc.dart';
import 'package:go_router/go_router.dart';

/// Main application widget
class BondApp extends StatefulWidget {
  BondApp({Key? key}) : super(key: key);

  @override
  State<BondApp> createState() => _BondAppState();
}

class _BondAppState extends State<BondApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // Initialize design system
    BondDesignSystem.initialize();
    // Initialize router
    _router = AppRouter.createRouter();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Bond',
      debugShowCheckedModeBanner: false,
      theme: BondTheme.lightTheme,
      darkTheme: BondTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: _router,
      builder: (context, child) {
        // Apply system UI overlays based on current theme
        BondDesignSystem.updateSystemUI(context);
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
