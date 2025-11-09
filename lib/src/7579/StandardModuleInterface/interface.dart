import 'dart:typed_data';

import 'package:eip7579/src/7579/utils.dart' show extractPrevAddress;
import 'package:variance_dart/variance_dart.dart';
import 'package:web3_signers/web3_signers.dart';
import 'package:web3dart/web3dart.dart';

part 'executors.dart';
part 'hooks.dart';
part 'validators.dart';

abstract interface class Base7579ModuleInterface {
  final SmartWallet _wallet;

  Base7579ModuleInterface(this._wallet);

  // returns an interface with only contract related functions
  SmartContract get contract => _wallet;

  // Module Name as defined in contract metadata
  String get name;

  // Module Version as defined in contract metadata
  String get version;

  // Module type
  ModuleType get type;

  // Module address
  Address get address;

  // Returns the module intialization data
  Uint8List get initData;

  // Checks if the module is initialized
  Future<bool> isInitialized() async {
    final result = await _wallet.readContract(
      address,
      Safe7579Abis.get('iModule'),
      'isInitialized',
      params: [_wallet.address],
      sender: _wallet.address,
    );
    return result.first;
  }

  // Checks if the expected module corresponds with the contract metadata
  Future<bool> isModuleType(ModuleType type) async {
    final result = await _wallet.readContract(
      address,
      Safe7579Abis.get('iModule'),
      'isModuleType',
      params: [BigInt.from(type.value)],
      sender: _wallet.address,
    );
    return result.first;
  }

  /// Returns the initialization data required for this module
  ///
  /// This data is used during module installation to properly configure
  /// the module for the smart wallet
  Uint8List getInitData();

  /// Returns the de-initialization data required for uninstalling this module.
  ///
  /// The optional [context] parameter allows passing additional data that may
  /// be needed during module de-initialization. If no context is provided,
  /// an empty Uint8List is returned.
  Future<Uint8List> getDeInitData([Uint8List? context]) {
    return Future.value(context ?? Uint8List(0));
  }
}
