// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test,console2} from "forge-std/Test.sol";
import {TSwapPool} from "../../src/TSwapPool.sol";
import {ERC20Mock} from "../mocks/ERC20Mock.sol";

contract Handler is Test{
    TSwapPool pool;
    ERC20Mock weth;
    ERC20Mock poolToken;

    int256 startingY;
    int256 startingX;
    int256 public expectedDeltY;
    int256 public expectedDeltaX;

    address liquidityProvider=makeAddr('lp');
    address swaper=makeAddr('swaper');
    int256 public actualDeltaY;
    int256 public actualDeltaX;

    constructor(TSwapPool _pool){
        pool=_pool;
        weth=ERC20Mock(_pool.getWeth());
        poolToken=ERC20Mock(_pool.getPoolToken());
    }

    function swapPoolTokenForWethBasedOnOutputWeth(uint256 outputWeth) public{

        //Here our output token is weth i am thinking
        outputWeth=bound(outputWeth,pool.getMinimumWethDepositAmount(),weth.balanceOf(address(pool)));

        if(outputWeth >= weth.balanceOf(address(pool))){
            return ;
        }

        uint256 poolTokenAmount=pool.getInputAmountBasedOnOutput(outputWeth,poolToken.balanceOf(address(pool)),weth.balanceOf(address(pool)));
        if(poolTokenAmount > type(uint64).max){
            return ;
        }

        startingY=int256(weth.balanceOf(address(pool)));
        startingX=int256(poolToken.balanceOf(address(pool)));

        expectedDeltY=int256(-1)*int256(outputWeth); // 
expectedDeltaX = int256(pool.getPoolTokensToDepositBasedOnWeth(uint256(expectedDeltY)));

        if(poolToken.balanceOf(swaper) < poolTokenAmount){
            poolToken.mint(swaper,poolTokenAmount-poolToken.balanceOf(swaper)+1);
        }

        vm.startPrank(swaper);
        poolToken.approve(address(pool),type(uint256).max);
        pool.swapExactOutput(poolToken,weth,outputWeth,uint64(block.timestamp));
        vm.stopPrank();

        uint256 endingY=weth.balanceOf(address(pool));
        uint256 endingX=poolToken.balanceOf(address(pool));

        actualDeltaY=int256(endingY)-int256(startingY);
        actualDeltaX=int256(endingX)-int256(startingX);
    }

    function deposite(uint256 wethAmount) public {
        uint256 wethMinAmount=pool.getMinimumWethDepositAmount();
        wethAmount=bound(wethAmount,wethMinAmount,type(uint64).max);

        startingY=int256(weth.balanceOf(address(pool)));
        startingX=int256(poolToken.balanceOf(address(pool)));

        expectedDeltY=int256(wethAmount);
        expectedDeltaX=int256(pool.getPoolTokensToDepositBasedOnWeth(wethAmount)); //it will expected ratio

        vm.startPrank(liquidityProvider);
        weth.mint(liquidityProvider,wethAmount);
        poolToken.mint(liquidityProvider,uint256(expectedDeltaX));
        weth.approve(address(pool),type(uint256).max);
        poolToken.approve(address(pool),type(uint256).max);
        pool.deposit(wethAmount,wethMinAmount,uint256(expectedDeltaX),uint64(block.timestamp));
        vm.stopPrank();

        uint256 endingY=weth.balanceOf(address(pool));
        uint256 endingX=poolToken.balanceOf(address(pool));

        actualDeltaY=int256(endingY)-int256(startingY);
        actualDeltaX=int256(endingX)-int256(startingX);
    }


}