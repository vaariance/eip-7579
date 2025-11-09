import 'dart:typed_data';

import 'package:variance_dart/variance_dart.dart' show Addresses;
import 'package:web3_signers/web3_signers.dart';
import 'package:web3dart/web3dart.dart';

BigInt dateTimeToInt(DateTime time) {
  return BigInt.from(time.millisecondsSinceEpoch);
}

Map<int, Address> swapRouterAddresses = {
  1: Address.fromHex('0xE592427A0AEce92De3Edee1F18E0157C05861564'),
  11155111: Address.fromHex('0xE592427A0AEce92De3Edee1F18E0157C05861564'),
  42161: Address.fromHex('0xE592427A0AEce92De3Edee1F18E0157C05861564'),
  421614: Address.fromHex('0xE592427A0AEce92De3Edee1F18E0157C05861564'),
  10: Address.fromHex('0xE592427A0AEce92De3Edee1F18E0157C05861564'),
  11155420: Address.fromHex('0xE592427A0AEce92De3Edee1F18E0157C05861564'),
  137: Address.fromHex('0xE592427A0AEce92De3Edee1F18E0157C05861564'),
  8453: Address.fromHex('0x2626664c2603336E57B271c5C0b26F421741e481'),
  84532: Address.fromHex('0x94cC0AaC535CCDB3C01d6787D6413C739ae12bc4'),
  56: Address.fromHex('0xB971eF87ede563556b2ED4b1C0b0019111Dd85d2'),
  43114: Address.fromHex('0xbb00FF08d01D300023C629E8fFfFcb65A5a578cE'),
};

Map<String, BigInt> defaultSwapDetails() {
  return <String, BigInt>{
    "sqrtPriceLimitX96": BigInt.zero,
    "amountOutMin": BigInt.zero,
    "fee": BigInt.zero,
  };
}

Address getSwapRouterAddress(int chainId) {
  final Address? swapRouter = swapRouterAddresses[chainId];
  if (swapRouter == null) {
    throw Exception('No swap router found for chainId $chainId');
  }
  return swapRouter;
}

Address extractPrevAddress(int addressIndex, List<Address> allAddresses) {
  Address prevAddress;
  if (addressIndex == -1) {
    throw Exception('Address not found');
  } else if (addressIndex == 0) {
    prevAddress = Addresses.sentinelAddress;
  } else {
    prevAddress = allAddresses[addressIndex - 1];
  }
  return prevAddress;
}

extension DoubleExt on double {
  BigInt toBigInt() => BigInt.from(this);
  Uint8List toBytes(int? bytes) {
    final value = intToBytes(toBigInt());
    return value.padToNBytes(bytes ?? value.length);
  }
}
