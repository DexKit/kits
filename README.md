# KITS (WORK IN PROGRESS)

<img src="https://github.com/DexKit/assets/blob/main/images/kits.png" width="100%" >

## This is work in  progress

Kits aka 0x transformers can perform multiple actions on decentralized finance without a need of an smartcontract wallet. All this using the best liquidity on the market



# TODO

Docs for each KIT under [docs](./docs)

## Proposed KITS:

- [ ] Uniswap Wrap to Pool KIT - Enables trader to swap from a single side asset to a uni lp pool. for instance, having only eth, user can swap half for dai and enter on Uni LP ETH-DAI position
- [ ] Sushi Pool KIT - Same as above but for Sushi
- [ ] Uniswap unWrap to Pool KIT - Enables trader to swap uni lp pool to a single side asset. For instance, having only uni lp pool ETH-DAI, user can wrap and swap DAI for ETH
- [ ] Sushi Pool KIT - Same as above but for Sushi
- [ ] Aave/Compound/etc KIT - Enables trader to receive token in Aave/Compound/etc colateral. For instance, swap ETH for DAI and convert to aDai in same process
- [ ] Aave/Compound/etc to Aave/Compound KIT - Enables trader to swap between colaterals token. For instance, swap cUSDC for aDai

## Documentation

- [ ] Investigate dynamic fields to be used as form on frontend
- [ ] tutorials how to use transformers

## Tooling

- [ ] Add library to make it easy to use transformers on frontend


# References

[Example of usage](https://github.com/0xProject/0x-monorepo/blob/development/packages/asset-swapper/src/quote_consumers/exchange_proxy_swap_quote_consumer.ts)

[Transformers Discussion](https://forum.0x.org/t/transformers-usecases/624/2)

[Transformers codebase](https://github.com/0xProject/protocol/tree/development/contracts/zero-ex/contracts/src/transformers)