// SPDX-License-Identifier: CC-BY-SA-4.0

// Version of Solidity compiler this program was written for

pragma solidity ^0.8.0;

import "./LinkedList.sol";
import "./coinInfo.sol";


contract CryptoCFD {
    
    event test(uint256 node_id, string name);

    mapping(string => coinInfo) coinsList; //mapping form coin index (for example bitcoin = 1 )
    
    constructor() public{
        //BTC
        coinInfo coin = new coinInfo("BTC", 0x6135b13325bfC4B00278B4abC5e20bbce2D6580e);
        coinsList["BTC"] = coin;

        //XRP
        coinInfo coin2 = new coinInfo("XRP", 0x3eA2b7e3ed9EA9120c3d6699240d1ff2184AC8b3);
        coinsList["XRP"] = coin2;

        //BAT
        coinInfo coin3 = new coinInfo("BAT", 0x8e67A0CFfbbF6A346ce87DFe06daE2dc782b3219);
        coinsList["BAT"] = coin3;
    }

    
    function doStuff() public {
        uint256 val =1;
        string memory name = coinsList["XRP"].getName();
        emit test(val, name);

    }
    
}
