// SPDX-License-Identifier: CC-BY-SA-4.0

// Version of Solidity compiler this program was written for

pragma solidity ^0.8.0;

import "./LinkedList.sol";

contract coinInfo{
    
    struct specficBet{
        uint256 betStartPrice;
        uint256 betStartTime;
        LinkedList head;
    }
    
    string public name;
    address public OracleAddress; //used for chainlink aggreagor price to get bitcoin price
    mapping(uint256 => specficBet) public betList; //This is a mapping for betID which can be identified for example using the specific date since we have 1 bet per day.
    
    constructor(string memory Iname, address addr) public{
        name = Iname;
        OracleAddress = addr;
    }
    
    function getName() public view returns (string memory){
        return name;
    }
    
    }//it is important to return the betID (identifier for the mapping above) to the user(using event) so he can reedem his bet after 24h
