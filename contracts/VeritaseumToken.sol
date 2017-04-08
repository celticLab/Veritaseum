pragma solidity ^0.4.8;

import 'zeppelin/token/StandardToken.sol';      // ERC20 Standard Token interface
import 'zeppelin/ownership/Ownable.sol';        // set specific function for owner only
import 'zeppelin/lifecycle/Killable.sol';       // kill feature for contract

contract VeritaseumToken is Ownable, StandardToken, Killable {

    string public name = "Veritaseum";
    string public symbol = "VERI";
    uint public decimals = 18;

    uint public startTime = 1493130600;         // 2017 April 25th 9:30 EST (14:30 UTC)
    uint public closeTime = startTime + 31 days;
    uint public price = 30 ether;               // Each token has 18 decimal places, just like ether. 1 ETH = Ve 30 tokens (^E18). 
    uint public totalSupply = 100000000 ether;  // total supply of 100 Million Tokens
    uint public allocationRatio = 51;           // the totalSupply ratio of tokens allocated towards the ICO

    function VeritaseumToken() {
        balances[msg.sender] = totalSupply;     // allocate all initial tokens to the owner
    }

    function () payable {
        purchaseTokens(msg.sender);
    }
    
    function purchaseTokens(address _recipient) payable {
        // check if now is within ICO period, or if the amount sent is nothing
        if ((now < startTime) || (now > closeTime) || (msg.value == 0)) throw;
        
        // the check for the allocation ratio can only be done after the currentPrice has been determined below
        
        uint currentPrice;
        if (now < (startTime + 1 days)) {
            currentPrice = safeDiv(safeMul(price, 8), 10);  // 20 % discount (x * 8 / 10)
        } 
        else if (now < (startTime + 2 days)) {
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

    function allocateTokens(address _recipient, uint _value) onlyOwner {
        balances[_recipient] = balances[_recipient] + _value;
        balances[owner] = balances[owner] - _value;
    }

    // withdraw Ether
    function withdrawEther() payable onlyOwner returns (bool) {
        return owner.send(this.balance);
    }

    function transferOwnership(address _newOwner) onlyOwner {
        balances[_newOwner] = balances[owner];
        balances[owner] = 0;
        Ownable.transferOwnership(_newOwner);
    }
}
