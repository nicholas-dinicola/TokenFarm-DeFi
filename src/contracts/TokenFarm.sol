pragma solidity ^0.5.0; 

import "./DappToken.sol";
import "./DaiToken.sol";

contract TokenFarm{
    string public name = "Dapp Token Farm";
    address public owner; 
    DappToken public dappToken; 
    DaiToken public daiToken; 

    // Array of people who ever staked the app - Kepp track of them 
    address[] public stakers; // Array 
    mapping(address => uint) public stakingBalance;
    mapping (address => bool) public hasStaked;
    mapping (address => bool) public isStaking;

    constructor(DappToken _dappToken, DaiToken _daiToken) public {
        dappToken = _dappToken;
        daiToken = _daiToken;
        owner = msg.sender;
    }

    // 1. Stakes tokens - Investor can put monei in the app (deposit) 
    function stakeTokens(uint _amount) public { // amount = amount of money to stake
        // Require amount greater than 0 
        require(_amount > 0, "amount cannot be 0");

        // Transfer Mock Dai tokens to this contract for staking 
        daiToken.transferFrom(msg.sender, address(this), _amount); // msg global variable in sol, sender the person who calls the function 

        // Update staking balance (using mapping defined above)
        stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;

        // Add user to stakers array *only* if they haven't staked already 
        if(!hasStaked[msg.sender]) {
            stakers.push(msg.sender);
        }

    // Update staking status
        isStaking[msg.sender] = true;
        hasStaked[msg.sender] = true; 
    }

    // Unstaking Tokens _ innvestor can take money fro the app (Withdraw)
    function unstakeTokens() public {
        // Fetch staking balance
        uint balance = stakingBalance[msg.sender];

        // Require amount greater than 0 
        require(balance > 0, "staking balance cannot be 0");

        // Transfer MOck Dai tokens to this contract for staking
        daiToken.transfer(msg.sender, balance);

        // Reset staking balance
        stakingBalance[msg.sender] = 0;

        // Update staking status 
        isStaking[msg.sender] = false;

    }

    // IssuingTokens 
    function issueTokens() public {
        // Only owner can call this function
        require(msg.sender == owner, "caller must be the owner");

        // Issue tokens to all stakers 
        for (uint i=0; i<stakers.length; i++) {
           address recipient = stakers[i]; 
           uint balance = stakingBalance[recipient];
           if(balance > 0) {
               dappToken.transfer(recipient, balance);
           }
       }
    }
}