import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:eip7579/eip7579.dart';
import 'package:variance_dart/variance_dart.dart';
import 'package:web3_signers/web3_signers.dart';
import '../helpers/mocks.dart';

class DummyValidatorModule extends ValidatorModuleInterface {
  DummyValidatorModule(super.wallet);

  @override
  Address get address =>
      dummyAddress('0x0000000000000000000000000000000000000002');

  @override
  Uint8List get initData => getInitData();

  @override
  String get name => 'DummyValidator';

  @override
  ModuleType get type => ModuleType.validator;

  @override
  String get version => '0.0.1';

  @override
  Uint8List getInitData() => Uint8List.fromList([1, 2, 3]);

  @override
  Future<UserOperationResponse> proxyTransaction(
    List<Address> recipients,
    List<Uint8List> calls, {
    List<BigInt>? amountsInWei,
  }) {
    throw UnimplementedError('Dummy test module does not proxy transactions');
  }
}

void main() {
  late MockSmartWallet wallet;
  late DummyValidatorModule module;

  setUp(() {
    registerMocktailFallbacks();
    wallet = MockSmartWallet();
    module = DummyValidatorModule(wallet);
    when(
      () => wallet.address,
    ).thenReturn(dummyAddress('0x00000000000000000000000000000000000000BB'));
  });

  test('getInstalledValidators returns modules list', () async {
    final installed = [
      dummyAddress('0x00000000000000000000000000000000000000C1'),
      dummyAddress('0x00000000000000000000000000000000000000C2'),
    ];

    when(
      () => wallet.readContract(
        any(),
        any(),
        any(),
        params: any(named: 'params'),
        sender: any(named: 'sender'),
      ),
    ).thenAnswer((_) => resultArray(installed));

    final validators = await module.getInstalledValidators();
    expect(validators, installed);
  });

  test('getDeInitData returns encoded payload (non-empty bytes)', () async {
    final installed = [
      dummyAddress('0x00000000000000000000000000000000000000C1'),
      module.address, // ensure module exists in list
      dummyAddress('0x00000000000000000000000000000000000000C3'),
    ];

    when(
      () => wallet.readContract(
        any(),
        any(),
        any(),
        params: any(named: 'params'),
        sender: any(named: 'sender'),
      ),
    ).thenAnswer((_) => resultArray(installed));

    final payload = await module.getDeInitData();
    expect(payload, isA<Uint8List>());
    expect(payload.isNotEmpty, isTrue);
  });
}
