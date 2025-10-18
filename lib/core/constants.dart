/// Constants and environment entry points. Keep secrets out of code; use
/// dart-define.
/// dart-define keys: SUPABASE_URL, SUPABASE_ANON_KEY, SUPABASE_REDIRECT_URL
library;

// Provide safe defaults so development builds work without dart-define.
// For production, pass real values via --dart-define to override these.
const kSupabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://ivhmiyzncnndkvqrmqpa.supabase.co',
);
const kSupabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.'
      'eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml2aG1peXpuY25uZGt2cXJtcXBh'
      'Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA2MzM2MzksImV4cCI6MjA3NjIwOTYzOX0.'
      '8rpOMNSaLSjhpJ_4Z_y78FplA_6i1PiEp1DgcVNIjGE',
);

/// OAuth redirect URL registered on Supabase + platforms (Android/iOS).
/// This must match the Android intent-filter and iOS URL scheme.
const kSupabaseRedirectUrl = String.fromEnvironment(
  'SUPABASE_REDIRECT_URL',
  defaultValue: 'com.example.gelir_gider://login-callback',
);

/// App configuration
const kAppName = 'Gelir Gider';

/// Feature flags (configure remotely in production if needed).
class FeatureFlags {
  static const voiceInput = true;
  static const forecasting = true; // Local simple forecasting enabled
  static const pythonForecastApi = false; // Toggle external FastAPI usage
  static const homeWidget = true;
  static const premiumFeatures = true;
}
