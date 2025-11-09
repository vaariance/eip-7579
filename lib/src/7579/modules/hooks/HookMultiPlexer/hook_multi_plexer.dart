part of '../../../../../eip7579.dart';

enum HookType { global, delegatecall, value, sig, target }

typedef SigHookInit = ({Uint8List sig, List<Address> subHooks});

class HookMultiPlexer extends HookModuleInterface {
  static final _deployedModule = HookMultiPlexerContract(getAddress());

  final List<Address> _globalHooks;
  final List<Address> _valueHooks;
  final List<Address> _delegatecallHooks;
  final List<SigHookInit> _sigHooks;
  final List<SigHookInit> _targetHooks;

  HookMultiPlexer(
    super.wallet,
    this._globalHooks,
    this._valueHooks,
    this._delegatecallHooks,
    this._sigHooks,
    this._targetHooks,
  );

  ///////////////////////////////////////////////////////////////
  //            GETTERS
  ///////////////////////////////////////////////////////////////
  @override
  Address get address => getAddress();

  @override
  Uint8List get initData => getInitData();

  @override
  String get name => "HookMultiPlexer";

  @override
  ModuleType get type => ModuleType.hook;

  @override
  String get version => '1.0.0';

  ///////////////////////////////////////////////////////////////
  //            READS
  ///////////////////////////////////////////////////////////////
  @override
  Uint8List getInitData() {
    return abi.encode(
      [
        "address[]",
        "address[]",
        "address[]",
        "(address[],bytes4)[]",
        "(address[],bytes4)[]",
      ],
      [
        _globalHooks,
        _valueHooks,
        _delegatecallHooks,
        [
          ..._sigHooks.map((e) => [e.subHooks, e.sig.padToNBytes(4)]),
        ],
        [
          ..._targetHooks.map((e) => [e.subHooks, e.sig.padToNBytes(4)]),
        ],
      ],
    );
  }

  Future<List<Address>?> getHooks([Address? account]) async {
    final result = await contract.readContract(
      address,
      hook_multi_plexer_abi,
      'getHooks',
      params: [account ?? contract.address],
    );
    return result.firstOrNull;
  }

  //////////////////////////////////////////////////////////////////
  //            WRITES
  ///////////////////////////////////////////////////////////////
  Future<UserOperationReceipt?> addHook(
    Address hook,
    HookType type, [
    Uint8List? sig,
  ]) async {
    final calldata = _deployedModule.contract
        .function(sig != null ? 'addSigHook' : 'addHook')
        .encodeCall(
          sig != null
              ? [hook, sig.padToNBytes(4), type.index]
              : [hook, type.index],
        );
    final tx = await contract.sendTransaction(address, calldata);
    final receipt = await tx.wait();
    return receipt;
  }

  Future<UserOperationReceipt?> removeHook(
    Address hook,
    HookType type, [
    Uint8List? sig,
  ]) async {
    final calldata = _deployedModule.contract
        .function(sig != null ? 'removeSigHook' : 'removeHook')
        .encodeCall(
          sig != null
              ? [hook, sig.padToNBytes(4), type.index]
              : [hook, type.index],
        );
    final tx = await contract.sendTransaction(address, calldata);
    final receipt = await tx.wait();
    return receipt;
  }

  //////////////////////////////////////////////////////////////////
  //            STATIC METHODS
  ///////////////////////////////////////////////////////////////
  static Address getAddress() {
    return Address.fromHex('0xF6782ed057F95f334D04F0Af1Af4D14fb84DE549');
  }
}
