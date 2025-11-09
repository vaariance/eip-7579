part of '../../../../../eip7579.dart';

typedef AutoSaveConfig = ({Percent percentage, Address vault});
typedef AutoSaveConfigWithToken = ({Address token, AutoSaveConfig inner});

class AutoSavings extends ExecutorModuleInterface {
  static final _deployedModule = AutoSavingsContract(getAddress());

  final List<AutoSaveConfigWithToken> _config;

  AutoSavings(super.wallet, this._config);

  ///////////////////////////////////////////////////////////////
  //            GETTERS
  ///////////////////////////////////////////////////////////////
  @override
  Address get address => getAddress();

  @override
  Uint8List get initData => getInitData();

  @override
  String get name => 'AutoSavings';

  @override
  ModuleType get type => ModuleType.executor;

  @override
  String get version => '1.0.0';

  ///////////////////////////////////////////////////////////////
  //            READS
  ///////////////////////////////////////////////////////////////

  @override
  Uint8List getInitData() {
    return abi.encode(
      ["address", "(address,uint64,address)[]"],
      [
        getSwapRouterAddress((contract as SmartWallet).chain.chainId),
        [
          ..._config.map(
            (e) => [e.token, e.inner.percentage.toBytes(8), e.inner.vault],
          ),
        ],
      ],
    );
  }

  Future<List<Address>> getTokens([Address? account]) async {
    final result = await contract.readContract(
      address,
      auto_savings_abi,
      'getTokens',
      params: [account ?? contract.address],
    );
    return result.firstOrNull;
  }

  Future<dynamic> config(Address token, [Address? account]) async {
    final result = await contract.readContract(
      address,
      auto_savings_abi,
      'config',
      params: [account ?? contract.address, token],
    );
    return result.firstOrNull;
  }

  //////////////////////////////////////////////////////////////////
  //            WRITES
  ///////////////////////////////////////////////////////////////

  Future<UserOperationReceipt?> setConfig(
    Address token,
    AutoSaveConfig config,
  ) async {
    final calldata = _deployedModule.contract.function('setConfig').encodeCall([
      token,
      [config.percentage.toBytes(8), config.vault],
    ]);
    final tx = await contract.sendTransaction(address, calldata);
    final receipt = await tx.wait();
    return receipt;
  }

  Future<UserOperationReceipt?> deleteConfig(Address token) async {
    final allTokens = await getTokens();
    final currentTokenIndex = allTokens.indexOf(token);

    final calldata = _deployedModule.contract
        .function('deleteConfig')
        .encodeCall([extractPrevAddress(currentTokenIndex, allTokens), token]);
    final tx = await contract.sendTransaction(address, calldata);
    final receipt = await tx.wait();
    return receipt;
  }

  Future<UserOperationReceipt?> autoSave(
    Address token,
    BigInt amountReceived,
  ) async {
    final swapDetails = defaultSwapDetails();
    final calldata = _deployedModule.contract.function('autoSave').encodeCall([
      token,
      amountReceived,
      swapDetails["sqrtPriceLimitX96"],
      swapDetails["amountOutMin"],
      swapDetails["fee"],
    ]);
    final tx = await contract.sendTransaction(address, calldata);
    final receipt = await tx.wait();
    return receipt;
  }

  //////////////////////////////////////////////////////////////////
  //            STATIC METHODS
  ///////////////////////////////////////////////////////////////
  static Address getAddress() {
    return Address.fromHex('0x6AE48bD83B6bdc8489584Ea0814086f963d1BD95');
  }
}
