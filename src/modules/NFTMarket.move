address 0x222 {
module NFTMarket {

    // ******************** Initial Offering ********************
    // 盲盒首发列表
    struct BoxInitialOffering<BoxToken: store, PayToken: store> has key, store {
        // box tokens
        box_tokens: Token::Token<BoxToken>,
        // selling price for PayToken
        selling_price: u128,
        offering_events: Event::EventHandle<BoxOfferingEvent>,
        sell_events: Event::EventHandle<BoxOfferingSellEvent>,
    }

    // 盲盒首发事件
    struct BoxOfferingEvent has drop, store {
        box_token_code: Token::TokenCode,
        pay_token_code: Token::TokenCode,
        // box quantity
        quantity: u128,
        // total price
        total_price: u128,
    }

    // 盲盒首发卖出事件
    struct BoxOfferingSellEvent has drop, store {
        box_token_code: Token::TokenCode,
        pay_token_code: Token::TokenCode,
        // box quantity
        quantity: u128,
        // total price
        total_price: u128,
        // buyer address
        buyer: address,
    }

    // 盲盒首发
    public fun box_initial_offering() {

    }

    // ******************** Box Transaction ********************
    // 盲盒出售列表
    struct BoxSelling<BoxToken: store, PayToken: store> has key, store {
        // selling list
        items: vector<BoxSellInfo<BoxToken, PayToken>>,
        bid_events: Event::EventHandle<BoxBidEvent>,
        sell_events: Event::EventHandle<BoxSellEvent>,
    }

    // 盲盒商品信息，用于封装盲盒token
    struct BoxSellInfo<BoxToken: store, PayToken: store> has store, drop {
        seller: address,
        // box tokens for selling
        box_tokens: Token::Token<BoxToken>,
        // selling price
        selling_price: u128,
        // buyer address
        buyer: address,
        // top price tokens
        top_tokens: Token::Token<PayToken>,
    }

    // 盲盒出价事件
    struct BoxBidEvent has drop, store {
        // seller address
        seller: address,
        box_token_code: Token::TokenCode,
        pay_token_code: Token::TokenCode,
        // selling price
        selling_price: u128,
        // bider address
        bider: address,
        // bid price, lower than selling price
        bid_price: u128,
    }

    // 盲盒卖出事件
    struct BoxSellEvent has drop, store {
        // seller address
        seller: address,
        box_token_code: Token::TokenCode,
        pay_token_code: Token::TokenCode,
        // box quantity
        quantity: u128,
        // selling price
        selling_price: u128,
        // buyer address
        buyer: address,
        // final price
        final_price: u128,
    }

    // 盲盒发售
    public fun box_sell() {

    }

    // 盲盒出价
    public fun box_bid() {

    }

    // 盲盒接受报价
    public fun box_accept_bid() {

    }

    // 盲盒购买
    public fun box_buy() {

    }

    // ******************** NFT Transaction ********************
    // NFT出售列表
    struct NFTSelling<NFTMeta: store, NFTBody: store, PayToken: store> has key, store {
        // nft selling list
        items: vector<NFTSellInfo<NFTMeta, NFTBody, PayToken>>,
        sell_events: Event::EventHandle<NFTSellEvent<NFTMeta>>,
    }

    // NFT商品信息，用于封装NFT
    struct NFTSellInfo<NFTMeta: store, NFTBody: store, PayToken: store> has store, drop {
        // nft item
        nft: NFT<NFTMeta, NFTBody>,
        // nft id
        id: u64,
        // selling price
        selling_price: u128,
        // top price tokens
        top_tokens: Token::Token<PayToken>,
        // buyer address
        buyer: address,
        bid_events: Event::EventHandle<NFTSellEvent<NFTMeta>>,
    }

    // NFT出价事件
    struct NFTBidEvent<NFTMeta:store> has drop, store {
        seller: address,
        id: u64,
        pay_token_code: Token::TokenCode,
        selling_price: u128,
        bid_price: u128,
        bider: address,
    }

    // NFT卖出事件
    struct NFTSellEvent<NFTMeta:store> has drop, store {
        seller: address,
        id: u64,
        pay_token_code: Token::TokenCode,
        final_price: u128,
        buyer: address,
    }

    // NFT发售
    public fun nft_sell() {

    }

    // NFT出价
    public fun nft_bid() {

    }

    // NFT接受报价
    public fun nft_accept_bid() {

    }

    // NFT购买
    public fun nft_buy() {

    }

    // ******************** Platform Buyback ********************
    // NFT回购列表
    struct NFTBuyBack<NFTMeta: store, NFTBody: store, PayToken: store> has key, store {
        // nft buying list
        items: vector<NFTBuyInfo<NFTMeta, NFTBody, PayToken>>,
        sell_events: Event::EventHandle<NFTBuyBackSellEvent<NFTMeta>>,
    }

    // NFT商品信息，用于封装NFT
    struct NFTBuyBackInfo<NFTMeta: store, NFTBody: store, PayToken: store> has store, drop {
        id: u64,
        pay_tokens: Token::Token<PayToken>,
    }

    // NFT回购出售事件
    struct NFTBuyBackSellEvent<NFTMeta:store> has drop, store {
        seller: address,
        id: u64,
        pay_token_code: Token::TokenCode,
        final_price: u128,
        buyer: address,
    }

    // NFT回购
    public fun nft_buy_back() {

    }

    // NFT回购出售
    public fun nft_buy_back_sell() {

    }

}
}