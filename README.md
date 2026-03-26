# Social Gate Protocol

This repository implements a decentralized access-control layer for social applications. It bridges the gap between on-chain financial state and off-chain content availability.

## Core Features
* **Pay-to-Unlock**: Users pay a fixed tip to a creator to permanently unlock a piece of content.
* **Token Gating**: Users must hold a minimum balance of a specific ERC-20 token to view content.
* **Creator Registry**: A centralized place for creators to manage their "Gate" configurations and metadata.

## Workflow
1. **Setup**: A creator registers a `ContentID` and sets the `unlockPrice` or `requiredToken`.
2. **Access**: A frontend client checks the contract: `hasAccess(user, contentId)`.
3. **Unlock**: If no access, the user calls `unlockContent{value: price}()`.
