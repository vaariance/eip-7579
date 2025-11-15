// NOTE: THIS IS A TEMPLATE FILE FOR TESTING MODULES
// COPY AND MODIFY THE FILE TO TEST YOUR MODULE
// REPLACE `YourModule` WITH THE MODULE CLASS YOU ARE TESTING

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../helpers/mocks.dart';

// Copy this file to a target folder (modules/hooks/validators)
// and rename tests accordingly. Replace `YourModule` with the module class.

void main() {
  late MockSmartWallet wallet;

  setUp(() {
    registerMocktailFallbacks();
    wallet = MockSmartWallet();
    when(
      () => wallet.address,
    ).thenReturn(dummyAddress('0x00000000000000000000000000000000000000EE'));
  });

  test('YourModule getters sanity', () {
    // final module = YourModule(wallet, ...args);
    // expect(module.name, 'YourModule');
    // expect(module.type, ModuleType.validator);
    // expect(module.version, '1.0.0');
  });

  test('Read path: mocks and expectations', () async {
    when(
      () => wallet.readContract(
        any(), // module.address
        any(), // abi
        any(), // function name
        params: any(named: 'params'),
        sender: any(named: 'sender'),
      ),
    ).thenAnswer((_) async => [true]);

    // final module = YourModule(wallet, ...args);
    // final ok = await module.someReadMethod(...);
    // expect(ok, isTrue);
  });

  test('Write path: proxied user op or contract call', () async {
    // For ValidatorModuleInterface proxyTransaction, you may stub expected outcomes
    // when(() => wallet.writeContract(...)).thenAnswer((_) async => ...);

    // final receipt = await module.proxyTransaction([...], [...]);
    // expect(receipt, isA<UserOperationResponse>());
  });

  test('Error path: assertions / invalid inputs', () {
    // expect(() => YourModule(wallet, invalidArgs), throwsA(isA<AssertionError>()));
  });
}
