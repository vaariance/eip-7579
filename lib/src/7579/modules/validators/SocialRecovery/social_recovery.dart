part of '../../../../../eip7579.dart';

typedef RecoveryData = Uint8List;

enum RecoveryMechanism { setThreshold, addOwner }

class SocialRecovery extends ValidatorModuleInterface {
  static final _deployedModule = SocialRecoveryContract(getAddress());

  final BigInt _initThreshold;

  final List<Address> _initGuardians;

  SocialRecovery(super._wallet, this._initThreshold, this._initGuardians)
    : assert(
        _initThreshold > BigInt.zero,
        ModuleVariableError('SocialRecoveryValidator', 'threshold'),
      ),
      assert(
        _initGuardians.length >= _initThreshold.toInt(),
        ModuleVariableError('SocialRecoveryValidator', 'guardians'),
      ) {
    _initGuardians.sort((a, b) => a.with0x.compareTo(b.with0x));
  }

  ///////////////////////////////////////////////////////////////
  //            GETTERS
  ///////////////////////////////////////////////////////////////
  @override
  Address get address => getAddress();

  @override
  Uint8List get initData => getInitData();

  @override
  String get name => "SocialRecoveryValidator";

  @override
  ModuleType get type => ModuleType.validator;

  @override
  String get version => "1.0.0";

  ///////////////////////////////////////////////////////////////
  //            READS
  ///////////////////////////////////////////////////////////////
  @override
  Uint8List getInitData() {
    return abi.encode(
      ["uint256", "address[]"],
      [_initThreshold, _initGuardians],
    );
  }

  Future<List<Address>?> getGuardians([Address? account]) async {
    final result = await contract.readContract(
      address,
      social_recovery_abi,
      'getGuardians',
      params: [account ?? contract.address],
    );
    return result.firstOrNull;
  }

  Future<BigInt?> guardianCount([Address? account]) async {
    final result = await contract.readContract(
      address,
      social_recovery_abi,
      'guardianCount',
      params: [account ?? contract.address],
    );
    return result.firstOrNull;
  }

  Future<BigInt?> threshold([Address? account]) async {
    final result = await contract.readContract(
      address,
      social_recovery_abi,
      'threshold',
      params: [account ?? contract.address],
    );
    return result.firstOrNull;
  }

  //////////////////////////////////////////////////////////////////
  //            WRITES
  ///////////////////////////////////////////////////////////////
  Future<UserOperationReceipt?> addGuardian(
    Address guardian, [
    SmartContract? sc,
  ]) async {
    final calldata = _deployedModule.contract
        .function('addGuardian')
        .encodeCall([guardian]);
    final tx = await (sc ?? contract).sendTransaction(
      address,
      calldata,
      nonceKey: validatorNonceKey,
    );
    final receipt = await tx.wait();
    return receipt;
  }

  Future<UserOperationReceipt?> removeGuardian(
    Address guardian, [
    SmartContract? sc,
  ]) async {
    final guardians = await getGuardians() ?? [];
    final currentGuardianIndex = guardians.indexOf(guardian);

    Address prevGuardian;
    if (currentGuardianIndex == -1) {
      throw Exception('Guardian not found');
    } else if (currentGuardianIndex == 0) {
      prevGuardian = SENTINEL_ADDRESS;
    } else {
      prevGuardian = guardians[currentGuardianIndex - 1];
    }
    final calldata = _deployedModule.contract
        .function('removeGuardian')
        .encodeCall([prevGuardian, guardian]);
    final tx = await (sc ?? contract).sendTransaction(
      address,
      calldata,
      nonceKey: validatorNonceKey,
    );
    final receipt = await tx.wait();
    return receipt;
  }

  Future<UserOperationReceipt?> setThreshold(
    int threshold, [
    SmartContract? sc,
  ]) async {
    final calldata = _deployedModule.contract
        .function('setThreshold')
        .encodeCall([BigInt.from(threshold)]);
    final tx = await (sc ?? contract).sendTransaction(
      address,
      calldata,
      nonceKey: validatorNonceKey,
    );
    final receipt = await tx.wait();
    return receipt;
  }

  @override
  Future<UserOperationResponse> proxyTransaction(
    List<Address> recipients,
    List<Uint8List> calls, {
    List<BigInt>? amountsInWei,
  }) {
    return contract.sendBatchedTransaction(
      recipients,
      calls,
      amountsInWei: amountsInWei,
      nonceKey: validatorNonceKey,
    );
  }

  //////////////////////////////////////////////////////////////////
  //            STATIC METHODS
  ///////////////////////////////////////////////////////////////
  static Address getAddress() {
    return Address.fromHex('0xA04D053b3C8021e8D5bF641816c42dAA75D8b597');
  }

