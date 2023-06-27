// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.8.14;

import { Owned } from "../dependencies/solmate/Owned.sol";

import { ISoul } from "../interfaces/ISoul.sol";

import { CyberNFT721 } from "../base/CyberNFT721.sol";
import { LibString } from "../libraries/LibString.sol";

/**
 * @title Soul
 * @author CyberConnect
 * @notice A 721 NFT contract that indicates if an address is a CyberAccount.
 */
contract Soul is Owned, CyberNFT721, ISoul {
    /*//////////////////////////////////////////////////////////////
                                STATES
    //////////////////////////////////////////////////////////////*/

    mapping(address => bool) internal _orgs;
    string internal _tokenURI;
    mapping(address => bool) internal _minters;

    /*//////////////////////////////////////////////////////////////
                              MODIFIERS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Checks the sender is a minter.
     */
    modifier onlyMinter() {
        require(_minters[msg.sender], "ONLY_MINTER");
        _;
    }

    /*//////////////////////////////////////////////////////////////
                                 CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor() {
        _disableInitializers();
    }

    /*//////////////////////////////////////////////////////////////
                                 EXTERNAL
    //////////////////////////////////////////////////////////////*/

    function initialize(
        address owner,
        string calldata name,
        string calldata symbol
    ) external initializer {
        _minters[owner] = true;
        Owned.__Owned_Init(owner);
        super._initialize(name, symbol);
    }

    /// @inheritdoc ISoul
    function createSoul(
        address to,
        bool isOrg
    ) external override onlyMinter returns (uint256) {
        if (isOrg) {
            _orgs[to] = true;
        }
        uint256 tokenId = super._mint(to);
        emit CreateSoul(to, isOrg, tokenId);

        return tokenId;
    }

    /// @inheritdoc ISoul
    function setOrg(address account, bool isOrg) external override onlyOwner {
        require(balanceOf(account) > 0, "NOT_SOUL_OWNER");
        _orgs[account] = isOrg;

        emit SetOrg(account, isOrg);
    }

    /// @inheritdoc ISoul
    function setMinter(
        address account,
        bool _isMinter
    ) external override onlyOwner {
        _minters[account] = _isMinter;

        emit SetMinter(account, _isMinter);
    }

    /// @inheritdoc ISoul
    function isOrgAccount(
        address account
    ) external view override returns (bool) {
        require(balanceOf(account) > 0, "NOT_SOUL_OWNER");
        return _orgs[account];
    }

    /// @inheritdoc ISoul
    function isMinter(address account) external view override returns (bool) {
        return _minters[account];
    }

    /// @inheritdoc ISoul
    function setTokenURI(string calldata uri) external override onlyOwner {
        _tokenURI = uri;
    }

    /*//////////////////////////////////////////////////////////////
                                 PUBLIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Disallows the transfer of the soul.
     */
    function transferFrom(address, address, uint256) public pure override {
        revert("TRANSFER_NOT_ALLOWED");
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC VIEW
    //////////////////////////////////////////////////////////////*/

    /// ERC721
    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        _requireMinted(tokenId);
        return string(abi.encodePacked(_tokenURI, LibString.toString(tokenId)));
    }
}
