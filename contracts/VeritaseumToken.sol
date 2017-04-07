pragma solidity ^0.4.8;

import 'zeppelin/token/StandardToken.sol';      // ERC20 Standard Token interface
import 'zeppelin/ownership/Ownable.sol';        // set specific function for owner only

contract VeritaseumToken is Ownable, StandardToken {

    string public name = "Veritaseum";
    string public symbol = "VERI";
    uint public decimals = 18;

    uint public startTime = 1493130600;         // 2017 April 25th 9:30 EST (14:30 UTC)
    uint public closeTime = startTime + 31 days;
    uint public price = 50 ether;               // Each token has 18 decimal places, just like ether. 1 ETH = 50 tokens (^E18). 
    uint public totalSupply = 100 ether;        // total supply of 100 Million Tokens

    function VeritaseumToken() {
        balances[msg.sender] = totalSupply;     // allocate all initial tokens to the owner
    }

    function () payable {
        createTokens(msg.sender);
    }
    
    function createTokens(address recipient) payable {
        uint currentPrice;

        if ((now < startTime) || (now > closeTime) || (msg.value == 0)) throw;

        if (now < (startTime + 1 days)) {
            currentPrice = safeDiv(safeMul(price, 8), 10);  // 20 % discount (x * 8 / 10)
        } 
        else if (now < (startTime + 2 days)) {
            currentPrice = safeDiv(safeMul(price, 9), 10);  // 10 % discount (x * 9 / 10)
        }
        else if (now < (startTime + 12 days)) {
            // 1 % reduction in the discounted rate from day 2 until day 12 (sliding scale per second)
            // 8640000 is 60 x 60 x 24 x 100 (100 for 1%) (60 x 60 x 24 for seconds per day)
            currentPrice = price - safeDiv(safeMul(startTime + 12 days - now, price), 8640000);
        }
        else {
            currentPrice = price;
        }

        uint tokens = safeMul(msg.value, currentPrice);

        // transfer tokens from owner account to purchasers account
        balances[recipient] = safeAdd(balances[recipient], tokens);
        balances[owner] = safeSub(balances[owner], tokens);
    }

    // withdraw Ether
    function withdrawEther() payable onlyOwner returns (bool) {
        return owner.send(this.balance);
    }

    // replace this with any other price function
    function setPrice(uint _price) onlyOwner {
        price = _price;
    }

    function transferOwnership(address newOwner) onlyOwner {
        balances[newOwner] = balances[owner];
        balances[owner] = 0;
        Ownable.transferOwnership(newOwner);
    }
}
