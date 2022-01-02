address 0x69F1E543A3BeF043B63BEd825fcd2cf6 {
module KikoCatCard01 {
    use 0x1::Signer;
    use 0x1::Event;
    use 0x1::Block;
    use 0x1::Vector;
    use 0x1::Option::{Self, Option};
    use 0x1::Token;
    use 0x1::Account;
    use 0x1::NFT::{Self, NFT};
    use 0x1::NFTGallery;
    use 0x69F1E543A3BeF043B63BEd825fcd2cf6::KikoCatElement01::{Self, KikoCatMeta as ElementMeta, KikoCatBody as ElementBody};

    const NFT_ADDRESS: address = @0x69F1E543A3BeF043B63BEd825fcd2cf6;

    const PERMISSION_DENIED: u64 = 100001;
    const TYPE_NOT_MATCH: u64 = 100002;
    const NFT_NOT_EXIST: u64 = 100003;
    const ELEMENT_CANNOT_EMPTY: u64 = 100004;

    // ******************** NFT ********************
    // NFT extra meta
    struct KikoCatMeta has copy, store, drop {
        original: bool,
        score: u128,
        background_id: u64,
        fur_id: u64,
        clothes_id: u64,
        facial_expression_id: u64,
        head_id: u64,
    }

    // NFT body
    struct KikoCatBody has copy, store, drop {}

    // NFT extra type info
    struct KikoCatTypeInfo has copy, store, drop {}

    struct KikoCatNFTCapability has key {
        mint: NFT::MintCapability<KikoCatMeta>,
        burn: NFT::BurnCapability<KikoCatMeta>,
    }

    struct ElementGallery has key, store {
        items: vector<ElementInfo>,
    }

    struct ElementInfo has key, store {
        nft_id: u64,
        background: Option<NFT<ElementMeta, ElementBody>>,
        fur: Option<NFT<ElementMeta, ElementBody>>,
        clothes: Option<NFT<ElementMeta, ElementBody>>,
        facial_expression: Option<NFT<ElementMeta, ElementBody>>,
        head: Option<NFT<ElementMeta, ElementBody>>,
    }

    // init nft with image data
    fun init_nft(
        sender: &signer,
        metadata: NFT::Metadata,
    ) {
        NFT::register<KikoCatMeta, KikoCatTypeInfo>(sender, KikoCatTypeInfo {}, metadata);
        let mint = NFT::remove_mint_capability<KikoCatMeta>(sender);
        let burn = NFT::remove_burn_capability<KikoCatMeta>(sender);
        move_to(sender, KikoCatNFTCapability { mint, burn });
    }

    // mint nft and deposit into kiko gallery
    fun mint_original_nft(
        sender: &signer,
        metadata: NFT::Metadata,
        background_id: u64,
        fur_id: u64,
        clothes_id: u64,
        facial_expression_id: u64,
        head_id: u64,
    ) acquires KikoCatNFTCapability, KikoCatGallery, ElementGallery {
        let nft = composit_nft(sender, metadata, true, background_id, fur_id, clothes_id, facial_expression_id, head_id);

        let gallery = borrow_global_mut<KikoCatGallery>(NFT_ADDRESS);
        let id = NFT::get_id<KikoCatMeta, KikoCatBody>(&nft);
        Vector::push_back(&mut gallery.items, nft);
        Event::emit_event<NFTMintEvent<KikoCatMeta, KikoCatBody>>(&mut gallery.nft_mint_events,
            NFTMintEvent<KikoCatMeta, KikoCatBody> {
                creator: NFT_ADDRESS,
                id,
                original: true,
                background_id,
                clothes_id,
                fur_id,
                facial_expression_id,
                head_id,
            },
        );
    }

    // mint nft and deposit into user gallery
    fun mint_custom_nft(
        sender: &signer,
        metadata: NFT::Metadata,
        background_id: u64,
        fur_id: u64,
        clothes_id: u64,
        facial_expression_id: u64,
        head_id: u64,
    ) acquires KikoCatNFTCapability, KikoCatGallery, ElementGallery {
        let nft = composit_nft(sender, metadata, false, background_id, fur_id, clothes_id, facial_expression_id, head_id);
        let sender_address = Signer::address_of(sender);

        let gallery = borrow_global_mut<KikoCatGallery>(NFT_ADDRESS);
        let id = NFT::get_id<KikoCatMeta, KikoCatBody>(&nft);
        NFTGallery::deposit(sender, nft);
        Event::emit_event<NFTMintEvent<KikoCatMeta, KikoCatBody>>(&mut gallery.nft_mint_events,
            NFTMintEvent<KikoCatMeta, KikoCatBody> {
                creator: sender_address,
                id,
                original: false,
                background_id,
                clothes_id,
                fur_id,
                facial_expression_id,
                head_id,
            },
        );
    }

    fun composit_nft(
        sender: &signer,
        metadata: NFT::Metadata,
        original: bool,
        background_id: u64,
        fur_id: u64,
        clothes_id: u64,
        facial_expression_id: u64,
        head_id: u64
    ) : NFT<KikoCatMeta, KikoCatBody> acquires KikoCatNFTCapability, ElementGallery {
        let sender_address = Signer::address_of(sender);
        assert(background_id + fur_id + clothes_id + facial_expression_id + head_id > 0, ELEMENT_CANNOT_EMPTY);

        let cap = borrow_global_mut<KikoCatNFTCapability>(sender_address);
        // get element
        let background = get_element_by_id(sender, background_id, 1u64);
        let fur = get_element_by_id(sender, fur_id, 2u64);
        let clothes = get_element_by_id(sender, clothes_id, 3u64);
        let facial_expression = get_element_by_id(sender, facial_expression_id, 4u64);
        let head = get_element_by_id(sender, head_id, 5u64);
        // sum score
        let score = 0;
        score = score + get_score(&background);
        score = score + get_score(&fur);
        score = score + get_score(&clothes);
        score = score + get_score(&facial_expression);
        score = score + get_score(&head);
        // mint card
        let card_nft = NFT::mint_with_cap<KikoCatMeta, KikoCatBody, KikoCatTypeInfo>(
            sender_address,
            &mut cap.mint,
            metadata,
            KikoCatMeta {
                original,
                score,
                background_id,
                clothes_id,
                fur_id,
                facial_expression_id,
                head_id,
            },
            KikoCatBody {}
        );
        // stake element
        let nft_id = NFT::get_id(&card_nft);
        let element_info = ElementInfo {
            nft_id,
            background,
            fur,
            clothes,
            facial_expression,
            head,
        };
        let gallery = borrow_global_mut<ElementGallery>(NFT_ADDRESS);
        Vector::push_back(&mut gallery.items, element_info);
        return card_nft
    }

    // get element by id
    fun get_element_by_id(sender: &signer, nft_id: u64, type_id: u64): Option<NFT<ElementMeta, ElementBody>> {
        if (nft_id == 0) {
            return Option::none()
        };
        // get element
        let option_nft = NFTGallery::withdraw<ElementMeta, ElementBody>(sender, nft_id);
        assert(Option::is_some<NFT<ElementMeta, ElementBody>>(&option_nft), NFT_NOT_EXIST);
        // get nft
        let nft = Option::borrow<NFT<ElementMeta, ElementBody>>(&option_nft);
        assert(KikoCatElement01::get_type_id(nft) == type_id, TYPE_NOT_MATCH);
        return option_nft
    }

    // get score from element
    fun get_score(option_nft: &Option<NFT<ElementMeta, ElementBody>>): u128 {
        if (Option::is_some<NFT<ElementMeta, ElementBody>>(option_nft)) {
            let nft = Option::borrow<NFT<ElementMeta, ElementBody>>(option_nft);
            return KikoCatElement01::get_score(nft)
        };
        return 0
    }

    // resolve and destory card
    fun resolve_nft(sender: &signer, nft_id: u64) acquires KikoCatNFTCapability, KikoCatGallery, ElementGallery {
        let option_nft = NFTGallery::withdraw<KikoCatMeta, KikoCatBody>(sender, nft_id);
        assert(Option::is_some<NFT<KikoCatMeta, KikoCatBody>>(&option_nft), NFT_NOT_EXIST);
        let nft = Option::extract<NFT<KikoCatMeta, KikoCatBody>>(&mut option_nft);
        // get meta
        let meta = NFT::get_type_meta<KikoCatMeta, KikoCatBody>(&nft);
        // deposit element to user
        unstake_element(sender, meta.background_id);
        // destroy card
        let cap = borrow_global_mut<KikoCatNFTCapability>(NFT_ADDRESS);
        let KikoCatBody {} = NFT::burn_with_cap<KikoCatMeta, KikoCatBody>(&mut cap.burn, nft);
        Option::destroy_none(option_nft);

        let gallery = borrow_global_mut<KikoCatGallery>(NFT_ADDRESS);
        Event::emit_event<NFTResolveEvent<KikoCatMeta, KikoCatBody>>(&mut gallery.nft_resolve_events,
            NFTResolveEvent<KikoCatMeta, KikoCatBody> {
                owner: Signer::address_of(sender),
                id: nft_id,
            },
        );
    }

    fun unstake_element(sender: &signer, nft_id: u64) acquires ElementGallery {
        if (nft_id > 0) {
            let gallery = borrow_global_mut<ElementGallery>(NFT_ADDRESS);
            let len = Vector::length(&gallery.items);
            if (len == 0) {
                return
            };
            let idx = len - 1;
            loop {
                let info = Vector::borrow(&gallery.items, idx);
                if (info.nft_id == nft_id) {
                    let info = Vector::remove<ElementInfo>(&mut gallery.items, idx);
                    deposit_nft(sender, &mut info.background);
                    deposit_nft(sender, &mut info.fur);
                    deposit_nft(sender, &mut info.clothes);
                    deposit_nft(sender, &mut info.facial_expression);
                    deposit_nft(sender, &mut info.head);
                    let ElementInfo {
                        nft_id: _,
                        background,
                        fur,
                        clothes,
                        facial_expression,
                        head,
                    } = info;
                    Option::destroy_none(background);
                    Option::destroy_none(fur);
                    Option::destroy_none(clothes);
                    Option::destroy_none(facial_expression);
                    Option::destroy_none(head);
                    return
                };
                idx = idx - 1;
                assert(idx >= 0, NFT_NOT_EXIST);
            }
        }
    }

    fun deposit_nft(sender: &signer, option_nft: &mut Option<NFT<ElementMeta, ElementBody>>) {
        if (Option::is_some(option_nft)) {
            let nft = Option::extract(option_nft);
            NFTGallery::deposit(sender, nft);
        }
    }

    // ******************** NFT Gallery ********************
    // kiko gallery
    struct KikoCatGallery has key, store {
        items: vector<NFT<KikoCatMeta, KikoCatBody>>,
        nft_mint_events: Event::EventHandle<NFTMintEvent<KikoCatMeta, KikoCatBody>>,
        nft_resolve_events: Event::EventHandle<NFTResolveEvent<KikoCatMeta, KikoCatBody>>,
        box_open_events: Event::EventHandle<BoxOpenEvent<KikoCatMeta, KikoCatBody>>,
    }

    // box open event
    struct NFTMintEvent<NFTMeta: store + drop, NFTBody: store + drop> has drop, store {
        creator: address,
        id: u64,
        original: bool,
        background_id: u64,
        fur_id: u64,
        clothes_id: u64,
        facial_expression_id: u64,
        head_id: u64,
    }

    // box open event
    struct NFTResolveEvent<NFTMeta: store + drop, NFTBody: store + drop> has drop, store {
        owner: address,
        id: u64,
    }

    // box open event
    struct BoxOpenEvent<NFTMeta: store + drop, NFTBody: store + drop> has drop, store {
        owner: address,
        id: u64,
    }

    // init kiko gallery
    fun init_gallery(sender: &signer) {
        if (!exists<KikoCatGallery>(Signer::address_of(sender))) {
            let gallery = KikoCatGallery {
                items: Vector::empty<NFT<KikoCatMeta, KikoCatBody>>(),
                nft_mint_events: Event::new_event_handle<NFTMintEvent<KikoCatMeta, KikoCatBody>>(sender),
                nft_resolve_events: Event::new_event_handle<NFTResolveEvent<KikoCatMeta, KikoCatBody>>(sender),
                box_open_events: Event::new_event_handle<BoxOpenEvent<KikoCatMeta, KikoCatBody>>(sender),
            };
            move_to(sender, gallery);
        }
    }

    // Count all NFTs assigned to an owner
    public fun count_of(owner: address): u64
    acquires KikoCatGallery {
        let gallery = borrow_global_mut<KikoCatGallery>(owner);
        Vector::length(&gallery.items)
    }

    // ******************** NFT Box ********************
    // box
    struct KikoCatBox has copy, drop, store {}

    const PRECISION: u8 = 0;

    struct KikoCatBoxCapability has key, store {
        mint: Token::MintCapability<KikoCatBox>,
        burn: Token::BurnCapability<KikoCatBox>,
    }

    // init box
    fun init_box(sender: &signer) {
        Token::register_token<KikoCatBox>(sender, PRECISION);
        let mint_cap = Token::remove_mint_capability<KikoCatBox>(sender);
        let burn_cap = Token::remove_burn_capability<KikoCatBox>(sender);
        move_to(sender, KikoCatBoxCapability { mint: mint_cap, burn: burn_cap });
    }

    // mint box
    fun mint_box(sender: &signer, amount: u128)
    acquires KikoCatBoxCapability {
        let cap = borrow_global<KikoCatBoxCapability>(NFT_ADDRESS);
        let token = Token::mint_with_capability<KikoCatBox>(&cap.mint, amount);
        Account::deposit_to_self(sender, token);
    }

    fun burn_box(token: Token::Token<KikoCatBox>)
    acquires KikoCatBoxCapability {
        let cap = borrow_global<KikoCatBoxCapability>(NFT_ADDRESS);
        Token::burn_with_capability(&cap.burn, token);
    }

    // ******************** NFT public function ********************

    // init nft and box with image
    public(script) fun init_with_image(
        sender: signer,
        name: vector<u8>,
        image: vector<u8>,
        description: vector<u8>,
    ) {
        assert(Signer::address_of(&sender) == NFT_ADDRESS, PERMISSION_DENIED);
        let metadata = NFT::new_meta_with_image(name, image, description);
        init_nft(&sender, metadata);
        init_box(&sender);
        init_gallery(&sender);
        NFTGallery::accept<KikoCatMeta, KikoCatBody>(&sender);
    }

    // mint NFT and box
    public(script) fun mint_original_nft_with_image(
        sender: signer,
        name: vector<u8>,
        image: vector<u8>,
        description: vector<u8>,
        background_id: u64,
        fur_id: u64,
        clothes_id: u64,
        facial_expression_id: u64,
        head_id: u64,
    ) acquires KikoCatNFTCapability, KikoCatBoxCapability, KikoCatGallery, ElementGallery {
        let sender_address = Signer::address_of(&sender);
        assert(sender_address == NFT_ADDRESS, PERMISSION_DENIED);
        let metadata = NFT::new_meta_with_image(name, image, description);
        mint_original_nft(&sender, metadata, background_id, fur_id, clothes_id, facial_expression_id, head_id);
        mint_box(&sender, 1);
    }

    // mint custom NFT
    public(script) fun mint_custom_nft_with_image(
        sender: signer,
        name: vector<u8>,
        image: vector<u8>,
        description: vector<u8>,
        background_id: u64,
        fur_id: u64,
        clothes_id: u64,
        facial_expression_id: u64,
        head_id: u64,
    ) acquires KikoCatNFTCapability, KikoCatGallery, ElementGallery {
        let sender_address = Signer::address_of(&sender);
        assert(sender_address == NFT_ADDRESS, PERMISSION_DENIED);
        let metadata = NFT::new_meta_with_image(name, image, description);
        mint_custom_nft(&sender, metadata, background_id, fur_id, clothes_id, facial_expression_id, head_id);
    }

    // open box and get a random NFT
    public(script) fun open_box(sender: signer)
    acquires KikoCatBoxCapability, KikoCatGallery {
        let box_token = Account::withdraw<KikoCatBox>(&sender, 1);
        burn_box(box_token);
        // get hash last 64 bit and mod nft_size
        let hash = Block::get_parent_hash();
        let k = 0u64;
        let i = 0;
        while (i < 8) {
            let tmp = (Vector::pop_back<u8>(&mut hash) as u128);
            k = (tmp << (i * 8) as u64) + k;
            i = i + 1;
        };
        let idx = k % count_of(NFT_ADDRESS);
        // get a nft by idx
        let sender_address = Signer::address_of(&sender);
        let gallery = borrow_global_mut<KikoCatGallery>(NFT_ADDRESS);
        let nft = Vector::remove<NFT<KikoCatMeta, KikoCatBody>>(&mut gallery.items, idx);
        let id = NFT::get_id<KikoCatMeta, KikoCatBody>(&nft);
        NFTGallery::accept<KikoCatMeta, KikoCatBody>(&sender);
        NFTGallery::deposit<KikoCatMeta, KikoCatBody>(&sender, nft);
        // emit event
        Event::emit_event<BoxOpenEvent<KikoCatMeta, KikoCatBody>>(&mut gallery.box_open_events,
            BoxOpenEvent<KikoCatMeta, KikoCatBody> {
                owner: sender_address,
                id: id,
            },
        );
    }
}
}
