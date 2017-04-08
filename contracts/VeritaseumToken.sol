pragma solidity ^0.4.8;

import 'zeppelin/token/StandardToken.sol';      // ERC20 Standard Token interface
import 'zeppelin/ownership/Ownable.sol';        // set specific function for owner only
import 'zeppelin/lifecycle/Killable.sol';       // kill feature for contract

/// @title Veritaseum Lottery
/// @author Riaan F Venter~ RFVenter~ <msg@rfv.io>
contract VeritaseumToken is Ownable, StandardToken, Killable {

    string public name = "Veritaseum";          // name of the token
    string public symbol = "VERI";              // ERC20 compliant 4 digit token code
    uint public decimals = 18;                  // token has 18 digit precision

    uint public startTime = 1493130600;         // 2017 April 25th 9:30 EST (14:30 UTC)
    uint public closeTime = startTime + 31 days;// ICO will run for 31 days
    uint public price = 30 ether;               // Each token has 18 decimal places, just like ether. 1 ETH = Ve 30 tokens (^E18). 
    uint public totalSupply = 100000000 ether;  // total supply of 100 Million Tokens
    uint public allocationRatio = 51;           // the totalSupply ratio of tokens allocated towards the ICO

    /// @notice Initializes the contract and allocates all initial tokens to the owner
    function VeritaseumToken() {
        balances[msg.sender] = totalSupply;
    }

    /// @notice default fall-back function of the contract, when sending Ether to this contact this function will be called
    function () payable {                       
        purchaseTokens(msg.sender);
    }
    
    /// @notice Used to buy tokens with Ether
    /// @param _recipient The actual recipient of the tokens
    function purchaseTokens(address _recipient) payable {
        // check if now is within ICO period, or if the amount sent is nothing
        if ((now < startTime) || (now > closeTime) || (msg.value == 0)) throw;
        
        // the check to make sure token allocation is within the allocation ratio can only be done after the currentPrice has been determined below (based on prevaling rate)
        
        uint currentPrice;
        // using safeMath for all calculatinos below except for datetimes
        if (now < (startTime + 1 days)) {       // day one discount
            currentPrice = safeDiv(safeMul(price, 8), 10);  // 20 % discount (x * 8 / 10)
        } 
        else if (now < (startTime + 2 days)) {  // day two discount
            currentPrice = safeDiv(safeMul(price, 9), 10);  // 10 % discount (x * 9 / 10)
        }
        else if (now < (startTime + 12 days)) {
            // 1 % reduction in the discounted rate from day 2 until day 12 (sliding scale per second)
            // 8640000 is 60 x 60 x 24 x 100 (100 for 1%) (60 x 60 x 24 for seconds per day)
            currentPrice = safeSub(price, safeDiv(safeMul(startTime + 12 days - now, price), 8640000));
        }
        else {
            currentPrice = price;
        }
        uint tokens = safeMul(msg.value, currentPrice);

        // check if this purchase will go over the allowed ICO allocation ratio
        // current ICO ownership: totalSupply - balances[owner]
        // ICO may have up to allocationRatio of totalSupply: totalSupply / allocationRatio
        if ((totalSupply - balances[owner] + tokens) <= safeDiv(totalSupply, allocationRatio)) {
            // transfer tokens from owner account to purchasers account
            balances[_recipient] = safeAdd(balances[_recipient], tokens);
            balances[owner] = safeSub(balances[owner], tokens);
        }
        else {
            // return the Ether
            throw;
        }
    }

    //////////////// owner only functions below

    /// @notice Manually allocate tokens to Ethereum addresses
    /// @param _recipient The address of the recipient to receive the tokens
    /// @param _value The amount of tokens
    function allocateTokens(address _recipient, uint _value) onlyOwner {
        balances[_recipient] = balances[_recipient] + _value;
        balances[owner] = balances[owner] - _value;
    }

    /// @notice Withdraw all Ether in this contract
    /// @return True if successful
    function withdrawEther() payable onlyOwner returns (bool) {
        return owner.send(this.balance);
    }

    /// @notice To transfer token contract ownership
    /// @param _newOwner The address of the new owner of this contract
    function transferOwnership(address _newOwner) onlyOwner {
        balances[_newOwner] = balances[owner];
        balances[owner] = 0;
        Ownable.transferOwnership(_newOwner);
    }
}
