part of 'interface.dart';

abstract class ExecutorModuleInterface extends Base7579ModuleInterface {
  ExecutorModuleInterface(super._wallet);

  final ContractAbi _abi = ContractAbi.fromJson(
    '[{"type":"function","name":"getExecutorsPaginated","inputs":[{"name":"cursor","type":"address","internalType":"address"},{"name":"pageSize","type":"uint256","internalType":"uint256"}],"outputs":[{"name":"array","type":"address[]","internalType":"address[]"},{"name":"next","type":"address","internalType":"address"}],"stateMutability":"view"}]',
    "getExecutorsPaginated",
  );

  /// Retrieves the list of currently installed executor modules on the account.
  ///
  /// Uses the `getExecutorsPaginated` view function starting from the sentinel address
  /// and fetches up to 100 executors. Returns the array of executor addresses.
  Future<List<Address>> getInstalledExecutors() async {
    final result = await _wallet.readContract(
      _wallet.address,
      _abi,
      _abi.name,
      params: [Addresses.sentinelAddress, BigInt.from(100)],
      sender: _wallet.address,
    );
    final modules = List<Address>.from(result.first);
    return modules;
  }

  @override
  Future<Uint8List> getDeInitData([Uint8List? context]) async {
    final executors = await getInstalledExecutors();
    final index = executors.indexOf(address);
    final prev = extractPrevAddress(index, executors);
    return abi.encode(["address", "bytes"], [prev, context ?? Uint8List(0)]);
  }
}
