// GENERATED CODE - DO NOT MODIFY BY HAND
// Generated from lib/src/7579/modules/executors/ScheduledOrders/scheduled_orders.abi.json

// ignore_for_file: non_constant_identifier_names

import 'package:web3dart/web3dart.dart';
import 'package:web3_signers/web3_signers.dart';

/// The ABI string exported from the original .abi.json file.
final ContractAbi scheduled_orders_abi = ContractAbi.fromJson(
  '[{"inputs":[{"internalType":"bytes","name":"orderData","type":"bytes"}],"name":"addOrder","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"jobId","type":"uint256"},{"internalType":"uint160","name":"sqrtPriceLimitX96","type":"uint160"},{"internalType":"uint256","name":"amountOutMinimum","type":"uint256"},{"internalType":"uint24","name":"fee","type":"uint24"}],"name":"executeOrder","outputs":[],"stateMutability":"nonpayable","type":"function"}]',
  'scheduled_orders',
);

/// A helper class for the contract.
/// You must provide the contract [address] when instantiating.
class ScheduledOrdersContract {
  final DeployedContract contract;

  ScheduledOrdersContract(Address address)
    : contract = DeployedContract(scheduled_orders_abi, address);
}
