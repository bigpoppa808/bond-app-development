# Bond App: Implementation Starter Guide

This document provides sample implementations for key components to help you get started with the Bond App development using the recommended approach.

## Directory Structure Setup

```bash
mkdir -p lib/app lib/core/{config,di,network,theme,utils} lib/features/{auth,profile,discovery,connections,meetings}/{data,domain,presentation} lib/shared/{widgets,models,constants}
touch lib/main.dart lib/app/{app.dart,router.dart,theme.dart}
```

## First Components Implementation

### 1. Theme Configuration (`lib/app/theme.dart`)

```dart
import 'package:flutter/material.dart';

class BondAppTheme {
  static const Color primaryColor = Color(0xFF3B82F6);
  static const Color secondaryColor = Color(0xFF10B981);
  static const Color accentColor = Color(0xFF8B5CF6);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color successColor = Color(0xFF10B981);
  
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF4B5563);
  static const Color textTertiary = Color(0xFF9CA3AF);
  
  static const Color backgroundPrimary = Color(0xFFF9FAFB);
  static const Color backgroundSecondary = Color(0xFFFFFFFF);
  static const Color backgroundTertiary = Color(0xFFF3F4F6);

  static ThemeData lightTheme() {
    return ThemeData(
      primaryColor: primaryColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
      ),
      scaffoldBackgroundColor: backgroundPrimary,
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textPrimary, height: 1.2),
        displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textPrimary, height: 1.2),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textPrimary, height: 1.3),
        titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textPrimary, height: 1.3),
        bodyLarge: TextStyle(fontSize: 16, color: textPrimary, height: 1.5),
        bodyMedium: TextStyle(fontSize: 14, color: textPrimary, height: 1.5),
        labelSmall: TextStyle(fontSize: 12, color: textSecondary, height: 1.4),
      ),
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        buttonColor: primaryColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      cardTheme: CardTheme(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
    );
  }

  static ThemeData darkTheme() {
    // Implement dark theme based on the light theme with appropriate color adjustments
    return lightTheme().copyWith(
      // Dark theme configuration
    );
  }
}
```

### 2. Router Configuration (`lib/app/router.dart`)

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Import your screen files here when they're created
// import '../features/auth/presentation/screens/login_screen.dart';
// import '../features/auth/presentation/screens/signup_screen.dart';
// import '../features/home/presentation/screens/home_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter get router => _router;
  
  static final _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // Initial route - could be splash screen or auth check
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Bond App Placeholder')),
        ),
      ),
      
      // Auth routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Login Screen Placeholder')),
        ),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Signup Screen Placeholder')),
        ),
      ),

      // Main app shell with bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return Scaffold(
            body: child,
            bottomNavigationBar: BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Discover'),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
              ],
              currentIndex: _calculateSelectedIndex(state),
              onTap: (index) => _onItemTapped(index, context),
            ),
          );
        },
        routes: [
          // Home tab
          GoRoute(
            path: '/home',
            builder: (context, state) => const Center(child: Text('Home Screen')),
          ),
          // Discover tab
          GoRoute(
            path: '/discover',
            builder: (context, state) => const Center(child: Text('Discover Screen')),
          ),
          // Profile tab
          GoRoute(
            path: '/profile',
            builder: (context, state) => const Center(child: Text('Profile Screen')),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      // Add authentication logic here when implemented
      // final isLoggedIn = AuthService.isLoggedIn();
      // if (!isLoggedIn && !state.location.startsWith('/login') && !state.location.startsWith('/signup')) {
      //   return '/login';
      // }
      return null;
    },
  );

  static int _calculateSelectedIndex(GoRouterState state) {
    final location = state.location;
    if (location.startsWith('/home')) {
      return 0;
    }
    if (location.startsWith('/discover')) {
      return 1;
    }
    if (location.startsWith('/profile')) {
      return 2;
    }
    return 0;
  }

  static void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/home');
        break;
      case 1:
        GoRouter.of(context).go('/discover');
        break;
      case 2:
        GoRouter.of(context).go('/profile');
        break;
    }
  }
}
```

### 3. App Configuration (`lib/app/app.dart`)

```dart
import 'package:flutter/material.dart';
import 'router.dart';
import 'theme.dart';

