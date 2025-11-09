// GENERATED CODE - DO NOT MODIFY BY HAND
// Generated from lib/src/7579/modules/executors/ScheduledTransfers/scheduled_transfers.abi.json

// ignore_for_file: non_constant_identifier_names

import 'package:web3dart/web3dart.dart';
import 'package:web3_signers/web3_signers.dart';

/// The ABI string exported from the original .abi.json file.
final ContractAbi scheduled_transfers_abi = ContractAbi.fromJson(
  '[{"inputs":[{"internalType":"bytes","name":"orderData","type":"bytes"}],"name":"addOrder","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"jobId","type":"uint256"}],"name":"executeOrder","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"jobId","type":"uint256"}],"name":"toggleOrder","outputs":[],"stateMutability":"nonpayable","type":"function"}]',
  'scheduled_transfers',
);

/// A helper class for the contract.
/// You must provide the contract [address] when instantiating.
class ScheduledTransfersContract {
  final DeployedContract contract;

  ScheduledTransfersContract(Address address)
    : contract = DeployedContract(scheduled_transfers_abi, address);
}
