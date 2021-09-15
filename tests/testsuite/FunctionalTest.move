//! new-transaction
//! account: alice
//! account: admin, 0x222
//! sender: admin
script {
    use 0x1::STC;
    use 0x222::NFTMarket;
    use 0x111::KikoCat01;

    fun init_buy_back_list(sender: signer) {
        NFTMarket::init_buy_back_list<KikoCat01::KikoCatMeta, KikoCat01::KikoCatBody, STC::STC>(&sender);
    }
}
// check: EXECUTED


//! new-transaction
//! sender: admin
script {
    use 0x1::STC;
    use 0x222::NFTMarket;
    use 0x111::KikoCat01;

    fun nft_buy_back(sender: signer) {
        NFTMarket::nft_buy_back<KikoCat01::KikoCatMeta, KikoCat01::KikoCatBody, STC::STC>(&sender, 12u64, 12u128);
    }
}
// check: EXECUTED


//! new-transaction
//! sender: alice
address alice = {{alice}};
script {
    use 0x1::STC;
    use 0x222::NFTMarket;
    use 0x111::KikoCat01;

    fun nft_buy_back_sell(sender: signer) {
        NFTMarket::nft_buy_back_sell<KikoCat01::KikoCatMeta, KikoCat01::KikoCatBody, STC::STC>(&sender, 12u64);
    }
}
// check: EXECUTED