class BondApp extends StatelessWidget {
  const BondApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Bond App',
      theme: BondAppTheme.lightTheme(),
      darkTheme: BondAppTheme.darkTheme(),
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
```

### 4. Main Entry Point (`lib/main.dart`)

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/app.dart';
import 'core/di/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize dependency injection
  await initServiceLocator();
  
  runApp(const BondApp());
}
```

### 5. Service Locator Setup (`lib/core/di/service_locator.dart`)

```dart
import 'package:get_it/get_it.dart';

final GetIt serviceLocator = GetIt.instance;

Future<void> initServiceLocator() async {
  // Register services
  // Example: serviceLocator.registerSingleton<AuthService>(AuthServiceImpl());
  
  // Register repositories
  // Example: serviceLocator.registerSingleton<AuthRepository>(AuthRepositoryImpl());
  
  // Register BLoCs
  // Example: serviceLocator.registerFactory<AuthBloc>(() => AuthBloc(serviceLocator()));
}
```

### 6. Firebase API Service (`lib/core/network/firebase_api_service.dart`)

```dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class FirebaseApiService {
  final Dio _dio;
  final String _baseUrl;
  final String _apiKey;

  FirebaseApiService({
    required String baseUrl,
    required String apiKey,
    Dio? dio,
  })  : _baseUrl = baseUrl,
        _apiKey = apiKey,
        _dio = dio ?? Dio() {
    _dio.options.headers['Content-Type'] = 'application/json';
    
    // Add logging interceptor in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    }
  }

  // Authentication API endpoints
  Future<Map<String, dynamic>> signUp(String email, String password) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/v1/accounts:signUp?key=$_apiKey',
        data: {
          'email': email,
          'password': password,
          'returnSecureToken': true,
        },
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/v1/accounts:signInWithPassword?key=$_apiKey',
        data: {
          'email': email,
          'password': password,
          'returnSecureToken': true,
        },
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Helper method to standardize error handling
  Exception _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response?.data != null) {
        final errorData = error.response!.data;
        if (errorData['error'] != null) {
          final message = errorData['error']['message'];
          if (message == 'EMAIL_EXISTS') {
            return Exception('The email address is already in use');
          } else if (message == 'INVALID_LOGIN_CREDENTIALS') {
            return Exception('Invalid email or password');
          } else {
            return Exception(message ?? 'An unknown error occurred');
          }
        }
      }
      return Exception('Network error: ${error.message}');
    }
    return Exception('Unexpected error occurred');
  }
}
```

### 7. Common Button Widget (`lib/shared/widgets/bond_button.dart`)

```dart
import 'package:flutter/material.dart';

enum BondButtonType { primary, secondary, text }

class BondButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final BondButtonType type;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;

  const BondButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = BondButtonType.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    switch (type) {
      case BondButtonType.primary:
        return SizedBox(
          width: width,
          height: height,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _buildButtonContent(theme),
          ),
        );
        
      case BondButtonType.secondary:
        return SizedBox(
          width: width,
          height: height,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.primaryColor,
              side: BorderSide(color: theme.primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _buildButtonContent(theme),
          ),
        );
        
      case BondButtonType.text:
        return SizedBox(
          width: width,
          height: height,
          child: TextButton(
            onPressed: isLoading ? null : onPressed,
            style: TextButton.styleFrom(
              foregroundColor: theme.primaryColor,
            ),
            child: _buildButtonContent(theme),
          ),
        );
    }
  }

  Widget _buildButtonContent(ThemeData theme) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            type == BondButtonType.primary ? Colors.white : theme.primaryColor,
          ),
        ),
      );
    }
    
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    }
    
    return Text(text);
  }
}
```

## Getting Started with Auth Implementation

### 1. Auth Repository Interface (`lib/features/auth/domain/repositories/auth_repository.dart`)

```dart
abstract class AuthRepository {
  Future<void> signUpWithEmail(String email, String password);
  Future<void> signInWithEmail(String email, String password);
  Future<void> signOut();
  Future<bool> isUserLoggedIn();
  Stream<bool> authStateChanges();
}
```

### 2. Auth Repository Implementation (`lib/features/auth/data/repositories/auth_repository_impl.dart`)

```dart
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/network/firebase_api_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseApiService _apiService;
  final SharedPreferences _prefs;
  final StreamController<bool> _authStateController = StreamController<bool>.broadcast();

  static const String _authTokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _expiryTimeKey = 'token_expiry';

  AuthRepositoryImpl(this._apiService, this._prefs) {
    // Check authentication state on initialization
    isUserLoggedIn().then((isLoggedIn) {
      _authStateController.add(isLoggedIn);
    });
  }

  @override
  Future<void> signUpWithEmail(String email, String password) async {
    final response = await _apiService.signUp(email, password);
    _saveAuthData(response);
    _authStateController.add(true);
  }

  @override
  Future<void> signInWithEmail(String email, String password) async {
    final response = await _apiService.signIn(email, password);
    _saveAuthData(response);
    _authStateController.add(true);
  }

  @override
  Future<void> signOut() async {
    await _prefs.remove(_authTokenKey);
    await _prefs.remove(_userIdKey);
    await _prefs.remove(_expiryTimeKey);
    _authStateController.add(false);
  }

  @override
  Future<bool> isUserLoggedIn() async {
    final token = _prefs.getString(_authTokenKey);
    if (token == null) return false;
    
    final expiryTimeStr = _prefs.getString(_expiryTimeKey);
    if (expiryTimeStr == null) return false;
    
    final expiryTime = DateTime.parse(expiryTimeStr);
    if (DateTime.now().isAfter(expiryTime)) {
      // Token expired
      await signOut();
      return false;
    }
    
    return true;
  }

  @override
  Stream<bool> authStateChanges() {
    return _authStateController.stream;
  }

  void _saveAuthData(Map<String, dynamic> authData) {
    final token = authData['idToken'];
    final userId = authData['localId'];
    final expiresIn = int.parse(authData['expiresIn']);
    
    final expiryTime = DateTime.now().add(Duration(seconds: expiresIn));
    
    _prefs.setString(_authTokenKey, token);
    _prefs.setString(_userIdKey, userId);
    _prefs.setString(_expiryTimeKey, expiryTime.toIso8601String());
  }

  void dispose() {
    _authStateController.close();
  }
}
```

### 3. Auth BLoC Implementation (Starter Code)

**Auth Events** (`lib/features/auth/presentation/bloc/auth_event.dart`):
```dart
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {}

class SignUpEvent extends AuthEvent {
  final String email;
  final String password;

  const SignUpEvent({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class SignInEvent extends AuthEvent {
  final String email;
  final String password;

  const SignInEvent({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class SignOutEvent extends AuthEvent {}
```

**Auth States** (`lib/features/auth/presentation/bloc/auth_state.dart`):
```dart
import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object> get props => [];
}

class AuthInitialState extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthenticatedState extends AuthState {
  final String userId;

  const AuthenticatedState(this.userId);

  @override
  List<Object> get props => [userId];
}

class UnauthenticatedState extends AuthState {}

class AuthErrorState extends AuthState {
  final String message;

  const AuthErrorState(this.message);

  @override
  List<Object> get props => [message];
}
```

**Auth BLoC** (`lib/features/auth/presentation/bloc/auth_bloc.dart`):
```dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  late StreamSubscription<bool> _authStateSubscription;

  AuthBloc(this._authRepository) : super(AuthInitialState()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<SignUpEvent>(_onSignUp);
    on<SignInEvent>(_onSignIn);
    on<SignOutEvent>(_onSignOut);

    // Listen to auth state changes
    _authStateSubscription = _authRepository.authStateChanges().listen((isAuthenticated) {
      if (isAuthenticated) {
        // In a real implementation, you would get the actual userId
        add(const AuthenticatedState('userId'));
      } else {
        add(UnauthenticatedState());
      }
    });
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    try {
      final isLoggedIn = await _authRepository.isUserLoggedIn();
      if (isLoggedIn) {
        // In a real implementation, you would get the actual userId
        emit(const AuthenticatedState('userId'));
      } else {
        emit(UnauthenticatedState());
      }
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }

  Future<void> _onSignUp(
    SignUpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    try {
      await _authRepository.signUpWithEmail(event.email, event.password);
      // The state will be updated via the subscription to authStateChanges
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }

  Future<void> _onSignIn(
    SignInEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    try {
      await _authRepository.signInWithEmail(event.email, event.password);
      // The state will be updated via the subscription to authStateChanges
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }

  Future<void> _onSignOut(
    SignOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    try {
      await _authRepository.signOut();
      // The state will be updated via the subscription to authStateChanges
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription.cancel();
    return super.close();
  }
}
```

## Next Steps for Implementation

1. **Complete Auth Screens**:
   - Create a login screen UI
   - Create a signup screen UI
   - Integrate with BLoC for state management

2. **Core Navigation**:
   - Implement auth state-based navigation
   - Build out the main app screens structure

3. **Profile Features**:
   - Create profile models and repositories
   - Design profile UI and editing screens

4. **Testing**:
   - Write unit tests for repositories and BLoCs
   - Create widget tests for key components

Follow the incremental approach described in the transition guide, adding dependencies one by one and testing the iOS build after each major addition.