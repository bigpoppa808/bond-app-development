import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:bond_app/core/theme/app_theme.dart';
import 'package:bond_app/core/routing/app_router.dart';
import 'package:bond_app/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:bond_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:bond_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bond_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:bond_app/features/profile/data/repositories/firebase_profile_repository.dart';
import 'package:bond_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:bond_app/features/profile/presentation/bloc/profile_bloc.dart';

/// The main application widget for the Bond app
class BondApp extends StatelessWidget {
  const BondApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (context) => FirebaseAuthRepository(
            firebaseAuth: FirebaseAuth.instance,
            firestore: FirebaseFirestore.instance,
            googleSignIn: GoogleSignIn(),
          ),
        ),
        RepositoryProvider<ProfileRepository>(
          create: (context) => FirebaseProfileRepository(
            firestore: FirebaseFirestore.instance,
            storage: FirebaseStorage.instance,
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) {
              final authBloc = AuthBloc(
                authRepository: context.read<AuthRepository>(),
                profileRepository: context.read<ProfileRepository>(),
              );
              authBloc.add(const AuthCheckRequested());
              return authBloc;
            },
          ),
          BlocProvider<ProfileBloc>(
            create: (context) => ProfileBloc(
              profileRepository: context.read<ProfileRepository>(),
            ),
          ),
        ],
        child: MaterialApp.router(
          title: 'Bond',
          debugShowCheckedModeBanner: false,
          theme: AppTheme().lightTheme,
          darkTheme: AppTheme().darkTheme,
          themeMode: ThemeMode.system,
          routerConfig: AppRouter(
            authBloc: context.read<AuthBloc>(),
          ).router,
        ),
      ),
    );
  }
}
