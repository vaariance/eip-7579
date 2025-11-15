import 'package:flutter_test/flutter_test.dart';
import 'package:eip7579/eip7579.dart';
import 'package:variance_dart/variance_dart.dart';
import '../helpers/mocks.dart';

void main() {
  test('RegistryHook getters sanity', () {
    final wallet = MockSmartWallet();
    final hook = RegistryHook(wallet);
    expect(hook.name, 'RegistryHook');
    expect(hook.type, ModuleType.hook);
    expect(hook.version, '1.0.0');
  });
}
