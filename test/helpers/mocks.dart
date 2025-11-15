import 'package:mocktail/mocktail.dart';
import 'package:variance_dart/variance_dart.dart';
import 'package:web3_signers/web3_signers.dart';
import 'package:web3dart/web3dart.dart' show ContractAbi;

class MockSmartWallet extends Mock implements SmartWallet {}

Address dummyAddress([
  String hex = '0x0000000000000000000000000000000000000000',
]) => Address.fromHex(hex);

ContractAbi dummyAbi() => ContractAbi.fromJson('[]', 'dummy');

void registerMocktailFallbacks() {
  // Required for non-nullable typed positional args in mocktail `any()`
  registerFallbackValue(dummyAddress());
  registerFallbackValue(dummyAbi());
  registerFallbackValue('method');
}

// Convenience helpers for stubbing common readContract responses
Future<List<dynamic>> resultBool(bool v) async => [v];
Future<List<dynamic>> resultArray(List<Address> list) async => [
  list,
  dummyAddress(),
];
