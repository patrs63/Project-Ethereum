// SPDX-License-Identifier: CC-BY-SA-4.0

// Version of Solidity compiler this program was written for

pragma solidity ^0.8.0;

import "./BetsLog.sol";
import "./DateTime.sol";
import "./Loot.sol";

contract coinInfo{
    
    struct specficBet{
        uint256 betStartPrice;
        uint256 betStartTime;
        //bool initialized;
        BetsLog betLog;
    }
    
    string public name;
    address public OracleAddress; //used for chainlink aggreagor price to get bitcoin price
    DateTime  public timeLibrary;
    mapping(uint256 => specficBet) public betList; //This is a mapping for betID which can be identified for example using the specific date since we have 1 bet per day.
    // mapping(uint256 => betExists) public
    constructor(string memory Iname, address addr,address timeLibraryAddr) {
        name = Iname;
        OracleAddress = addr;
        timeLibrary = DateTime(timeLibraryAddr);
    }
    
    function getName() public view returns (string memory){
        return name;
    }
    
    function getAddress() public view returns (address){
        return OracleAddress;
    }
    
    function placeBet(address sender, uint256 betValue, bool bet) public returns (uint256){
        //msg.value
        uint256 betID = ((timeLibrary.getYear(block.timestamp))*100+
                            (timeLibrary.getMonth(block.timestamp)))*100+(timeLibrary.getDay(block.timestamp));
        
        specficBet storage currBet = betList[betID];
        if (currBet.betStartTime != 0){ //there exists a bet in this time 
            
            require(block.timestamp < currBet.betStartTime + 1 hours, "1 hour has passed since the bet started, try again tomorrow !");
            // concatenate to the end of the bets on the current bet.
            currBet.betLog.addHead(betValue, sender, bet);
            
        }else {// need to create a new bet mapping
        
            betList[betID] = specficBet({betStartPrice : 1, betStartTime : block.timestamp, betLog : new BetsLog()});
            currBet.betLog.addHead(betValue, sender, bet);
        }
        
        return betID;
    }
    
    
    function redeemBet(uint256 betID) public returns (Loot){
        require(betList[betID].betStartTime > 0, "No such bet exists");
        require(block.timestamp > betList[betID].betStartTime +1 days, "cannot claim yet");
        //calc the curr vlue
        return betList[betID].betLog.redeemBets(actual);
    }
    
}//it is important to return the betID (identifier for the mapping above) to the user(using event) so he can reedem his bet after 24h
    
    
    
    
    
    