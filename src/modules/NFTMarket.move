address 0x222 {
module NFTMarket {
    use 0x1::Token;

    use 0x1::Event;
    use 0x1::Errors;
    use 0x1::Account;
    use 0x1::Signer;
    use 0x1::Token;
    use 0x1::Vector;
    use 0x1::NFTGallery;

    const NFT_MARKET_ADDRESS: address = @0x222;

    //error
    const PERMISSION_DENIED: u64 = 200001;
    const OFFERING_NOT_EXISTS : u64 = 200002;
    const INSUFFICIENT_BALANCE: u64 = 200003;
    const ID_NOT_EXIST: u64 = 200004;
    const BOX_SELLING_NOT_EXIST: u64 = 200005;
    const BOX_SELLING_IS_EMPTY: u64 = 200006;
    const BOX_SELLING_PRICE_SMALL: u64 = 200007;


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
    public fun init_market<NFTMeta: store, NFTBody: store, BoxToken: store, PayToken: store>(sender: &signer) {
        let sender_address = Signer::address_of(sender);
        if (!exists<BoxSelling<BoxToken, PayToken>>(sender_address)) {
            move_to(sender, BoxSelling<BoxToken, PayToken> {
                items: Vector::empty<BoxSellInfo<BoxToken, PayToken>>,
                last_id: 0u128,
                sell_events: Event::new_event_handle<BoxSellEvent>(sender),
                bid_events: Event::new_event_handle<BoxBidEvent>(sender),
            });
        };
        if (!exists<NFTSelling<NFTMeta, NFTBody>>(sender_address)) {
            move_to(sender, NFTSelling<NFTMeta, NFTBody> {
                items: Vector::empty<NFTSellInfo<NFTMeta, NFTBody, PayToken>>,
                sell_events: Event::new_event_handle<NFTSellEvent>(sender),
                bid_events: Event::new_event_handle<NFTBidEvent>(sender),
            });
        };
    }

    // box initial offering
    public fun box_initial_offering<NFTMeta: store, NFTBody: store, BoxToken: store, PayToken: store>(
        sender: &signer,
        box_amount: u128,
        selling_price: u128,
        selling_time: u64,
    ) acquires BoxOffering {
        let sender_address = Signer::address_of(sender);
        assert(signer_address == NFT_MARKET_ADDRESS, PERMISSION_DENIED);
        // check exists
        if (!exists<BoxOffering<BoxToken, PayToken>>(sender_address)) {
            move_to(sender, BoxOffering {
                box_tokens,
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
        Token::deposit<BoxToken>(&offering.box_tokens, box_tokens);
        // init other market
        init_market<NFTMeta, NFTBody, BoxToken, PayToken>(sender);
    }

    // buy box from offering
    public fun box_buy_from_offering<BoxToken: store, PayToken: store>(sender: &signer, quantity: u128)
    acquires BoxOffering {
        assert(exists<BoxOffering<BoxToken, PayToken>>(NFT_MARKET_ADDRESS), OFFERING_NOT_EXISTS);
        let offering = borrow_global_mut<BoxOffering<BoxToken, PayToken>>(NFT_MARKET_ADDRESS);
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
            BoxOfferingSellEvent{
                box_token_code: Token::token_code<BoxToken>(),
                pay_token_code: Token::token_code<PayToken>(),
                quantity,
                total_price,
                buyer: sender_address,
            }
        );
    }

    // ******************** Box Transaction ********************
    // box sell listing
    struct BoxSelling<BoxToken: store, PayToken: store> has key, store {
        // selling list
        items: vector<BoxSellInfo<BoxToken, PayToken>>,
        last_id: u128,
        sell_events: Event::EventHandle<BoxSellEvent>,
        bid_events: Event::EventHandle<BoxBidEvent>,
    }

    // box sell info
    struct BoxSellInfo<BoxToken: store, PayToken: store> has store, drop, key {
        id: u128,
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

    // box offer price event
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

    // box sell
    public fun box_sell<BoxToken: store, PayToken: store>(seller: &signer, sell_price: u128) acquires BoxSelling {

        assert(exists<BoxSelling<BoxToken, PayToken>>(NFT_MARKET_ADDRESS), Errors::invalid_argument(BOX_SELLING_NOT_EXIST));

        let seller_address = Signer::address_of(seller);

        let box_sellings = borrow_global_mut<BoxSelling<BoxToken, PayToken>>(NFT_MARKET_ADDRESS);

        box_sellings.last_id = box_sellings.last_id + 1;

        let withdraw_box_token = Token::withdraw<BoxToken>(seller, 1);

        let new_box = BoxSellInfo<BoxToken, PayToken> {
            id: box_sellings.last_id,
            seller: seller_address,
            box_tokens: withdraw_box_token,
            selling_price: sell_price,
            bid_tokens: Token::zero<PayToken>(),
            bider: @0x1,
        };

        Vector::push_back(&mut box_sellings.items, new_box);

    }

    // box accept offer price
    public fun box_accept_bid<BoxToken: store, PayToken: store>(seller: &signer, id: u128) acquires BoxSelling {

        assert(exists<BoxSelling<BoxToken, PayToken>>(NFT_MARKET_ADDRESS), Errors::invalid_argument(BOX_SELLING_NOT_EXIST));

        let box_sellings = borrow_global_mut<BoxSelling<BoxToken, PayToken>>(NFT_MARKET_ADDRESS);
        let len = Vector::length(&box_sellings.items);
        assert(len > 0, Errors::invalid_argument(BOX_SELLING_IS_EMPTY));

        let seller_address = Signer::address_of(seller);

        let box_sell_info: &mut BoxSellInfo<BoxToken, PayToken>;
        let k = 0;
        while ( k < len){
            let box_item = Vector::borrow_mut(&box_sellings.items, k);
            if(box_item.id == id){
                box_sell_info = box_item;
                break;
            };
            k = k + 1;
        };
        let buyer_address = box_sell_info.bider;

        let withdraw_box_token = Token::withdraw<BoxToken>(&box_sell_info.box_tokens, 1);
        Account::deposit(buyer_address, withdraw_box_token);

        let bid_amount = Token::value<PayToken>(&box_sell_info.bid_tokens);
        let withdraw_bid_token = Token::withdraw<PayToken>(&box_sell_info.bid_tokens, bid_amount);
        Account::deposit(seller_address, withdraw_bid_token);

        let remove_box_sell_info = Vector::remove<BoxSellInfo<BoxToken, PayToken>>(&mut &box_sellings.items, k);

        let BoxSellInfo<BoxToken, PayToken>  {
            id:_,
            seller: _,
            box_tokens,
            selling_price: _,
            bid_tokens,
            bider: _,
        } = remove_box_sell_info;

        Event::emit_event(
            &box_sellings.bid_events,
            BoxBidEvent{
                seller: box_sell_info.seller,
                box_token_code: Token::token_code<BoxToken>(),
                pay_token_code: Token::token_code<PayToken>(),
                selling_price: box_sell_info.selling_price,
                bider: seller_address,
                bid_price: offer_price,
            }
        );
        Event::emit_event(
            &box_sellings.sell_events,
            BoxSellEvent{
                seller: box_sell_info.seller,
                box_token_code: Token::token_code<BoxToken>(),
                pay_token_code: Token::token_code<PayToken>(),
                quantity: 1u128,
                selling_price: box_sell_info.selling_price,
                final_price: offer_price,
                buyer: buyer_address,
            }
        );

    }

    // box offer price
    public fun box_bid<BoxToken: store, PayToken: store>(buyer: &signer, id: u128, offer_price: u128) acquires BoxSelling{

        assert(exists<BoxSelling<BoxToken, PayToken>>(NFT_MARKET_ADDRESS), Errors::invalid_argument(BOX_SELLING_NOT_EXIST));

        let box_sellings = borrow_global_mut<BoxSelling<BoxToken, PayToken>>(NFT_MARKET_ADDRESS);
        let len = Vector::length(&box_sellings.items);
        assert(len > 0, Errors::invalid_argument(BOX_SELLING_IS_EMPTY));

        let buyer_address = Signer::address_of(buyer);

        let box_sell_info: &mut BoxSellInfo<BoxToken, PayToken>;
        let k = 0;
        while ( k < len){
            let box_item = Vector::borrow_mut(&box_sellings.items, k);
            if(box_item.id == id){
                box_sell_info = box_item;
                break;
            };
            k = k + 1;
        };

        if(offer_price >= box_sell_info.selling_price){
            //购买
            box_buy(buyer, id);
        } else {
            let bid_price = Token::value<PayToken>(&box_sell_info.bid_tokens);
            //已经有报价
            if(bid_price > 0u128){
                //最新的报价小于等于之前的最高报价
                assert(offer_price > bid_price, Errors::invalid_argument(BOX_SELLING_PRICE_SMALL));

                //最新的报价大于之前的最高报价，对之前的用户进行返还
                let withdraw_bid_token = Token::withdraw<PayToken>(&box_sell_info.bid_tokens, bid_price);
                Account::deposit<PayToken>(&box_sell_info.bider, withdraw_bid_token);
            };

            let withdraw_buy_box_token = Token::withdraw<PayToken>(buyer, offer_price);
            Token::deposit(&mut box_sell_info.bid_tokens, withdraw_buy_box_token);

            box_sell_info.bider = buyer_address;

            Event::emit_event(
                &box_sellings.bid_events,
                BoxBidEvent{
                    seller: box_sell_info.seller,
                    box_token_code: Token::token_code<BoxToken>(),
                    pay_token_code: Token::token_code<PayToken>(),
                    selling_price: box_sell_info.selling_price,
                    bider: buyer_address,
                    bid_price: offer_price,
                }
            );

        };

    }

    // box buy
    public fun box_buy<BoxToken: store, PayToken: store>(buyer: &signer, id: u128) acquires BoxSelling{

        assert(exists<BoxSelling<BoxToken, PayToken>>(NFT_MARKET_ADDRESS), Errors::invalid_argument(BOX_SELLING_NOT_EXIST));

        let box_sellings = borrow_global_mut<BoxSelling<BoxToken, PayToken>>(NFT_MARKET_ADDRESS);
        let len = Vector::length(&box_sellings.items);
        assert(len > 0, Errors::invalid_argument(BOX_SELLING_IS_EMPTY));

        let buyer_address = Signer::address_of(buyer);

        let box_sell_info: &mut BoxSellInfo<BoxToken, PayToken>;
        let k = 0;
        while ( k < len){
            let box_item = Vector::borrow(&box_sellings.items, k);
            if(box_item.id == id){
                box_sell_info = box_item;
                break;
            };
            k = k + 1;
        };
        let seller_address = box_sell_info.seller;

        let bid_price = Token::value<PayToken>(&box_sell_info.bid_tokens);
        //已经有报价
        if(bid_price > 0u128){
            //最新的报价大于之前的最高报价，对之前的用户进行返还
            let withdraw_bid_token = Token::withdraw<PayToken>(&box_sell_info.bid_tokens, bid_price);
            Account::deposit<PayToken>(&box_sell_info.bider, withdraw_bid_token);
        };

        let withdraw_box_token = Token::withdraw<BoxToken>(&box_sell_info.box_tokens, 1);
        Account::deposit(buyer_address, withdraw_box_token);

        let withdraw_buy_box_token = Token::withdraw<PayToken>(buyer, offer_price);
        Account::deposit(seller_address, withdraw_buy_box_token);

//        box_sell_info.bider = buyer_address;

        let remove_box_sell_info = Vector::remove<BoxSellInfo<BoxToken, PayToken>>(&mut &box_sellings.items, k);

        let BoxSellInfo<BoxToken, PayToken>  {
            id:_,
            seller: _,
            box_tokens,
            selling_price: _,
            bid_tokens,
            bider: _,
        } = remove_box_sell_info;

        Event::emit_event(
            &box_sellings.bid_events,
            BoxBidEvent{
                seller: box_sell_info.seller,
                box_token_code: Token::token_code<BoxToken>(),
                pay_token_code: Token::token_code<PayToken>(),
                selling_price: box_sell_info.selling_price,
                bider: buyer_address,
                bid_price: box_sell_info.selling_price,
            }
        );
        Event::emit_event(
            &box_sellings.sell_events,
            BoxSellEvent{
                seller: box_sell_info.seller,
                box_token_code: Token::token_code<BoxToken>(),
                pay_token_code: Token::token_code<PayToken>(),
                quantity: 1,
                selling_price: box_sell_info.selling_price,
                final_price: selling_price,
                buyer: buyer_address,
            }
        );

    }

    // ******************** NFT Transaction ********************
    // NFT出售列表
    struct NFTSelling<NFTMeta: store, NFTBody: store, PayToken: store> has key, store {
        // nft selling list
        items: vector<NFTSellInfo<NFTMeta, NFTBody, PayToken>>,
        sell_events: Event::EventHandle<NFTSellEvent<NFTMeta>>,
        bid_events: Event::EventHandle<NFTSellEvent<NFTMeta>>,
    }

    // NFT商品信息，用于封装NFT
    struct NFTSellInfo<NFTMeta: store, NFTBody: store, PayToken: store> has store, drop {
        seller: address,
        // nft item
        nft: NFT<NFTMeta, NFTBody>,
        // nft id
        id: u64,
        // selling price
        selling_price: u128,
        // top price bid tokens
        bid_tokens: Token::Token<PayToken>,
        // buyer address
        bider: address,
    }

    // NFT出价事件
    struct NFTBidEvent<NFTMeta: store> has drop, store {
        seller: address,
        id: u64,
        pay_token_code: Token::TokenCode,
        selling_price: u128,
        bid_price: u128,
        bider: address,
    }

    // NFT卖出事件
    struct NFTSellEvent<NFTMeta: store> has drop, store {
        seller: address,
        id: u64,
        pay_token_code: Token::TokenCode,
        final_price: u128,
        buyer: address,
    }

    // NFT出售，挂单子,将我自己的 nft 移动到 NFTSellInfo
    public fun nft_sell<NFTMeta: store, NFTBody: store, PayToken: store>(account: &signer, id: u64, selling_price: u128) acquires NFTSelling{
        let nft_selling = borrow_global_mut<NFTSelling<NFTMeta, NFTBody, PayToken>>(NFT_MARKET_ADDRESS);
        // 判断 NFTSelling 是否存在
        assert(exists<NFTSelling<NFTMeta, NFTBody, PayToken>>(NFT_MARKET_ADDRESS), Errors::invalid_argument(OFFERING_NOT_EXISTS));
        let owner_address = Signer::address_of(account);
        // 从自己的账户取出 一个 NFT token
        let nft = Account::withdraw<NFTMeta, NFTBody>(owner_address, 1);
        let nft_sell_info = NFTSellInfo<NFTMeta, NFTBody, PayToken> {
            seller: owner_address,
            nft: nft,
            id: id,
            selling_price: selling_price,
            bid_tokens: Token::token_code<PayToken>(),
            bider: @0x1,
        };
        Vector::push_back(&mut nft_selling.items, nft_sell_info);
    }

    // NFT出价
    public fun nft_bid<NFTMeta: store, NFTBody: store, PayToken: store>(account: &signer, id: u64, price: u128) acquires NFTSelling{
        let nft_token = borrow_global_mut<NFTSelling<NFTMeta, NFTBody, PayToken>>(NFT_MARKET_ADDRESS);
        let nftSellInfo = find_ntf_sell_info_by_id<NFTMeta,NFTBody>(&nft_token.items,id);
        //出价者的地址
        let user_address = Signer::address_of(account);

        if(price >= nftSellInfo.selling_price){
            nft_buy<NFTMeta, NFTBody, PayToken>(account,id);
        }else{
            //判断 是否已经有人出价，如果有，需要还回去
            // 判断依据bid_tokens 是否》0
            nftSellInfo.bider = user_address;

            // top price bid tokens
            bid_tokens: Token::Token<PayToken>,

            //发送 NFTBidEvent 事件
            Event::emit_event<NFTBidEvent>( &mut nft_token.bid_events,bid_event
                NFTBidEvent {
                    seller: nftSellInfo.seller,
                    id: id,
                    pay_token_code: Token::token_code<PayToken>(),
                    selling_price: nftSellInfo.selling_price,
                    bid_price: price,
                    bider: user_address,
                },
            );
        }
    }

    // NFT接受报价 卖出去
    public fun nft_accept_bid<NFTMeta: store, NFTBody: store, PayToken: store>(account: &signer, id: u64) acquires NFTSelling{

        let user_address = Signer::address_of(account);

        let nft_token = borrow_global_mut<NFTSelling<NFTMeta, NFTBody, PayToken>>(NFT_MARKET_ADDRESS);

        let nftSellInfo = find_ntf_sell_info_by_id<NFTMeta,NFTBody>(&nft_token.items,id);

        // 将 nft 直接转给 出价者

        // 将 支付币种 PayToken 从 pool 转到 自己账户，

    }

    // NFT购买 id = NFTSellInfo id
    public fun nft_buy<NFTMeta: store, NFTBody: store, PayToken: store>(account: &signer, id: u64) acquires NFTSelling{

        let user_address = Signer::address_of(account);

        let nft_token = borrow_global_mut<NFTSelling<NFTMeta, NFTBody, PayToken>>(NFT_MARKET_ADDRESS);

        let nftSellInfo = find_ntf_sell_info_by_id<NFTMeta,NFTBody>(&nft_token.items,id);

        let token_balance = Account::balance<PayToken>(user_address);
        let selling_price = nftSellInfo.selling_price;

        assert(token_balance >= selling_price, Errors::invalid_argument(INSUFFICIENT_BALANCE));

        Account::pay_from<PayToken>(account,nftSellInfo.seller,selling_price);

        // 同意一下
        NFTGallery::accept<NFTMeta,NFTBody>(account);

        // nft 转给 我自己
        NFTGallery::deposit<NFTMeta,NFTBody>(account,nftSellInfo.nft);

        //发送 NFTSellEvent 事件
        Event::emit_event<NFTSellEvent>(&mut nft_token.sell_events,
            NFTSellEvent {
                seller: nftSellInfo.seller,
                id: nftSellInfo.id,
                pay_token_code: Token::token_code<PayToken>(),
                final_price: selling_price,
                buyer: user_address,
            },
        );
    }

    fun find_ntf_sell_info_by_id<NFTMeta: store, NFTBody: store>(c: &vector<NFTSellInfo<NFTMeta, NFTBody, PayToken>>, id: u64):
        NFTSellInfo<NFTMeta, NFTBody, PayToken> {
        let len = Vector::length(c);
        assert(len > 0, Errors::invalid_argument(ID_NOT_EXIST));
        let nftSellInfos = len - 1;
        loop {
            // NFTSellInfo<NFTMeta, NFTBody, PayToken>
            let nftSellInfo = Vector::borrow(c, nftSellInfos);
            let nft = nftSellInfo.nft;
            if (NFT::get_id(nft) == id) {
                return nftSellInfo
            };
            assert(nftSellInfos > 0, Errors::invalid_argument(ID_NOT_EXIST));
            nftSellInfos = nftSellInfos - 1;
        }
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
    struct NFTBuyBackSellEvent<NFTMeta: store> has drop, store {
        seller: address,
        id: u64,
        pay_token_code: Token::TokenCode,
        final_price: u128,
        buyer: address,
    }

    // NFT回购
    public fun nft_buy_back() {}

    // NFT回购出售
    public fun nft_buy_back_sell() {}
}
}