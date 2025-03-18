// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol" ;
import {ERC20Mock} from "../mocks/ERC20Mock.sol";
import {PoolFactory} from "../../src/PoolFactory.sol";
import {TSwapPool} from "../../src/TSwapPool.sol";

contract Invariant is StdInvariant, Test{
    // These pools have 2 assets as per the readme,.md , which means lets sat any ERC20 tokens and WETH tokens go and chenck in 
    //You can think of each `TSwapPool` contract as it's own exchange between exactly 2 assets. Any ERC20 and the [WETH]
    ERC20Mock poolToken; // it could be a Any ERC20 token
    ERC20Mock weth;

    //We need 2 contracts 
    PoolFactory factory;
    TSwapPool pool;

    uint256 constant STARTING_X=100e18;
    uint256 constant STARTING_Y=50e18;

    function setUp() public{
        weth=new ERC20Mock();
        poolToken=new ERC20Mock();
        factory = new PoolFactory(address(weth));
        //if we want create pool we have to call createPool function from PoolFactory contract lets call
        //ERC20 any token we should pass here.
        pool=TSwapPool(factory.createPool(address(poolToken)));
        
        poolToken.mint(address(this),STARTING_X); // Here ERC20Mock will take amount into uint256 format only for minting 
        weth.mint(address(this),STARTING_Y);

    }
}
