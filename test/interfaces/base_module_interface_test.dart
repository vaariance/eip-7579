import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:eip7579/eip7579.dart';
import 'package:variance_dart/variance_dart.dart';
import 'package:web3_signers/web3_signers.dart';
import '../helpers/mocks.dart';

// test ting as hooks because
// it implements thae base interface without any custom code
class TestModule extends HookModuleInterface {
  TestModule(super.wallet);

  @override
  String get name => 'TestModule';

  @override
  String get version => '0.0.1';

  @override
  ModuleType get type => ModuleType.hook;

  @override
  Address get address =>
      dummyAddress('0x0000000000000000000000000000000000000001');

  @override
  Uint8List get initData => Uint8List(0);

  @override
  Uint8List getInitData() => Uint8List(0);
}

void main() {
  late MockSmartWallet wallet;
  late TestModule module;

  setUp(() {
    registerMocktailFallbacks();
    wallet = MockSmartWallet();
    module = TestModule(wallet);

    // Default address for the wallet
    when(
      () => wallet.address,
    ).thenReturn(dummyAddress('0x00000000000000000000000000000000000000AA'));
  });

  test('isInitialized returns true when contract says initialized', () async {
    when(
      () => wallet.readContract(
        any(),
        any(),
        any(),
        params: any(named: 'params'),
        sender: any(named: 'sender'),
      ),
    ).thenAnswer((_) => resultBool(true));

    expect(await module.isInitialized(), isTrue);
  });

  test(
    'isInitialized returns false when contract says not initialized',
    () async {
      when(
        () => wallet.readContract(
          any(),
          any(),
          any(),
          params: any(named: 'params'),
          sender: any(named: 'sender'),
        ),
      ).thenAnswer((_) => resultBool(false));

      expect(await module.isInitialized(), isFalse);
    },
  );

  test('isModuleType matches given module type', () async {
    when(
      () => wallet.readContract(
        any(),
        any(),
        any(),
        params: any(named: 'params'),
        sender: any(named: 'sender'),
      ),
    ).thenAnswer((_) => resultBool(true));

    expect(await module.isModuleType(ModuleType.hook), isTrue);
  });

  test('isModuleType does not match other types', () async {
    when(
      () => wallet.readContract(
        any(),
        any(),
        any(),
        params: any(named: 'params'),
        sender: any(named: 'sender'),
      ),
    ).thenAnswer((_) => resultBool(false));

    expect(await module.isModuleType(ModuleType.executor), isFalse);
  });
}
