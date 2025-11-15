part of '../../../../../eip7579.dart';

/// - [validatorId]: The unique identifier of the validator (bytes12).
typedef ValidatorId = Uint8List;

/// - [validatorAddress]: The address of the validator.
/// - [validatorId]: The unique identifier of the validator (bytes12).
/// - [data]: either subValidator config data or signature
/// - see: https://github.com/rhinestonewtf/core-modules/blob/main/src/MultiFactor/DataTypes.sol
typedef Validator =
    ({Address validatorAddress, ValidatorId validatorId, Uint8List data});

class MultiFactor extends ValidatorModuleInterface {
  static final _deployedModule = MultiFactorContract(getAddress());

  final BigInt _initThreshold;
  final List<Validator> _initValidators;

  MultiFactor(super.wallet, this._initThreshold, this._initValidators)
    : assert(
        _initThreshold > BigInt.zero,
        ModuleVariableError('MultiFactor', 'threshold'),
      ),
      assert(
        _initValidators.length >= _initThreshold.toInt(),
        ModuleVariableError('MultiFactor', 'validators'),
      ) {
    _initValidators.sort(
      (a, b) => a.validatorAddress.with0x.compareTo(b.validatorAddress.with0x),
    );
  }

  ///////////////////////////////////////////////////////////////
  //            GETTERS
  ///////////////////////////////////////////////////////////////
  @override
  Address get address => getAddress();

  @override
  Uint8List get initData => getInitData();

  @override
  String get name => "MultiFactor";

  @override
  ModuleType get type => ModuleType.validator;

  @override
  String get version => "1.0.0";

  ///////////////////////////////////////////////////////////////
  //            READS
  ///////////////////////////////////////////////////////////////
  @override
  Uint8List getInitData() {
    return intToBytes(
      _initThreshold,
    ).padToNBytes(1).concat(_initValidators.encoded);
  }

  Future<bool?> isSubValidator(
    Address subValidator,
    ValidatorId validatorId, [
    Address? account,
  ]) async {
    final result = await contract.readContract(
      address,
      multi_factor_abi,
      'isSubValidator',
      params: [account ?? contract.address, subValidator, validatorId],
    );
    return result.firstOrNull;
  }

  //////////////////////////////////////////////////////////////////
  //            WRITES
  ///////////////////////////////////////////////////////////////

  Future<UserOperationReceipt?> setThreshold(
    BigInt threshold, [
    SmartContract? sc,
  ]) async {
    final calldata = _deployedModule.contract
        .function('setThreshold')
        .encodeCall([threshold]);
    final tx = await (sc ?? contract).sendTransaction(
      address,
      calldata,
      nonceKey: validatorNonceKey,
    );
    final receipt = await tx.wait();
    return receipt;
  }

  Future<UserOperationReceipt?> setValidator(
    Address validatorAddress,
    ValidatorId validatorId,
    Uint8List newValidatorData, [
    SmartContract? sc,
  ]) async {
    final calldata = _deployedModule.contract
        .function('setValidator')
        .encodeCall([validatorAddress, validatorId, newValidatorData]);
    final tx = await (sc ?? contract).sendTransaction(
      address,
      calldata,
      nonceKey: validatorNonceKey,
    );
    final receipt = await tx.wait();
    return receipt;
  }

  Future<UserOperationReceipt?> removeValidator(
    Address validatorAddress,
    ValidatorId validatorId, [
    SmartContract? sc,
  ]) async {
    final calldata = _deployedModule.contract
        .function('removeValidator')
        .encodeCall([validatorAddress, validatorId]);
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
  static Uint8List getMFAMockSignature() {
    final List<Validator> mockValidators = [
      (
        validatorAddress: Address.fromHex(
          "0xf83d07238a7c8814a48535035602123ad6dbfa63",
        ),
        validatorId: Uint8List(12),
        data: hexToBytes(
          '0xe8b94748580ca0b4993c9a1b86b5be851bfc076ff5ce3a1ff65bf16392acfcb800f9b4f1aef1555c7fce5599fffb17e7c635502154a0333ba21f3ae491839af51c',
        ),
      ),
    ];
    return mockValidators.encoded;
  }

  static Address getAddress() {
    return Address.fromHex('0xf6bDf42c9BE18cEcA5C06c42A43DAf7FBbe7896b');
  }
}
