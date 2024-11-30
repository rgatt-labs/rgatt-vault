// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/access/Ownable.sol";

contract VaultManager is Ownable {
    struct Vault {
        uint256 balance;
        uint256 unusedPercentage;
    }

    mapping(address => Vault) public subVaults;
    address[] public subVaultAddresses;

    uint256 public mainVaultBalance;

    event Redistribution(address indexed user, uint256 amount);

    // Constructor without explicit Ownable call
    constructor() {
        // Optionally add more initialization code here if needed
    }

    // Function to add funds to the main vault
    function addFundsToMainVault(uint256 amount) external onlyOwner {
        mainVaultBalance += amount;
    }

    // Function to add funds to a specific sub-vault
    function addFundsToSubVault(address subVault, uint256 amount) external onlyOwner {
        if (subVaults[subVault].balance == 0) {
            subVaultAddresses.push(subVault);
        }
        subVaults[subVault].balance += amount;
    }

    // Function to get the total balance of all sub-vaults
    function getSubVaultsBalance() public view returns (uint256 totalBalance) {
        for (uint256 i = 0; i < subVaultAddresses.length; i++) {
            address subVaultAddress = subVaultAddresses[i];
            totalBalance += subVaults[subVaultAddress].balance;
        }
    }

    // Function to calculate the unused funds in a specific sub-vault
    function calculateRedistribution(address subVault) public view returns (uint256) {
        Vault storage vault = subVaults[subVault];
        return (vault.balance * vault.unusedPercentage) / 100;
    }

    // Function to redistribute unused funds
    function redistributeFunds() external {
        uint256 totalRedistribution = 0;

        for (uint256 i = 0; i < subVaultAddresses.length; i++) {
            address subVaultAddress = subVaultAddresses[i];
            uint256 redistributionAmount = calculateRedistribution(subVaultAddress);
            totalRedistribution += redistributionAmount;
            subVaults[subVaultAddress].balance -= redistributionAmount;
            emit Redistribution(subVaultAddress, redistributionAmount);
        }

        mainVaultBalance -= totalRedistribution;
    }
}
