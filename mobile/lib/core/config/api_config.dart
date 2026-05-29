class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://api.wecircle.helpers-tech.com/api',
  );

  static String getBaseUrl() {
    if (baseUrl.isEmpty) {
      throw Exception('API_URL environment variable is not defined.');
    }
    return baseUrl;
  }
}

