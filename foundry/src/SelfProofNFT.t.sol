// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/Constants.sol";
import "../src/SelfProofNFT.sol";

contract DummyVerifier {
    function verify(bytes calldata) external pure returns (uint64) {
        // score=4, ok=1
        return uint64(uint8(4)) << 56 | uint64(1);
    }
}

contract SelfProofNFTTest is Test {
    SelfProofNFT nft;

    function setUp() public {
        nft = new SelfProofNFT(address(new DummyVerifier()));
    }

    function testMintAndValidity() public {
        vm.deal(address(1), 1 ether);
        vm.prank(address(1));
        nft.submit{value: Constants.MIN_STAKE}(hex"deadbeef");

        assertTrue(nft.valid(address(1)));
    }

    function testStakeTooLowReverts() public {
        vm.deal(address(2), 0.2 ether);      // fund the wallet first
        vm.prank(address(2));
        vm.expectRevert();
        nft.submit{value: 0.1 ether}(hex"00");
    }
}
