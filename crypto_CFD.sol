// SPDX-License-Identifier: CC-BY-SA-4.0

// Version of Solidity compiler this program was written for

pragma solidity ^0.6.0;

import "./LinkedList.sol";

contract CryptoCFD {
    
    event test(uint256 node_id, string name);

    struct specficBet{
        uint256 betStartPrice;
        uint256 betStartTime;
        LinkedList head;
    }

    struct coinInfo{
        string name;
        address OracleAddress; //used for chainlink aggreagor price to get bitcoin price
        mapping(uint256 => LinkedList) betList; //This is a mapping for betID which can be identified for example using the specific date since we have 1 bet per day.
    }//it is important to return the betID (identifier for the mapping above) to the user(using event) so he can reedem his bet after 24h

    mapping(string => coinInfo) coinsList; //mapping form coin index (for example bitcoin = 1 )
    
    constructor() {
        //BTC
        coinInfo memory coin = coinInfo("BTC", 0x6135b13325bfC4B00278B4abC5e20bbce2D6580e);
        coinsList["BTC"] = coin;

        //XRP
        coinInfo memory coin = coinInfo("XRP", 0x3eA2b7e3ed9EA9120c3d6699240d1ff2184AC8b3);
        coinsList["XRP"] = coin;

        //BAT
        coinInfo memory coin = coinInfo("BAT", 0x8e67A0CFfbbF6A346ce87DFe06daE2dc782b3219);
        coinsList["BAT"] = coin;
    }

    
    function doStuff() public {
        uint256 val =1;
        emit test(val,"pat");

    }
    
}
