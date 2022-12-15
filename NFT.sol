// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

contract NFT is ERC721, ERC721Enumerable, Pausable, AccessControl, ERC721Burnable {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    string private _uriBase;

    constructor(
        string memory name,
        string memory symbol,
        string memory uriBase
    ) ERC721(name, symbol) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);

        _uriBase = uriBase;
    }

    function _baseURI() internal view override returns (string memory) {
        return _uriBase;
    }

    function setBaseURI(string memory uriBase) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _uriBase = uriBase;
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function safeMint(address to, uint256 tokenId) public onlyRole(MINTER_ROLE) {
        _safeMint(to, tokenId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) whenNotPaused {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function tokenIdsOfOwner(
        address owner,
        uint256 startIdx,
        uint256 size
    )
        public
        view
        returns (
            uint256[] memory,
            uint256,
            uint256
        )
    {
        require(0 < size && size <= 32, "incorrect size");

        uint256 last = 0;
        uint256 remain = 0;

        uint256 length = balanceOf(owner);
        if (length == 0 || startIdx >= length) {
            size = 0;
        } else {
            if (startIdx + size - 1 >= length) {
                size = length - startIdx;
            }
            last = startIdx + size;
            remain = length - last;
        }

        uint256[] memory ids = new uint256[](size);
        for (uint256 i = startIdx; i < last; i++) {
            ids[i - startIdx] = tokenOfOwnerByIndex(owner, i);
        }
        return (ids, size, remain);
    }
}
