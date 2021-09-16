address 0x333 {
module NFTScripts {

    use 0x222::NFTMarket;

    // NFT sell
    public(script) fun nft_sell<NFTMeta: copy + store + drop, NFTBody: store, PayToken: store>(
        account: &signer,
        id: u64,
        selling_price: u128
    ){
        NFTMarket::nft_sell<NFTMeta,NFTBody,PayToken>(account,id,selling_price);
    }

    // NFT bid
    public(script) fun nft_bid<NFTMeta: copy + store + drop, NFTBody: store, PayToken: store>(
        account: &signer,
        id: u64,
        price: u128
    ){
        NFTMarket::nft_bid<NFTMeta,NFTBody,PayToken>(account,id,price);
    }

    // NFT accept bid
    public(script) fun nft_accept_bid<NFTMeta: copy + store + drop, NFTBody: store, PayToken: store>(
        account: &signer,
        id: u64
    ){
        NFTMarket::nft_accept_bid<NFTMeta,NFTBody,PayToken>(account,id);
    }

    // NFT buy
    public(script) fun nft_buy<NFTMeta: copy + store + drop, NFTBody: store, PayToken: store>(
        account: &signer,
        id: u64
    ){
        NFTMarket::nft_buy<NFTMeta,NFTBody,PayToken>(account,id);
    }

    //box sell
    public(script) fun box_sell<BoxToken: store, PayToken: store>(
        seller: &signer,
        sell_price: u128
    ) {
        NFTMarket::box_sell<BoxToken, PayToken>(seller, sell_price);
    }

    //box accept offer price
    public(script) fun box_accept_bid<BoxToken: store, PayToken: store>(
        seller: &signer,
        id: u128
    ){
        NFTMarket::box_accept_bid<BoxToken, PayToken>(seller, id);
    }

    //box offer price
    public(script) fun box_bid<BoxToken: store, PayToken: store>(
        buyer: &signer,
        id: u128,
        offer_price: u128
    ){
        NFTMarket::box_bid<BoxToken, PayToken>(buyer, id, offer_price);
    }

    //box buy
    public(script) fun box_buy<BoxToken: store, PayToken: store>(
        buyer: &signer,
        id: u128
    ){
        NFTMarket::box_buy<BoxToken, PayToken>(buyer, id);
    }

    public(script) fun init_buy_back_list<NFTMeta: store + drop, NFTBody: store, PayToken: store>(sender: signer) {
        NFTMarket::init_buy_back_list<NFTMeta, NFTBody, PayToken>(&sender);
    }

    public(script) fun nft_buy_back<NFTMeta: store + drop, NFTBody: store, PayToken: store>(sender: signer, id: u64, amount: u128) {
        NFTMarket::nft_buy_back<NFTMeta, NFTBody, PayToken>(&sender, id, amount);
    }

    public(script) fun nft_buy_back_sell<NFTMeta: copy + store + drop, NFTBody: store, PayToken: store>(sender: signer, id: u64) {
        NFTMarket::nft_buy_back_sell<NFTMeta, NFTBody, PayToken>(&sender, id);
    }

}
}