part of '../../../../../eip7579.dart';

enum OrderType { buy, sell }

class Order {
  final Address buyToken;
  final Address sellToken;
  final BigInt amount;
  final OrderType orderType;
  final String? priceLimit;
  final String? expirationDate;

  Order({
    required this.buyToken,
    required this.sellToken,
    required this.amount,
    required this.orderType,
    this.priceLimit,
    this.expirationDate,
  });
}

typedef RecurringOrder = ({Order order, Schedule schedule});

class ScheduledOrders extends ExecutorModuleInterface {
  static final _deployedModule = ScheduledOrdersContract(getAddress());

  final BigInt _executeInterval;
  final BigInt _numberOfExecutions;
  final DateTime _startDate;
  final Uint8List _executionData;

  ScheduledOrders(
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
  String get name => 'ScheduledOrders';

  @override
  ModuleType get type => ModuleType.executor;

  @override
  String get version => '1.0.0';

  ///////////////////////////////////////////////////////////////
  //            READS
  ///////////////////////////////////////////////////////////////

  @override
  Uint8List getInitData() {
    return getSwapRouterAddress((contract as SmartWallet).chain.chainId).value
        .concat(_executeInterval.toBytes(6))
        .concat(_numberOfExecutions.toBytes(2))
        .concat(dateTimeToInt(_startDate).toBytes(6))
        .concat(_executionData);
  }

  //////////////////////////////////////////////////////////////////
  //            WRITES
  ///////////////////////////////////////////////////////////////

  Future<UserOperationReceipt?> executeOrder(BigInt jobId) async {
    final swapDetails = defaultSwapDetails();
    final calldata = _deployedModule.contract
        .function('executeOrder')
        .encodeCall([
          jobId,
          swapDetails["sqrtPriceLimitX96"],
          swapDetails["amountOutMin"],
          swapDetails["fee"],
        ]);
    final tx = await contract.sendTransaction(address, calldata);
    final receipt = await tx.wait();
    return receipt;
  }

  Future<UserOperationReceipt?> addOrder(RecurringOrder order) async {
    final swapOrderData = abi.encode(
      ["address", "address", "uint256"],
      [order.order.buyToken, order.order.sellToken, order.order.amount],
    );
    final calldata = _deployedModule.contract.function('addOrder').encodeCall([
      order.schedule.repeatEvery.toBytes(6),
      order.schedule.numberOfRepeats.toBytes(2),
      dateTimeToInt(order.schedule.startDate).toBytes(6),
      swapOrderData,
    ]);
    final tx = await contract.sendTransaction(address, calldata);
    final receipt = await tx.wait();
    return receipt;
  }

  //////////////////////////////////////////////////////////////////
  //            STATIC METHODS
  ///////////////////////////////////////////////////////////////
  static Address getAddress() {
    return Address.fromHex('0x40dc90D670C89F322fa8b9f685770296428DCb6b');
  }
}
