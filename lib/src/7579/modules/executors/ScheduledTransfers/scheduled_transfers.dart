part of '../../../../../eip7579.dart';

class Schedule {
  final DateTime startDate;
  final BigInt repeatEvery;
  final BigInt numberOfRepeats;

  Schedule({
    required this.startDate,
    required this.repeatEvery,
    required this.numberOfRepeats,
  });

  static BigInt dateTimeToInt(DateTime time) {
    return BigInt.from(time.millisecondsSinceEpoch);
  }
}

class ScheduledTransfers extends ExecutorModuleInterface {
  static final _deployedModule = ScheduledTransfersContract(getAddress());

  final BigInt _executeInterval;
  final BigInt _numberOfExecutions;
  final DateTime _startDate;
  final Uint8List _executionData;

  ScheduledTransfers(
    super.wallet,
    this._executeInterval,
    this._numberOfExecutions,
    this._startDate,
    this._executionData,
  );

  ///////////////////////////////////////////////////////////////
  //            GETTERS
  ///////////////////////////////////////////////////////////////
  @override
  Address get address => getAddress();

  @override
  Uint8List get initData => getInitData();

  @override
  String get name => 'ScheduledTransfers';

  @override
  ModuleType get type => ModuleType.executor;

  @override
  String get version => '1.0.0';

  ///////////////////////////////////////////////////////////////
  //            READS
  ///////////////////////////////////////////////////////////////

  @override
  Uint8List getInitData() {
    return intToBytes(_executeInterval)
        .padToNBytes(6)
        .concat(intToBytes(_numberOfExecutions).padToNBytes(2))
        .concat(intToBytes(Schedule.dateTimeToInt(_startDate)).padToNBytes(6))
        .concat(_executionData);
  }

  //////////////////////////////////////////////////////////////////
  //            WRITES
  ///////////////////////////////////////////////////////////////

  Future<UserOperationReceipt?> toggleOrder(BigInt jobId) async {
    final calldata = _deployedModule.contract
        .function('toggleOrder')
        .encodeCall([jobId]);
    final tx = await contract.sendTransaction(address, calldata);
    final receipt = await tx.wait();
    return receipt;
  }

  Future<UserOperationReceipt?> executeOrder(BigInt jobId) async {
    final calldata = _deployedModule.contract
        .function('executeOrder')
        .encodeCall([jobId]);
    final tx = await contract.sendTransaction(address, calldata);
    final receipt = await tx.wait();
    return receipt;
  }

  Future<UserOperationReceipt?> addOrder(
    Schedule schedule,
    BigInt amount,
    Address recipient, [
    Address? token,
  ]) async {
    final transferdata = abi.encode(
      ["address", "address", "uint256"],
      [recipient, token ?? Addresses.zeroAddress, amount],
    );
    final calldata = _deployedModule.contract.function('addOrder').encodeCall([
      intToBytes(schedule.repeatEvery).padToNBytes(6),
      intToBytes(schedule.numberOfRepeats).padToNBytes(2),
      intToBytes(Schedule.dateTimeToInt(schedule.startDate)).padToNBytes(6),
      transferdata,
    ]);
    final tx = await contract.sendTransaction(address, calldata);
    final receipt = await tx.wait();
    return receipt;
  }

  //////////////////////////////////////////////////////////////////
  //            STATIC METHODS
  ///////////////////////////////////////////////////////////////
  static Address getAddress() {
    return Address.fromHex('0xA8E374779aeE60413c974b484d6509c7E4DDb6bA');
  }
}
