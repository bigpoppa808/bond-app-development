import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fresh_bond_app/app/router.dart';
import 'package:fresh_bond_app/core/design/bond_design_system.dart';
import 'package:fresh_bond_app/features/auth/domain/blocs/auth_bloc.dart';

/// Main application widget
class BondApp extends StatefulWidget {
  BondApp({Key? key}) : super(key: key);

  @override
  State<BondApp> createState() => _BondAppState();
}

class _BondAppState extends State<BondApp> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    // Initialize design system
    BondDesignSystem.initialize();
    // Initialize router with auth bloc
    _appRouter = AppRouter(context.read<AuthBloc>());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Bond',
      debugShowCheckedModeBanner: false,
      theme: BondTheme.lightTheme,
      darkTheme: BondTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: _appRouter.router,
      builder: (context, child) {
        // Apply system UI overlays based on current theme
        BondDesignSystem.updateSystemUI(context);
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
