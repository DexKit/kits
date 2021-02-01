
//SPDX-License-Identifier: Unlicense
pragma solidity ^0.7.0;

import "@0x/contracts-zero-ex/contracts/src/transformers/Transformer.sol";
import "@0x/contracts-erc20/contracts/src/v06/IEtherTokenV06.sol";
import "@0x/contracts-zero-ex/contracts/src/transformers/LibERC20Transformer.sol";

import "./interfaces/ILendingPool.sol";
import "./interfaces/IATokenV06.sol";

/// @dev A transformer that deposit or withdraw to Aave.
contract AaveConvertTransformer is Transformer
{
    using LibRichErrorsV06 for bytes;
    using LibSafeMathV06 for uint256;
    using LibERC20Transformer for IERC20TokenV06;

    /// @dev Transform data to ABI-encode and pass into `transform()`.
    struct TransformData {
        // When deposit, this is the underlying asset, when withdrawing is the Atoken
        IATokenV06 token;
        // Amount of `token` convert
        // `uint(-1)` will convert the entire balance.
        uint256 amount;
        // if deposit true we mint Atokens, if false we burn it 
        bool isDeposit;
    }

    ILendingPool public immutable lendingPool;

    /// @dev Maximum uint256 value.
    uint256 private constant MAX_UINT256 = uint256(-1);

    /// @dev Construct the transformer and store the LendingPool address in an immutable.
    /// @param lendingPool_ The Aave lending pool smartcontract
    constructor(ILendingPool lendingPool_)
        public
        Transformer()
    {
        lendingPool = lendingPool_;
    }

    /// @dev Deposit or Withdraw on Aave Lending Pool.
    /// @param context Context information.
    /// @return success The success bytes (`LibERC20Transformer.TRANSFORMER_SUCCESS`).
    function transform(TransformContext calldata context)
        external
        override
        returns (bytes4 success)
    {
        TransformData memory data = abi.decode(context.data, (TransformData));
        if (data.token.isTokenETH()) {
            LibTransformERC20RichErrors.InvalidTransformDataError(
                LibTransformERC20RichErrors.InvalidTransformDataErrorCode.INVALID_TOKENS,
                context.data
            ).rrevert();
        }

        uint256 amount = data.amount;
        if (amount == MAX_UINT256) {
            amount = data.token.getTokenBalanceOf(address(this));
        }

        data.token.approveIfBelow(lendingPool, amount);
        if(amount !=0 ){
            // If is no deposit we withdraw
            if(data.isDeposit){
                lendingPool.deposit(address(data.token), amount, context.taker, 0);
            }else{
                address underlyingAsset = data.token.UNDERLYING_ASSET_ADDRESS();
                lendingPool.withdraw(underlyingAsset, amount, context.taker, 0);
            }
        }
       

        return LibERC20Transformer.TRANSFORMER_SUCCESS;
    }
}
