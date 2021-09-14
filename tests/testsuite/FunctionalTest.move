//! new-transaction
//! account: alice
//! sender: alice
address alice = {{alice}};
script {
    use 0x1::Account;
    use 0x1::Debug;
    use 0x1::STC;
    use 0x222::NFTMarket;
    // use 0x111::KikoCat01;

    fun swap_exact_token_for_token(sender: signer) {
        let addr = NFTMarket::test(&sender);
        Debug::print<address>(&addr);
        // NFTMarket::nft_buy_back<KikoCat01::KikoCatMeta, KikoCat01::KikoCatBody, STC::STC>(&sender, 12u64, 12u128);

        // Dummy::mint_token<ETH>(&sender, 1 * MULTIPLE);
        // // swap 1 ETH
        // SwapScripts::swap_exact_token_for_token<ETH, USDT>(sender, 1*MULTIPLE , 3*MULTIPLE);
        // // get 3.324995831 USDT
        let balance_usdt = Account::balance<STC::STC>(@alice);
        Debug::print<u128>(&balance_usdt);
        // assert(balance_usdt == 3324995831, 5001);
        // // STC = 6, USDT = 16.675004169
        // let (reserve_x, reserve_y) = SwapPair::get_reserves<ETH, USDT>();
        // assert(reserve_x == 6000000000 && reserve_y == 16675004169, 5001);
    }
}
// check: EXECUTED