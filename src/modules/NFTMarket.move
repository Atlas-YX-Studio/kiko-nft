address 0x222 {
module NFTMarket {

    use 0x1::Event;
    use 0x1::Errors;
    use 0x1::Account;
    use 0x1::Option::{Self,Option};
    use 0x1::Signer;
    use 0x1::Token;
    use 0x1::Vector;
    use 0x1::Timestamp;
    use 0x1::NFT::{Self,NFT};
    use 0x1::NFTGallery;

    const NFT_MARKET_ADDRESS: address = @0x222;

    //error
    const PERMISSION_DENIED: u64 = 200001;
    const OFFERING_NOT_EXISTS: u64 = 200002;
    const OFFERING_NOT_ON_SALE: u64 = 200003;
    const INSUFFICIENT_BALANCE: u64 = 200004;
    const ID_NOT_EXIST: u64 = 200005;
    const BID_FAILED : u64 = 200006;
    const NFTSELLINFO_NOT_EXISTS : u64 = 200007;


    // ******************** Initial Offering ********************
    // box initial offering struct
    struct BoxOffering<BoxToken: store, PayToken: store> has key, store {
        // box tokens
        box_tokens: Token::Token<BoxToken>,
        // selling price for PayToken
        selling_price: u128,
        // selling start time for box
        selling_time: u64,
        offering_events: Event::EventHandle<BoxOfferingEvent>,
        sell_events: Event::EventHandle<BoxOfferingSellEvent>,
    }

    // box initial offering event
    struct BoxOfferingEvent has drop, store {
        box_token_code: Token::TokenCode,
        pay_token_code: Token::TokenCode,
        // box quantity
        quantity: u128,
        // total price
        total_price: u128,
    }

    // box offering sell event
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

    // init market resource for different PayToken
    public fun init_market<NFTMeta: store + drop, NFTBody: store, BoxToken: store, PayToken: store>(sender: &signer) {
        let sender_address = Signer::address_of(sender);
        assert(sender_address == NFT_MARKET_ADDRESS, PERMISSION_DENIED);
        if (!exists<BoxSelling<BoxToken, PayToken>>(sender_address)) {
            move_to(sender, BoxSelling<BoxToken, PayToken> {
                items: Vector::empty(),
                bid_events: Event::new_event_handle<BoxBidEvent>(sender),
                sell_events: Event::new_event_handle<BoxSellEvent>(sender),
            });
        };
        if (!exists<NFTSelling<NFTMeta, NFTBody, PayToken>>(sender_address)) {
            move_to(sender, NFTSelling<NFTMeta, NFTBody, PayToken> {
                items: Vector::empty(),
                bid_events: Event::new_event_handle<NFTBidEvent<NFTMeta>>(sender),
                sell_events: Event::new_event_handle<NFTSellEvent<NFTMeta>>(sender),
            });
        };
    }

    // box initial offering
    public fun box_initial_offering<NFTMeta: store + drop, NFTBody: store, BoxToken: store, PayToken: store>(
        sender: &signer,
        box_amount: u128,
        selling_price: u128,
        selling_time: u64,
    ) acquires BoxOffering {
        let sender_address = Signer::address_of(sender);
        assert(sender_address == NFT_MARKET_ADDRESS, PERMISSION_DENIED);
        // check exists
        if (!exists<BoxOffering<BoxToken, PayToken>>(sender_address)) {
            move_to(sender, BoxOffering<BoxToken, PayToken> {
                box_tokens: Token::zero(),
                selling_price,
                selling_time,
                offering_events: Event::new_event_handle<BoxOfferingEvent>(sender),
                sell_events: Event::new_event_handle<BoxOfferingSellEvent>(sender),
            });
        };
        let offering = borrow_global_mut<BoxOffering<BoxToken, PayToken>>(sender_address);
        // transfer box to offering pool
        assert(Account::balance<PayToken>(sender_address) >= selling_price, INSUFFICIENT_BALANCE);
        let box_tokens = Account::withdraw<BoxToken>(sender, box_amount);
        Token::deposit<BoxToken>(&mut offering.box_tokens, box_tokens);
        // init other market
        init_market<NFTMeta, NFTBody, BoxToken, PayToken>(sender);
    }

    // buy box from offering
    public fun box_buy_from_offering<BoxToken: store, PayToken: store>(sender: &signer, quantity: u128)
    acquires BoxOffering {
        assert(exists<BoxOffering<BoxToken, PayToken>>(NFT_MARKET_ADDRESS), OFFERING_NOT_EXISTS);
        let offering = borrow_global_mut<BoxOffering<BoxToken, PayToken>>(NFT_MARKET_ADDRESS);
        assert(Timestamp::now_milliseconds() >= offering.selling_time, OFFERING_NOT_ON_SALE);
        let sender_address = Signer::address_of(sender);
        // transfer PayToken to platform
        let total_price = offering.selling_price * quantity;
        assert(Account::balance<PayToken>(sender_address) >= total_price, INSUFFICIENT_BALANCE);
        Account::pay_from<PayToken>(sender, NFT_MARKET_ADDRESS, total_price);
        // transfer box to buyer
        let box_tokens = Token::withdraw<BoxToken>(&mut offering.box_tokens, quantity);
        Account::deposit_to_self(sender, box_tokens);
        // emit event
        Event::emit_event(
            &mut offering.sell_events,
            BoxOfferingSellEvent {
                box_token_code: Token::token_code<BoxToken>(),
                pay_token_code: Token::token_code<PayToken>(),
                quantity,
                total_price,
                buyer: sender_address,
            }
        );
    }

    // ******************** Box Transaction ********************
    // box selling list
    struct BoxSelling<BoxToken: store, PayToken: store> has key, store {
        // selling list
        items: vector<BoxSellInfo<BoxToken, PayToken>>,
        sell_events: Event::EventHandle<BoxSellEvent>,
        bid_events: Event::EventHandle<BoxBidEvent>,
    }

    // box extra sell info
    struct BoxSellInfo<BoxToken: store, PayToken: store> has store {
        seller: address,
        // box tokens for selling
        box_tokens: Token::Token<BoxToken>,
        // selling price
        selling_price: u128,
        // top price bid tokens
        bid_tokens: Token::Token<PayToken>,
        // buyer address
        bider: address,
    }

    // box bid event
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

    // box sell event
    struct BoxSellEvent has drop, store {
        // seller address
        seller: address,
        box_token_code: Token::TokenCode,
        pay_token_code: Token::TokenCode,
        // box quantity
        quantity: u128,
        // selling price
        selling_price: u128,
        // final price
        final_price: u128,
        // buyer address
        buyer: address,
    }

    //Blind box On sale
    public fun box_sell() {}

    // Blind box Accept the offer
    public fun box_accept_bid() {}

    // Blind box bid
    public fun box_bid() {}

    // Blind box buy
    public fun box_buy() {}

    // ******************** NFT Transaction ********************
    // NFT selling list
    struct NFTSelling<NFTMeta: store + drop, NFTBody: store, PayToken: store> has key, store {
        // nft selling list
        items: vector<NFTSellInfo<NFTMeta, NFTBody, PayToken>>,
        bid_events: Event::EventHandle<NFTBidEvent<NFTMeta>>,
        sell_events: Event::EventHandle<NFTSellEvent<NFTMeta>>,
    }

    // NFT extra sell info
    struct NFTSellInfo<NFTMeta: store, NFTBody: store, PayToken: store> has store {
        seller: address,
        // nft item
        nft: Option<NFT<NFTMeta, NFTBody>>,
        // nft id
        id: u64,
        // selling price
        selling_price: u128,
        // top price bid tokens
        bid_tokens: Token::Token<PayToken>,
        // buyer address
        bider: address,
    }

    // NFT bid event
    struct NFTBidEvent<NFTMeta: store + drop> has drop, store {
        seller: address,
        id: u64,
        pay_token_code: Token::TokenCode,
        selling_price: u128,
        bid_price: u128,
        bider: address,
    }

    // NFT sell event
    struct NFTSellEvent<NFTMeta: store + drop> has drop, store {
        seller: address,
        id: u64,
        pay_token_code: Token::TokenCode,
        final_price: u128,
        buyer: address,
    }

    // NFT sell
    public fun nft_sell<NFTMeta: copy + store + drop, NFTBody: store, PayToken: store>(
        account: &signer,
        id: u64,
        selling_price: u128
    )acquires NFTSelling{
        let nft_selling = borrow_global_mut<NFTSelling<NFTMeta, NFTBody, PayToken>>(NFT_MARKET_ADDRESS);
        // NFTSelling exists
        assert(exists<NFTSelling<NFTMeta, NFTBody, PayToken>>(NFT_MARKET_ADDRESS), Errors::invalid_argument(OFFERING_NOT_EXISTS));
        let owner_address = Signer::address_of(account);
        // Withdraw one NFT token from your account
        let option_nft = NFTGallery::withdraw<NFTMeta,NFTBody>(account,id);
        let nft_sell_info = NFTSellInfo<NFTMeta, NFTBody, PayToken> {
            seller: owner_address,
            nft: option_nft,
            id: id,
            selling_price: selling_price,
            bid_tokens: Token::zero<PayToken>(),
            bider: @0x1,
        };
        // nft_sell_info add Vector
        Vector::push_back(&mut nft_selling.items, nft_sell_info);
    }

    // NFT bid
    public fun nft_bid<NFTMeta: copy + store + drop, NFTBody: store, PayToken: store>(
        account: &signer,
        id: u64, price: u128
    )acquires NFTSelling{
        let nft_token = borrow_global_mut<NFTSelling<NFTMeta, NFTBody, PayToken>>(NFT_MARKET_ADDRESS);
        let nftSellInfo = find_ntf_sell_info_by_id<NFTMeta,NFTBody,PayToken>(&mut nft_token.items,id);
        //bider address
        let user_address = Signer::address_of(account);
        if(price >= nftSellInfo.selling_price){
            nft_buy<NFTMeta, NFTBody, PayToken>(account,id);
        }else{
            // get bid token quantity
            let bid_tokens = Token::value(&nftSellInfo.bid_tokens);
            if(bid_tokens > 0){
                assert(price > bid_tokens, Errors::invalid_argument(BID_FAILED));
                // pool deduct token
                let pool_tokens = Token::withdraw<PayToken>(&mut nftSellInfo.bid_tokens, bid_tokens);
                // pay
                Account::deposit<PayToken>(nftSellInfo.bider, pool_tokens);
            };
            // Deduct deduction from my account PayToken
            let me_tokens = Account::withdraw<PayToken>(account, price);
            // Go to the pool
            Token::deposit(&mut nftSellInfo.bid_tokens, me_tokens);
            nftSellInfo.bider = user_address;
            // accept
            NFTGallery::accept<NFTMeta,NFTBody>(account);
            //send NFTBidEvent event
            Event::emit_event<NFTBidEvent<NFTMeta>>(&mut nft_token.bid_events,
                NFTBidEvent {
                    seller: nftSellInfo.seller,
                    id: id,
                    pay_token_code: Token::token_code<PayToken>(),
                    selling_price: nftSellInfo.selling_price,
                    bid_price: price,
                    bider: user_address,
                }
            );
        };
    }

    // NFT accept bid
    public fun nft_accept_bid<NFTMeta: copy + store + drop, NFTBody: store, PayToken: store>(
        account: &signer,
        id: u64
    ) acquires NFTSelling{
        let user_address = Signer::address_of(account);
        let nft_token = borrow_global_mut<NFTSelling<NFTMeta, NFTBody, PayToken>>(NFT_MARKET_ADDRESS);
        let nftSellInfo = find_ntf_sell_info_by_id<NFTMeta,NFTBody,PayToken>(&mut nft_token.items,id);
        let bid_tokens = Token::value(&nftSellInfo.bid_tokens);
        let nft = Option::extract(&mut nftSellInfo.nft);

        // nft ransfer to bider
        NFTGallery::deposit_to<NFTMeta,NFTBody>(nftSellInfo.bider,nft);

        //quchu
        let bid_token = Token::withdraw<PayToken>(&mut nftSellInfo.bid_tokens, bid_tokens);
        Account::deposit<PayToken>(user_address, bid_token);

        Event::emit_event<NFTSellEvent<NFTMeta>>(&mut nft_token.sell_events,
            NFTSellEvent {
                seller: nftSellInfo.seller,
                id: nftSellInfo.id,
                pay_token_code: Token::token_code<PayToken>(),
                final_price: bid_tokens,
                buyer: user_address,
            },
        );
    }
    // NFT buy
    public fun nft_buy<NFTMeta: copy + store + drop, NFTBody: store, PayToken: store>(
        account: &signer,
        id: u64
    ) acquires NFTSelling{
        let user_address = Signer::address_of(account);
        let nft_token = borrow_global_mut<NFTSelling<NFTMeta , NFTBody, PayToken>>(NFT_MARKET_ADDRESS);
        let nftSellInfo = find_ntf_sell_info_by_id<NFTMeta,NFTBody,PayToken>(&mut nft_token.items,id);
        let token_balance = Account::balance<PayToken>(user_address);
        let selling_price = nftSellInfo.selling_price;
        assert(token_balance >= selling_price, Errors::invalid_argument(INSUFFICIENT_BALANCE));
        Account::pay_from<PayToken>(account,nftSellInfo.seller,selling_price);
        // accept
        NFTGallery::accept<NFTMeta,NFTBody>(account);
        let nft = Option::extract(&mut nftSellInfo.nft);
        // nft transer Own
        NFTGallery::deposit<NFTMeta,NFTBody>(account,nft);

        //send NFTSellEvent event
        Event::emit_event<NFTSellEvent<NFTMeta>>(&mut nft_token.sell_events,
            NFTSellEvent {
                seller: nftSellInfo.seller,
                id: nftSellInfo.id,
                pay_token_code: Token::token_code<PayToken>(),
                final_price: selling_price,
                buyer: user_address,
            },
        );
    }

    //get nft_sell_info by id
    fun find_ntf_sell_info_by_id<NFTMeta: copy + store + drop, NFTBody: store,PayToken: store>(
        c: &mut vector<NFTSellInfo<NFTMeta, NFTBody, PayToken>>,
        id: u64): NFTSellInfo<NFTMeta, NFTBody, PayToken> {
        let len = Vector::length(c);
        assert(len > 0, Errors::invalid_argument(ID_NOT_EXIST));
        let i = len - 1;
        loop {
            // NFTSellInfo<NFTMeta, NFTBody, PayToken>
            let nftSellInfo = Vector::borrow(c, i);
            let nft = Option::borrow(&nftSellInfo.nft);
            if (NFT::get_id(nft) == id) {
                return Vector::remove(c,i)
            };
            assert(i > 0, Errors::invalid_argument(ID_NOT_EXIST));
            i = i - 1;
        }
    }

    // ******************** Platform Buyback ********************
    // NFT buy back list
    struct NFTBuyBack<NFTMeta: store, NFTBody: store, PayToken: store> has key, store {
        // nft buying list
        items: vector<NFTBuyBackInfo<NFTMeta, NFTBody, PayToken>>,
        sell_events: Event::EventHandle<NFTBuyBackSellEvent<NFTMeta>>,
    }

    // NFT Commodity information, used to encapsulate NFT
    struct NFTBuyBackInfo<NFTMeta: store, NFTBody: store, PayToken: store> has store {
        id: u64,
        pay_tokens: Token::Token<PayToken>,
    }

    // NFT repurchase sale event
    struct NFTBuyBackSellEvent<NFTMeta: store> has drop, store {
        seller: address,
        id: u64,
        pay_token_code: Token::TokenCode,
        final_price: u128,
        buyer: address,
    }

    //NFT repurchase
    public fun nft_buy_back() {}

    // NFT repurchase and sale
    public fun nft_buy_back_sell() {}
}
}