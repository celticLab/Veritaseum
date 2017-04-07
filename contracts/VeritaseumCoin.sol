pragma solidity ^0.4.8;

import 'zeppelin/token/CrowdsaleToken.sol';     // ERC20 interface
import 'zeppelin/ownership/Ownable.sol';        // set specific function for owner only

contract VeritaseumCoin is CrowdsaleToken, Ownable {

    string public name = "Veritaseum";
    string public symbol = "VERI";
    uint public decimals = 18;

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
