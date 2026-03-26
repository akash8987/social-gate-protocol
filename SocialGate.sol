// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract SocialGate is ReentrancyGuard {
    struct Content {
        address creator;
        uint256 unlockPrice; // In Native Token (ETH/MATIC)
        address requiredToken; // ERC20 for gating (address(0) if none)
        uint256 minTokenBalance;
        string encryptedUri;
    }

    // contentId => Content Details
    mapping(bytes32 => Content) public registry;
    // user => contentId => hasUnlocked
    mapping(address => mapping(bytes32 => bool)) public accessGrants;

    event ContentCreated(bytes32 indexed contentId, address indexed creator);
    event ContentUnlocked(bytes32 indexed contentId, address indexed user);

    /**
     * @dev Register a new piece of gated content.
     */
    function registerContent(
        bytes32 _contentId,
        uint256 _price,
        address _token,
        uint256 _minBalance,
        string calldata _uri
    ) external {
        registry[_contentId] = Content({
            creator: msg.sender,
            unlockPrice: _price,
            requiredToken: _token,
            minTokenBalance: _minBalance,
            encryptedUri: _uri
        });

        emit ContentCreated(_contentId, msg.sender);
    }

    /**
     * @dev Pay to unlock content.
     */
    function unlockWithPayment(bytes32 _contentId) external payable nonReentrant {
        Content storage content = registry[_contentId];
        require(msg.value >= content.unlockPrice, "Insufficient payment");
        require(content.creator != address(0), "Content does not exist");

        accessGrants[msg.sender][_contentId] = true;
        
        (bool success, ) = payable(content.creator).call{value: msg.value}("");
        require(success, "Creator payment failed");

        emit ContentUnlocked(_contentId, msg.sender);
    }

    /**
     * @dev Check if a user has access (either through payment or token holding).
     */
    function hasAccess(address _user, bytes32 _contentId) public view returns (bool) {
        Content storage content = registry[_contentId];
        
        // 1. Check if user paid to unlock
        if (accessGrants[_user][_contentId] || _user == content.creator) {
            return true;
        }

        // 2. Check token-gating requirements
        if (content.requiredToken != address(0)) {
            uint256 balance = IERC20(content.requiredToken).balanceOf(_user);
            return balance >= content.minTokenBalance;
        }

        return false;
    }
}
