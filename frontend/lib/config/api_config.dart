/// URL du backend FastAPI.
///
/// Surchargeable au lancement :
///   flutter run --dart-define=API_URL=http://10.0.2.2:8000
/// (10.0.2.2 = "localhost" de ta machine vu depuis l'émulateur Android.)
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8000',
  );

  static const String apiPrefix = '/api/v1';

  static Uri uri(String path) => Uri.parse('$baseUrl$apiPrefix$path');
}
