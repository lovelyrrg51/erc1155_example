// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC1155Burnable.sol";
import "./Ownable.sol";

interface TypeTwoInterface {
    function mintTokenByOne(address owner, uint256 typeId, uint256 mintAmount) external;
}

contract Type1 is ERC1155Burnable, Ownable {
    TypeTwoInterface typeTwoToken;
    // whether minting by owner is allowed
    bool public manualMintAllowed = true;
    // individual uri per type
    mapping (uint256 => string) public typeToUri;
    // whether main uri is freezed
    bool public isUriFreezed;
    // whether each individual uri is freezed
    mapping (uint256 => bool) public typeIsUriFreezed;
    
    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory _uri)
        ERC1155(_uri)
    {}
    
    /**
     * Set Type2 Token
     */
    function setTypeTwoToken(address twoTokenAddress) public onlyOwner {
        typeTwoToken = TypeTwoInterface(twoTokenAddress);
    }

    /**
     * @dev Lock further manual minting by owner
     */
    function disableManualMint() public onlyOwner {
        manualMintAllowed = false;
    }
            
    /**
     * @dev Airdrop tokens to owners
     */
    function mintOwner(address[] calldata owners, uint256[] calldata types, uint256[] calldata counts) public onlyOwner {
      require(manualMintAllowed, "Not allowed");
      require(owners.length == types.length && types.length == counts.length, "Bad array lengths");
         
      for (uint256 i = 0; i < owners.length; i++) {
        _mint(owners[i], types[i], counts[i], "");
      }
    }

    /**
     * @dev Airdrop single tokens to owners
     */
    function mintOwnerOneToken(address[] calldata owners, uint256 typeId) public onlyOwner {
      require(manualMintAllowed, "Not allowed");
         
      for (uint256 i = 0; i < owners.length; i++) {
        _mint(owners[i], typeId, 1, "");
      }
    }

    function uri(uint256 typeId) public view override returns (string memory) {
        string memory typeUri = typeToUri[typeId];
        if (bytes(typeUri).length == 0) {
            return super.uri(typeId);
        } else {
            return typeUri;
        }
    }

    function burn(address account, uint256 id, uint256 value) public override {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );

        // Burn Type1 Token
        _burn(account, id, value);

        // Mint Type2 Token
        typeTwoToken.mintTokenByOne(account, id, value);
    }

    /**
     * @dev Updates the metadata URI
     */
    function updateUri(string calldata newUri) public onlyOwner {
        require(!isUriFreezed, "Freezed");
        _setURI(newUri);
    }

    /**
     * @dev Freezes the metadata URI
     */
    function freezeUri() public onlyOwner {
        isUriFreezed = true;
    }

    /**
     * @dev Updates and freezes the metadata URI
     */
    function permanentSetUri(string calldata newUri) public onlyOwner {
        updateUri(newUri);
        freezeUri();
    }

    /**
     * @dev Updates the metadata URI for a specific type
     */
    function updateUriForType(string calldata newUri, uint256 typeId) public onlyOwner {
        require(!typeIsUriFreezed[typeId], "Freezed");
        typeToUri[typeId] = newUri;
    }

    /**
     * @dev Freezes the metadata URI
     */
    function freezeUriForType(uint256 typeId) public onlyOwner {
        typeIsUriFreezed[typeId] = true;
    }

    /**
     * @dev Updates and freezes the metadata URI
     */
    function permanentSetUriForType(string calldata newUri, uint256 typeId) public onlyOwner {
        updateUriForType(newUri, typeId);
        freezeUriForType(typeId);
    }
}