// SPDX-License-Identifier: CC-BY-SA-4.0

// Version of Solidity compiler this program was written for

pragma solidity ^0.8.0;

import "./BetsLog.sol";
import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract coinInfo{
    
    event time(address val,string name);
    
    struct specficBet{
        uint256 betStartPrice;
        uint256 betStartTime;
        uint256 num_betters;
        //bool initialized;
        BetsLog rise_betLog;
        BetsLog fall_betLog;
        uint256 total_bets;
        bool is_redeemed;
    }
    
    LinkTokenInterface private LINK;
    address payable owner;
    string public name;
    AggregatorV3Interface internal OracleContract; 
    AggregatorV3Interface internal priceFeedEther; 
    mapping(uint256 => specficBet) public betList; //This is a mapping for betID which can be identified for example using the specific date since we have 1 bet per day.
    // mapping(uint256 => betExists) public
    
    constructor(string memory Iname, address addr) {
        owner = payable(msg.sender);
        LINK = LinkTokenInterface(0xa36085F69e2889c224210F603D836748e7dC0088);
        OracleContract = AggregatorV3Interface(addr);
        priceFeedEther = AggregatorV3Interface(0x9326BFA02ADD2366b30bacB125260Af641031331);
        name = Iname;
    }
    
    struct _DateTime {
                uint16 year;
                uint8 month;
                uint8 day;
                uint8 hour;
                uint8 minute;
                uint8 second;
                uint8 weekday;
    }
    
    uint constant DAY_IN_SECONDS = 86400;
    uint constant YEAR_IN_SECONDS = 31536000;
    uint constant LEAP_YEAR_IN_SECONDS = 31622400;

    uint constant HOUR_IN_SECONDS = 3600;
    uint constant MINUTE_IN_SECONDS = 60;

    uint16 constant ORIGIN_YEAR = 1970;

    function isLeapYear(uint16 year) public pure returns (bool) {
        if (year % 4 != 0) {
                return false;
        }
        if (year % 100 != 0) {
                return true;
        }
        if (year % 400 != 0) {
                return false;
        }
        return true;
    }

    function leapYearsBefore(uint year) public pure returns (uint) {
        year -= 1;
        return year / 4 - year / 100 + year / 400;
    }

    function getDaysInMonth(uint8 month, uint16 year) public pure returns (uint8) {
        if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
                return 31;
        }
        else if (month == 4 || month == 6 || month == 9 || month == 11) {
                return 30;
        }
        else if (isLeapYear(year)) {
                return 29;
        }
        else {
                return 28;
        }
    }
    
    function getYear(uint timestamp) public pure returns (uint16) {
        uint secondsAccountedFor = 0;
        uint16 year;
        uint numLeapYears;

        // Year
        year = uint16(ORIGIN_YEAR + timestamp / YEAR_IN_SECONDS);
        numLeapYears = leapYearsBefore(year) - leapYearsBefore(ORIGIN_YEAR);

        secondsAccountedFor += LEAP_YEAR_IN_SECONDS * numLeapYears;
        secondsAccountedFor += YEAR_IN_SECONDS * (year - ORIGIN_YEAR - numLeapYears);

        while (secondsAccountedFor > timestamp) {
                if (isLeapYear(uint16(year - 1))) {
                        secondsAccountedFor -= LEAP_YEAR_IN_SECONDS;
                }
                else {
                        secondsAccountedFor -= YEAR_IN_SECONDS;
                }
                year -= 1;
        }
        return year;
        }
        
    function getHour(uint timestamp) public pure returns (uint8) {
        return uint8((timestamp / 60 / 60) % 24);
    }

    function getMinute(uint timestamp) public pure returns (uint8) {
        return uint8((timestamp / 60) % 60);
    }

    function getSecond(uint timestamp) public pure returns (uint8) {
        return uint8(timestamp % 60);
    }

    function getWeekday(uint timestamp) public pure returns (uint8) {
        return uint8((timestamp / DAY_IN_SECONDS + 4) % 7);
    }

    function parseTimestamp(uint timestamp) internal pure returns (_DateTime memory dt) {
        uint secondsAccountedFor = 0;
        uint buf;
        uint8 i;

        // Year
        dt.year = getYear(timestamp);
        buf = leapYearsBefore(dt.year) - leapYearsBefore(ORIGIN_YEAR);

        secondsAccountedFor += LEAP_YEAR_IN_SECONDS * buf;
        secondsAccountedFor += YEAR_IN_SECONDS * (dt.year - ORIGIN_YEAR - buf);

        // Month
        uint secondsInMonth;
        for (i = 1; i <= 12; i++) {
                secondsInMonth = DAY_IN_SECONDS * getDaysInMonth(i, dt.year);
                if (secondsInMonth + secondsAccountedFor > timestamp) {
                        dt.month = i;
                        break;
                }
                secondsAccountedFor += secondsInMonth;
        }

        // Day
        for (i = 1; i <= getDaysInMonth(dt.month, dt.year); i++) {
                if (DAY_IN_SECONDS + secondsAccountedFor > timestamp) {
                        dt.day = i;
                        break;
                }
                secondsAccountedFor += DAY_IN_SECONDS;
        }

        // Hour
        dt.hour = getHour(timestamp);

        // Minute
        dt.minute = getMinute(timestamp);

        // Second
        dt.second = getSecond(timestamp);

        // Day of week.
        dt.weekday = getWeekday(timestamp);
    }
    
    function getMonth(uint timestamp) public pure returns (uint8) {
        return parseTimestamp(timestamp).month;
    }

    function getDay(uint timestamp) public pure returns (uint8) {
        return parseTimestamp(timestamp).day;
    }

    // --------------------------------------------------------------------------------- //

    function placeBet(address sender, uint256 betValue, uint bet) public returns (uint256){
        //msg.value
        uint256 month = getMonth(block.timestamp);
        uint256 day = getDay(block.timestamp);
        uint256 betID = month * 100 + day;

        specficBet storage currBet = betList[betID];
        
        currBet.total_bets += betValue;
        
        if (currBet.betStartTime != 0){ //there exists a bet in this time 
            
            require(block.timestamp < currBet.betStartTime + 2 minutes, "1 minute has passed since the bet started, try again tomorrow !");
            require(currBet.num_betters < 50 , "max number of betters reached, try again tomorrow");
            
            // concatenate to the end of the bets on the current bet.
            if(bet == 0){
               currBet.rise_betLog.addHead(betValue, sender, bet); 
            }else{
                currBet.fall_betLog.addHead(betValue, sender, bet);
            }
            
            
        }else {// need to create a new bet mapping
            
            (
                , 
                int price,
                ,
                ,
                
            ) = OracleContract.latestRoundData();
    
            (
                , 
                int price2,
                ,
                ,
                
            ) = priceFeedEther.latestRoundData();

            betList[betID] = specficBet({betStartPrice : (uint256(price) * 10**18)/uint256(price2), betStartTime : block.timestamp, num_betters : 0, rise_betLog : new BetsLog(), fall_betLog : new BetsLog(), total_bets :0, is_redeemed : false});
            if(bet == 0){
                betList[betID].rise_betLog.addHead(betValue, sender, bet);   
            }else{
                betList[betID].fall_betLog.addHead(betValue, sender, bet);   
            }
        }
        
        return betID;
    }
    
    function redeemBet(uint256 betID) public returns (uint256[] memory, address[] memory){
        require(betList[betID].betStartTime > 0, "No such bet exists");
        require(betList[betID].is_redeemed == false, "Bet already redeemed");
        
        uint256 curr_value;
        (
            , 
            int price,
            ,
            ,
            
        ) = OracleContract.latestRoundData();

        (
            , 
            int price2,
            ,
            ,
            
        ) = priceFeedEther.latestRoundData();

        curr_value = (uint256(price) * 10**18)/uint256(price2);
        
        betList[betID].is_redeemed = true;
        
        specficBet memory sBet = betList[betID];
        
        if (curr_value > betList[betID].betStartPrice) {
            return sBet.rise_betLog.redeemBets(sBet.total_bets);
        }
        
        return sBet.fall_betLog.redeemBets(sBet.total_bets);
    }
    
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    // Accept any incoming amount - I guess if anyone want to donate :) 
    receive() external payable {}

    // Contract destructor
    function destroy() public onlyOwner {
        /*add withdraw link back to my address aswell or I'll lose the link*/
        LINK.transfer(owner, LINK.balanceOf(address(this)));
        selfdestruct(owner);
    }
    
    
}//it is important to return the betID (identifier for the mapping above) to the user(using event) so he can reedem his bet after 24h