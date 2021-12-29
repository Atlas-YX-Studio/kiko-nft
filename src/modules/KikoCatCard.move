address 0x69F1E543A3BeF043B63BEd825fcd2cf6 {
module KikoCatCard {
    use 0x1::Signer;
    use 0x1::Event;
    use 0x1::Block;
    use 0x1::Vector;
    use 0x1::Option::{Self, Option};
    use 0x1::Token;
    use 0x1::Account;
    use 0x1::NFT::{Self, NFT};
    use 0x1::NFTGallery;
    use 0x69F1E543A3BeF043B63BEd825fcd2cf6::KikoCatElement::{KikoCatMeta as ElementMeta, KikoCatBody as ElementBody};

    const NFT_ADDRESS: address = @0x69F1E543A3BeF043B63BEd825fcd2cf6;

    const PERMISSION_DENIED: u64 = 100001;
    const TYPE_NOT_MATCH: u64 = 100002;
    const NFT_NOT_EXIST: u64 = 100003;

    // ******************** NFT ********************
    // NFT extra meta
    struct KikoCatMeta has copy, store, drop {}

    // NFT body
    struct KikoCatBody has store, drop {
        background: Option<NFT<ElementMeta, ElementBody>>,
        fur: Option<NFT<ElementMeta, ElementBody>>,
        clothes: Option<NFT<ElementMeta, ElementBody>>,
        facial_expression: Option<NFT<ElementMeta, ElementBody>>,
        head: Option<NFT<ElementMeta, ElementBody>>,
        score: u128,
    }

    // NFT extra type info
    struct KikoCatTypeInfo has copy, store, drop {}

    struct KikoCatNFTCapability has key {
        mint: NFT::MintCapability<KikoCatMeta>,
        burn: NFT::BurnCapability<KikoCatMeta>,
        update: NFT::UpdateCapability<KikoCatMeta>,
    }

    // init nft with image data
    fun init_nft(
        sender: &signer,
        metadata: NFT::Metadata,
    ) {
        NFT::register<KikoCatMeta, KikoCatTypeInfo>(sender, KikoCatTypeInfo {}, metadata);
        let mint = NFT::remove_mint_capability<KikoCatMeta>(sender);
        let burn = NFT::remove_burn_capability<KikoCatMeta>(sender);
        let update = NFT::remove_update_capability<KikoCatMeta>(sender);
        move_to(sender, KikoCatNFTCapability { mint, burn, update });
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
    ) acquires KikoCatNFTCapability, KikoCatGallery {
        let sender_address = Signer::address_of(sender);
        let cap = borrow_global_mut<KikoCatNFTCapability>(sender_address);
        // element nft
        let background = get_element_by_id(sender, background_id, 1u64);
        let clothes = get_element_by_id(sender, fur_id, 1u64);
        let fur = get_element_by_id(sender, clothes_id, 1u64);
        let facial_expression = get_element_by_id(sender, facial_expression_id, 1u64);
        let head = get_element_by_id(sender, head_id, 1u64);
        // score
        let score = sum_score(background, clothes, fur, facial_expression, head);

        let nft = NFT::mint_with_cap<KikoCatMeta, KikoCatBody, KikoCatTypeInfo>(
            sender_address,
            &mut cap.mint,
            metadata,
            KikoCatMeta {},
            KikoCatBody {
                background,
                clothes,
                fur,
                facial_expression,
                head,
                score,
            }
        );
        let gallery = borrow_global_mut<KikoCatGallery>(sender_address);
        let id = NFT::get_id<KikoCatMeta, KikoCatBody>(&nft);
        Vector::push_back(&mut gallery.items, nft);
        Event::emit_event<NFTMintEvent<KikoCatMeta, KikoCatBody>>(&mut gallery.nft_mint_events,
            NFTMintEvent {
                creator: sender_address,
                id,
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
    ) acquires KikoCatNFTCapability, KikoCatGallery {
        let sender_address = Signer::address_of(sender);
        let cap = borrow_global_mut<KikoCatNFTCapability>(sender_address);
        let background = get_element_by_id(sender, background_id, 1u64);
        let clothes = get_element_by_id(sender, fur_id, 1u64);
        let fur = get_element_by_id(sender, clothes_id, 1u64);
        let facial_expression = get_element_by_id(sender, facial_expression_id, 1u64);
        let head = get_element_by_id(sender, head_id, 1u64);
        let score = sum_score(background, clothes, fur, facial_expression, head);
        let nft = NFT::mint_with_cap<KikoCatMeta, KikoCatBody, KikoCatTypeInfo>(
            sender_address,
            &mut cap.mint,
            metadata,
            KikoCatMeta {},
            KikoCatBody {
                background,
                clothes,
                fur,
                facial_expression,
                head,
                score, }
        );
        let gallery = borrow_global_mut<KikoCatGallery>(sender_address);
        let id = NFT::get_id<KikoCatMeta, KikoCatBody>(&nft);
        NFTGallery::deposit(sender, nft);
        Event::emit_event<NFTMintEvent<KikoCatMeta, KikoCatBody>>(&mut gallery.nft_mint_events,
            NFTMintEvent {
                creator: sender_address,
                id,
                background_id,
                clothes_id,
                fur_id,
                facial_expression_id,
                head_id,
            },
        );
    }

    // resolve and destory card
    fun resolve_nft(sender: &signer, nft_id: u64) acquires KikoCatNFTCapability {
        let option_nft = NFTGallery::withdraw<KikoCatMeta, KikoCatBody>(account, id);
        assert(Option::is_some<NFT<KikoCatMeta, KikoCatBody>>(&option_nft), NFT_NOT_EXIST);
        let nft = Option::extract<NFT<KikoCatMeta, KikoCatBody>>(&option_nft);
        // get body with update cap
        let cap = borrow_global_mut<KikoCatNFTCapability>(NFT_ADDRESS);
        let body = NFT::borrow_body_mut_with_cap<KikoCatMeta, KikoCatBody>(cap.update);
        // deposit element
        deposit_nft(sender, body.background);
        deposit_nft(sender, body.fur);
        deposit_nft(sender, body.clothes);
        deposit_nft(sender, body.facial_expression);
        deposit_nft(sender, body.head);
        // destroy card
        NFT::burn_with_cap<ElementMeta, ElementBody>(cap.update, nft);
        Event::emit_event<NFTResolveEvent<KikoCatMeta, KikoCatBody>>(&mut gallery.nft_resolve_events,
            NFTResolveEvent {
                creator: sender_address,
                id: nft_id,
            },
        );
    }

    fun deposit_nft(sender: &signer, option_nft: &Option<NFT<ElementMeta, ElementBody>>) {
        let backgroup = Option.extract<NFT<ElementMeta, ElementBody>>(body.background);
        NFTGallery::deposit(sender, backgroup);
    }

    // sum score
    fun sum_score(
        backgroup: Option<NFT<ElementMeta, ElementBody>>,
        fur: Option<NFT<ElementMeta, ElementBody>>,
        clothes: Option<NFT<ElementMeta, ElementBody>>,
        facial_expression: Option<NFT<ElementMeta, ElementBody>>,
        head: Option<NFT<ElementMeta, ElementBody>>,
    ): u64 {
        let score = get_score(backgroup);
        score = score + get_score(fur);
        score = score + get_score(clothes);
        score = score + get_score(facial_expression);
        score = score + get_score(head);
        score
    }

    // get score from element
    fun get_score(option_nft: &Option<NFT<ElementMeta, ElementBody>>): u64 {
        if (Option::is_some<NFT<ElementMeta, ElementBody>>(option_nft)) {
            let nft = Option::borrow<NFT<ElementMeta, ElementBody>>(&option_nft);
            return KikoCatElement::get_score(nft)
        };
        return 0
    }

    // get element by nft id
    fun get_element_by_id(sender: &signer, nft_id: u64, type_id: u64): Option<NFT<ElementMeta, ElementBody>> {
        let option_nft = NFTGallery::withdraw<ElementMeta, ElementBody>(sender, id);
        if (Option::is_some<NFT<ElementMeta, ElementBody>>(&option_nft)) {
            let nft = Option::borrow<NFT<ElementMeta, ElementBody>>(&option_nft);
            assert(KikoCatElement::get_type_id(nft) == type_id, TYPE_NOT_MATCH);
        };
        return option_nft
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
        background_id: u64,
        fur_id: u64,
        clothes_id: u64,
        facial_expression_id: u64,
        head_id: u64,
    }

    // box open event
    struct NFTResolveEvent<NFTMeta: store + drop, NFTBody: store + drop> has drop, store {
        creator: address,
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
    ) acquires KikoCatNFTCapability, KikoCatBoxCapability, KikoCatGallery {
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
    ) acquires KikoCatNFTCapability, KikoCatBoxCapability, KikoCatGallery {
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
            BoxOpenEvent {
                owner: sender_address,
                id: id,
            },
        );
    }
}
}
