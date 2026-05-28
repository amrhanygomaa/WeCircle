class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://44.201.109.24:5001/api',
  );

  static String getBaseUrl() {
    if (baseUrl.isEmpty) {
      throw Exception('API_URL environment variable is not defined.');
    }
    return baseUrl;
  }
}
