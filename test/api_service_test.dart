import 'package:flutter_test/flutter_test.dart';
import 'package:utammys_mobile_app/services/api_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  setUpAll(() async {
    // Mock the dotenv for testing
    dotenv.testLoad(fileInput: 'API_BASE_URL=https://test-api.example.com/api');
  });

  group('ApiService Tests', () {
    test('getBaseUrl should return URL from environment', () {
      final url = ApiService.getBaseUrl();
      expect(url, isNotEmpty);
      expect(url, contains('http'));
    });

    test('getBaseUrl should return default URL when not set', () {
      // Clear the environment
      dotenv.testLoad(fileInput: '');
      final url = ApiService.getBaseUrl();
      expect(url, equals('https://api.example.com/api'));
    });
  });
}
