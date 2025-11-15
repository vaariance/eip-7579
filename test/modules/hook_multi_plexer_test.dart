import 'package:flutter_test/flutter_test.dart';
import 'package:eip7579/eip7579.dart';
import 'package:variance_dart/variance_dart.dart';
import 'package:web3_signers/web3_signers.dart';
import '../helpers/mocks.dart';

void main() {
  test('HookMultiPlexer getters sanity', () {
    final wallet = MockSmartWallet();
    final hook = HookMultiPlexer(
      wallet,
      [Address.fromHex('0x0000000000000000000000000000000000000011')],
      [],
      [],
      [],
      [],
    );
    expect(hook.name, 'HookMultiPlexer');
    expect(hook.type, ModuleType.hook);
    expect(hook.version, '1.0.0');
  });

  test('HookType enum covers expected variants', () {
    expect(HookType.values.length, 5);
    expect(HookType.global.index, 0);
  });
}
