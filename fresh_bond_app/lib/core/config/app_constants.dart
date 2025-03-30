/// Application-wide constants
class AppConstants {
  // General app constants
  static const String appName = 'Bond';
  static const String appVersion = '1.0.0';
  
  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';
  static const String refreshTokenKey = 'refresh_token';
  static const String onboardingCompletedKey = 'onboarding_completed';
  
  // API endpoints
  static const String loginEndpoint = '/v1/accounts:signInWithPassword';
  static const String signupEndpoint = '/v1/accounts:signUp';
  static const String refreshTokenEndpoint = '/v1/token';
  static const String userProfileEndpoint = '/v1/user/profile';
  static const String connectionsEndpoint = '/v1/connections';
  static const String notificationsEndpoint = '/v1/notifications';
  
  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int tokenExpiryBuffer = 300000; // 5 minutes in milliseconds
  
  // Error messages
  static const String genericErrorMessage = 'Something went wrong. Please try again.';
  static const String networkErrorMessage = 'Network error. Please check your connection.';
  static const String authErrorMessage = 'Authentication failed. Please log in again.';
  
  // Animation durations
  static const int shortAnimationDuration = 200; // milliseconds
  static const int mediumAnimationDuration = 500; // milliseconds
  static const int longAnimationDuration = 800; // milliseconds
  
  // Limits
  static const int maxSearchResults = 50;
  static const int maxNotifications = 100;
  static const int maxRetries = 3;
  
  // Feature constants
  static const int maxConnections = 500;
  static const int maxPendingRequests = 50;
}
