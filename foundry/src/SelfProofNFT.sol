// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// NEW (correct)
import {ERC721} from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {Constants} from "./Constants.sol";

/// @dev Interface to the Steel 2.0 precompile (address TBD on dev-net)
interface ISteelVerifier {
    /// @return journalHash  –  upper 8 bits = score (0-255); lowest bit = pass/fail flag
    function verify(bytes calldata proof) external view returns (uint64 journalHash);
}

/// @title  SelfProofNFT
/// @notice Each agent mints (or refreshes) one ERC-721 that proves its last audit passed.
///         Validity window = Constants.PROOF_TTL.  Stake is escrowed on first mint.
contract SelfProofNFT is ERC721, Ownable {
    ISteelVerifier public immutable verifier;
    uint256 public nextId = 1;

    // agent address → tokenId
    mapping(address => uint256) public idOf;
    // tokenId → expiry timestamp
    mapping(uint256 => uint256) public expiresAt;
    // tokenId → staked amount (for view convenience)
    mapping(uint256 => uint256) public stakeOf;

    event ProofSubmitted(address indexed agent, uint256 tokenId, uint8 score);

    constructor(address _verifier)
        ERC721("Proof-of-Care NFT", "POC")
        Ownable(msg.sender)          // pass initial owner
    {
        verifier = ISteelVerifier(_verifier);
    }

    /* ----------  External ---------- */

    /// @notice Submit a Steel proof; mints or extends the caller’s NFT.
    /// @param proof   ZK receipt bytes from RISC-Zero guest
    function submit(bytes calldata proof) external payable {
        // Constant-gas verifier call
        uint64 h = verifier.verify(proof);
        uint8 score = uint8(h >> 56);
        bool ok     = (h & 0x1) == 1;
        require(ok && score <= 5, "Audit-fail");                 // C-3 threshold

        uint256 tid = idOf[msg.sender];
        if (tid == 0) {
            // first-time mint → enforce min stake
            require(msg.value >= Constants.MIN_STAKE, "Stake too low");
            tid = nextId++;
            _mint(msg.sender, tid);
            idOf[msg.sender] = tid;
            stakeOf[tid]    = msg.value;
        } else if (msg.value > 0) {
            stakeOf[tid] += msg.value;                           // allow top-ups
        }

        expiresAt[tid] = block.timestamp + Constants.PROOF_TTL;
        emit ProofSubmitted(msg.sender, tid, score);
    }

    /// @notice Anyone can slash a token by presenting a counter-proof.
    ///         Simplified v0: Guardian address only.
    function slash(uint256 tokenId, address guardian) external onlyOwner {
        _burn(tokenId);
        payable(guardian).transfer((stakeOf[tokenId] * Constants.SLASH_BPS) / 10_000);
        stakeOf[tokenId] = 0;
    }

    /* ----------  View helpers ---------- */

    function valid(address agent) external view returns (bool) {
        uint256 tid = idOf[agent];
        return (tid != 0 && block.timestamp < expiresAt[tid]);
    }
}
