// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title  Global constants for the Proof-of-Care roll-up
/// @notice Hard-codes the Constitution hash, stake params and NFT expiry.
///         Import this in SelfProofNFT.sol, PeerRing.sol, etc.
library Constants {
    /// @dev SHA-256 of docs/constitution-v0.1.md
    bytes32 internal constant CONSTITUTION_HASH =
        0x920e34b33567fb5f384f588e05ef19ce4d456072ec8b392c3773caf1f9934e56;

    /// @dev Minimum restaked stake (wei) an agent must post (0.5 ETH)
    uint256 internal constant MIN_STAKE = 0.5 ether;

    /// @dev Slash ratio (basis points). 1000 = 10 %
    uint16  internal constant SLASH_BPS = 1000;

    /// @dev How long a SelfProof NFT stays valid after mint (in seconds)
    uint256 internal constant PROOF_TTL = 4 hours;
}
