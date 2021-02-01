
//SPDX-License-Identifier: Unlicense
pragma solidity ^0.7.0;

import "@0x/contracts-zero-ex/contracts/src/transformers/Transformer.sol";
import "@0x/contracts-erc20/contracts/src/v06/IEtherTokenV06.sol";
import "@0x/contracts-utils/contracts/src/v06/LibSafeMathV06.sol";
import "@0x/contracts-zero-ex/contracts/src/transformers/LibERC20Transformer.sol";

import "./interfaces/IUniswapV2Router02.sol";
/// @dev A transformer that deposit or withdraw liquidity to Uniswap. Wrap ETH using ETH transformer before, if using ETH
contract UniswapPoolTransformer is Transformer
{
    using LibRichErrorsV06 for bytes;
    using LibSafeMathV06 for uint256;
    using LibERC20Transformer for IERC20TokenV06;

    /// @dev Transform data to ABI-encode and pass into `transform()`.
    struct TransformData {
        // The tokenA
        IERC20TokenV06 tokenA;
        // Amount of `tokenA` to add liquidity.
        // `uint(-1)` will add entire balance.
        uint256 amountA;

        // The tokenB
        IERC20TokenV06 tokenB;
        // Amount of `tokenB` to add liquidity.
        // `uint(-1)` will add entire balance.
        uint256 amountB;

        uint256 liquidity;
    }

    /// @dev Maximum uint256 value.
    uint256 private constant MAX_UINT256 = uint256(-1);

    IUniswapV2Router02 public immutable uniRouter;

    /// @dev
    constructor(IUniswapV2Router02 uniRouter_)
        public
        Transformer()
    {
        uniRouter = uniRouter_;
    }

    /// @dev Deposit or Withdraw Liquidity to Uniswap Pool
    /// @param context Context information.
    /// @return success The success bytes (`LibERC20Transformer.TRANSFORMER_SUCCESS`).
    function transform(TransformContext calldata context)
        external
        override
        returns (bytes4 success)
    {
        TransformData memory data = abi.decode(context.data, (TransformData));
        if (data.tokenA.isTokenETH() || data.tokenB.isTokenETH()) {
            LibTransformERC20RichErrors.InvalidTransformDataError(
                LibTransformERC20RichErrors.InvalidTransformDataErrorCode.INVALID_TOKENS,
                context.data
            ).rrevert();
        }
        uint256 liquidiy = data.liquidity;

        uint256 amountA = data.amountA;
        if (amountA == MAX_UINT256) {
            amountA = data.tokenA.getTokenBalanceOf(address(this));
        }
        uint256 amountB = data.amountB;
        if (amountB == MAX_UINT256) {
            amountB = data.tokenB.getTokenBalanceOf(address(this));
        }
        // Give allowance to router
        data.tokenA.approveIfBelow(uniRouter, amountA);
        data.tokenB.approveIfBelow(uniRouter, amountB);


        // 1% tolerance
        uint256 amountAmin = amountA.safeSub(amountA.safeMul(100).safeDiv(10000));
        uint256 amountBmin = amountB.safeSub(amountB.safeMul(100).safeDiv(10000));
        // if liquidity is set we want to remove liquidity
        if (amountA != 0 && amountB !=0 && liquidity == 0) {
            uniRouter.addLiquidity(
                address(data.tokenA),
                address(data.tokenB),
                amountA,
                amountB,
                amountAmin,
                amountBmin,
                context.taker,
                block.timestamp+100
            );
        }
        // We set the liquidity parameter if we want to remove liquidity
        if (amountA != 0 && amountB !=0 && liquidity != 0) {
            uniRouter.removeLiquidity(
                address(data.tokenA), 
                address(data.tokenB), 
                liquidity, 
                amountA,
                amountB,
                context.taker,
                block.timestamp+100
            );
        }



        return LibERC20Transformer.TRANSFORMER_SUCCESS;
    }
}
