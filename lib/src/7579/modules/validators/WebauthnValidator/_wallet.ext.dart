part of '../../../../../modules.dart';

const int typePrefixLength = 8; // `"type":"`
const int challengePrefixLength = 13; // `"challenge":"`

class _WebauthnWallet extends SmartWallet {
  final List<PassKeyPair> _keyPairs;

  final bool _uvRequired;

  /// Creates a new [_WebauthnWallet] from an existing [SmartWallet] instance.
  ///
  /// If [wallet] is already a [_WebauthnWallet], it is returned as-is.
  /// Otherwise, a new instance is created with the provided [keyPairs],
  /// optional [signer], and user-verification requirement flag [uvRequired].
  /// If [signer] is provided, the wallet will replace the default internal signer with the provided one.
  factory _WebauthnWallet.fromWallet(
    SmartWallet wallet,
    List<PassKeyPair> keyPairs, [
    PassKeySigner? signer,
    bool uvRequired = true,
  ]) {
    if (wallet is _WebauthnWallet) {
      return wallet;
    }

    return _WebauthnWallet.internal(
      wallet.state.copyWith(signer: signer),
      keyPairs,
      uvRequired,
    );
  }

  _WebauthnWallet.internal(super._state, this._keyPairs, this._uvRequired)
    : assert(
        _state.signer is PassKeySigner,
        "[WebauthnValidator]: SmartWallet signer must be an instance of [PassKeySigner]",
      );

  @override
  String get dummySignature => _getDummySignature();

  /// Encodes the provided credential IDs and PassKey signatures into a single ABI-encoded blob.
  ///
  /// The resulting bytes are structured as:
  /// - `bytes32[]` - list of credential IDs (keccak256 hashes)
  /// - `bool`      - `usePrecompile` flag, always set to `true`
  /// - `tuple[]`   - array of signature tuples, each containing:
  ///   - `bytes`   - authenticator data
  ///   - `string`  - client data JSON
  ///   - `uint256` - adjusted challenge position (`challengePos - challengePrefixLength`)
  ///   - `uint256` - adjusted type position (`typePos - typePrefixLength`)
  ///   - `uint256` - signature r-value
  ///   - `uint256` - signature s-value
  Uint8List encodeSignatures(List<Uint8List> ids, List<PassKeySignature> sigs) {
    return abi.encode(
      ["bytes32[]", "bool", "(bytes,string,uint256,uint256,uint256,uint256)[]"],
      [
        ids,
        true, // usePrecompile is always true
        [
          ...sigs.map(
            (sig) => [
              sig.authData,
              sig.clientDataJSON,
              BigInt.from(sig.challengePos - challengePrefixLength),
              BigInt.from(sig.typePos - typePrefixLength),
              sig.signature.$1.value,
              sig.signature.$2.value,
            ],
          ),
        ],
      ],
    );
  }

  /// {@macro genSig}
  Future<(List<Uint8List>, List<PassKeySignature>)> generateOffchainSignature(
    UserOperation op, [
    BlockInfo? blockInfo,
  ]) async {
    final signer = state.signer as PassKeySigner;
    final hash = op.hash(chain);

    List<Uint8List> credIds = [];
    List<PassKeySignature> sigs = [];

    for (var keypair in _keyPairs) {
      final credId = _getCredentialId(keypair);
      credIds.add(credId);

      final sig = await signer.signToPasskeySignature(
        hash,
        knownCredentials: [
          signer.credentialIdToType(keypair.authData.rawCredential),
        ],
      );
      sigs.add(sig);
    }
    return (credIds, sigs);
  }

  @override
  Future<String> generateSignature(
    UserOperation op,
    dynamic blockInfo,
    int? _,
  ) async {
    final base = await generateOffchainSignature(op, blockInfo);

    final webauthnSignature = encodeSignatures(base.$1, base.$2);
    return hexlify(webauthnSignature);
  }

  @override
  Future<UserOperation> prepareUserOperation(
    UserOperation op, {
    Uint256? nonceKey,
  }) {
    final validatorNonceKey = Uint256.fromList(
      WebauthnValidator.getAddress().value.padToNBytes(24, direction: "right"),
    );
    return super.prepareUserOperation(op, nonceKey: validatorNonceKey);
  }

  Uint8List _getCredentialId(PassKeyPair keypair) {
    return keccak256(
      abi.encode(
        ["uint256", "uint256", "bool", "address"],
        [
          keypair.authData.publicKey.$1.value,
          keypair.authData.publicKey.$2.value,
          _uvRequired,
          address,
        ],
      ),
    );
  }

  String _getDummySignature() {
    final uv = _uvRequired ? 0x04 : 0x01;
    final challenge = "p5aV2uHXr0AOqUk7HQitvi-Ny1p5aV2uHXr0AOqUk7H";
    final dummyCdField =
        '{"type":"webauthn.get","challenge":$challenge,"origin":"https://variance.space"}';
    final dummyAdField = Uint8List(37);
    dummyAdField.fillRange(0, dummyAdField.length, 0xfe);
    dummyAdField[32] = uv;

    final credId = _getCredentialId(_keyPairs.first);
    final sig = PassKeySignature(
      "null",
      credId,
      (Uint256.fromHex("0x${'ec' * 32}"), Uint256.fromHex("0x${'d5a' * 21}f")),
      dummyAdField,
      dummyCdField,
      dummyCdField.indexOf(challenge),
      dummyCdField.indexOf('webauthn.get'),
      "null",
    );

    final webauthnSignature = encodeSignatures([credId], [sig]);
    return hexlify(webauthnSignature);
  }
}
