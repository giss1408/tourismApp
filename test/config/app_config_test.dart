import 'package:explore_world/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('GraphQL disabled allows empty endpoint', () {
    final config = AppConfig.fromValues(
      useGraphQlApi: false,
      graphQlEndpoint: '',
      graphQlAuthToken: '',
    );

    expect(() => config.validate(), returnsNormally);
  });

  test('GraphQL enabled with endpoint passes validation', () {
    final config = AppConfig.fromValues(
      useGraphQlApi: true,
      graphQlEndpoint: 'https://example.com/graphql',
      graphQlAuthToken: 'token',
    );

    expect(() => config.validate(), returnsNormally);
  });

  test('GraphQL enabled without endpoint fails validation', () {
    final config = AppConfig.fromValues(
      useGraphQlApi: true,
      graphQlEndpoint: '   ',
      graphQlAuthToken: '',
    );

    expect(() => config.validate(), throwsStateError);
  });
}
