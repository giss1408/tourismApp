import 'package:explore_world/providers/payment_methods_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('loads seed mock payment methods with one default', () async {
    final provider = PaymentMethodsProvider();

    await Future<void>.delayed(Duration.zero);

    expect(provider.isLoaded, isTrue);
    expect(provider.methods.length, greaterThanOrEqualTo(2));
    expect(provider.methods.where((method) => method.isDefault), hasLength(1));
  });

  test('can add and remove mock payment methods', () async {
    final provider = PaymentMethodsProvider();

    await Future<void>.delayed(Duration.zero);
    final initialCount = provider.methods.length;

    await provider.addMockMethod();
    expect(provider.methods.length, initialCount + 1);

    final lastId = provider.methods.last.id;
    await provider.removeMethod(lastId);
    expect(provider.methods.length, initialCount);
  });

  test('setDefault keeps exactly one default method', () async {
    final provider = PaymentMethodsProvider();

    await Future<void>.delayed(Duration.zero);

    final targetId = provider.methods.last.id;
    await provider.setDefault(targetId);

    expect(provider.methods.where((method) => method.isDefault), hasLength(1));
    expect(provider.methods.last.isDefault, isTrue);
  });

  test('load falls back to seeded methods when cached payload is malformed', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'mock_payment_methods': '{not-valid-json',
    });

    final provider = PaymentMethodsProvider();
    await Future<void>.delayed(Duration.zero);

    expect(provider.isLoaded, isTrue);
    expect(provider.methods, isNotEmpty);
    expect(provider.methods.where((method) => method.isDefault), hasLength(1));
  });

  test('load ignores entries without ids in cached payload', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'mock_payment_methods':
          '[{"id":"","brand":"Visa","last4":"1111"},{"id":"pm_ok","brand":"Visa","last4":"4242","holderName":"A","expiryMonth":12,"expiryYear":2030,"isDefault":true}]',
    });

    final provider = PaymentMethodsProvider();
    await Future<void>.delayed(Duration.zero);

    expect(provider.methods.map((method) => method.id), contains('pm_ok'));
    expect(provider.methods.map((method) => method.id), isNot(contains('')));
  });

  test('removing default method promotes another method to default', () async {
    final provider = PaymentMethodsProvider();
    await Future<void>.delayed(Duration.zero);

    final defaultId = provider.methods.firstWhere((method) => method.isDefault).id;
    await provider.removeMethod(defaultId);

    expect(provider.methods, isNotEmpty);
    expect(provider.methods.where((method) => method.isDefault), hasLength(1));
  });
}