  static Uint8List getMockSignature(int threshold) {
    return OwnableValidator.getMockSignature(threshold);
  }

  //////////////////////////////////////////////////////////////////
  //            RECOVERY
  ///////////////////////////////////////////////////////////////
  ///

  /// {@template getOp}
  /// Creates a user operation for social recovery actions
  ///
  /// The [threshold] value for social recovery.
  /// - This value determines the minimum number of guardians required for a recovery action.
  /// Takes a list of recovery actions to perform, where each action is a tuple of:
  /// - [RecoveryMechanism]: The type of recovery action (setThreshold or addOwner)
  /// - [RecoveryData]: The data needed for that action (threshold value or owner address)
  ///
  /// The method will:
  /// 1. Validate the recovery list is not empty
  /// 2. Generate calldata for each recovery action
  /// 3. Batch the calls together into a single user operation
  /// 4. Add a mock signature, gas estimation and sponsorship
  ///
  /// Example Usage flow:
  /// - Affected user calls this function with the recovery actions they want to perform.
  /// - Sends the returned `UserOperation` to user's guardians
  /// - Guardians sign the user operation using `generateOffchainSignature`
  /// - Affected user calls `executeRecovery` with the signed user operation and signatures
  ///
  /// @param recovery List of recovery actions to perform
  /// @return [Future<UserOperation>] The prepared user operation ready for guardian signatures
  /// {@endtemplate}
  static Future<UserOperation> getRecoveryOperation(
    SmartWallet wallet,
    int threshold,
    List<(RecoveryMechanism, RecoveryData)> recovery,
  ) async {
    require(threshold != 0, 'Threshold must be set');
    require(recovery.isNotEmpty, 'Recovery list is empty');
    getCalls() {
      final calls = List.filled(recovery.length, Uint8List(0));
      for (var i in recovery) {
        calls[recovery.indexOf(i)] = switch (i.$1) {
          RecoveryMechanism.setThreshold => OwnableValidator
              ._deployedModule
              .contract
              .function('setThreshold')
              .encodeCall([bytesToInt(i.$2)]),
          RecoveryMechanism.addOwner => OwnableValidator
              ._deployedModule
              .contract
              .function('addOwner')
              .encodeCall([Address(i.$2)]),
        };
      }
    }

    final calldata = await wallet.get7579ExecuteBatchCalldata(
      recipients: List.filled(recovery.length, OwnableValidator.getAddress()),
      innerCalls: getCalls(),
    );

    return wallet
        .prepareUserOperation(
          wallet.buildUserOperation(callData: calldata),
          nonceKey: Uint256.fromList(
            getAddress().value.padToNBytes(24, direction: "right"),
          ),
        )
        .then(wallet.overrideGas)
        .then(wallet.sponsorUserOperation);
  }

  /// {@template genSig}
  /// Generates signatures for a UserOperation without broadcasting it onchain.
  ///
  /// This function creates the necessary signatures for a UserOperation to be valid,
  /// but does not submit the operation to the blockchain. Useful for
  /// preparing operations for later use.
  ///
  /// Returns a tuple containing:
  /// - [List<Uint8List>?]: Optional accompanying data
  /// - [List<dynamic>]: The Actual signatures in expected types
  /// {@endtemplate}
  static Future<(List<Uint8List>?, List<Uint8List>)> generateOffchainSignature(
    SmartWallet wallet,
    UserOperation op, [
    BlockInfo? blockInfo,
  ]) async {
    final hash = op.hash(wallet.chain);
    // ignore: invalid_use_of_protected_member
    final sig = await wallet.state.signer.personalSign(hash);
    return (null, [sig]);
  }

  /// {@template execRecovery}
  /// Executes a social recovery operation using the provided signed user operation and guardian signatures
  ///
  /// This method:
  /// 1. Verifies that the OwnableValidator module is installed
  /// 2. Combines the guardian signatures into a single validator signature
  /// 3. Sends the signed user operation for execution
  ///
  /// @param signedOp The user operation to execute, must contain recovery calldata
  /// @param signatures List of guardian signatures authorizing the recovery
  /// @return [Future<UserOperationResponse>] containing the transaction response
  /// {@endtemplate}
  static Future<UserOperationResponse> executeRecovery(
    SmartWallet wallet,
    UserOperation signedOp,
    List<Uint8List> signatures,
  ) async {
    final isOwnableValidatorInstalled = await wallet.isModuleInstalled(
      ModuleType.validator,
      OwnableValidator.getAddress(),
    );
    require(
      isOwnableValidatorInstalled ?? false,
      "OwnableValidator is not installed: it is required for SocialRecovery",
    );
    signedOp.signature = hexlify(
      OwnableValidator.getOwnableValidatorSignature(signatures),
    );
    return wallet.sendSignedUserOperation(signedOp);
  }
}
