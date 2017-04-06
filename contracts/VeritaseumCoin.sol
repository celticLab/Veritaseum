pragma solidity ^0.4.8;

import 'zeppelin/token/CrowdsaleToken.sol';     // ERC20 interface
import 'zeppelin/ownership/Ownable.sol';        // set specific function for owner only

contract VeritaseumCoin is CrowdsaleToken, Ownable {

    string public name = "VeritaseumToken";
    string public symbol = "VERI";
    uint public decimals = 18;

    // replace this with any other price function
    function setPrice(uint _price) onlyOwner {
      	PRICE = _price;
    }

    // withdraw Ether
    function withdrawEther() payable onlyOwner returns (bool) {
        return owner.send(this.balance);
    }

    function mint(address _to, uint256 _value) onlyOwner {
        if(_value <= 0) throw;                                      // Check send token value > 0;
    	balances[_to] += _value;
    	totalSupply += _value;
    }
}
