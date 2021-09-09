address 0x111 {
module KikoCat01 {
    use 0x1::Signer;
    use 0x1::Event;
    use 0x1::NFT;
    use 0x1::Block;

    const NFT_ADDRESS: address = @0x111;

    const PERMISSION_DENIED: u64 = 100001;

    // ******************** NFT ********************
    // NFT extra meta
    struct KikoCatMeta has copy, store, drop {
        background: vector<u8>,
        breed: vector<u8>,
        decorate: vector<u8>,
    }

    // NFT body
    struct KikoCatBody has copy, store, drop {}

    // NFT extra type info
    struct KikoCatTypeInfo has copy, store, drop {}

    struct KikoCatNFTCapability has key {
        mint: MintCapability<KikoCat>,
    }

    // init nft
    fun init_nft(sender: &signer) {
        NFT::register<KikoCatMeta, KikoCatTypeInfo>(sender, KikoCatTypeInfo {}, NFT::empty_meta());
        let mint = NFT::remove_mint_capability<KikoCatMeta>(sender);
        move_to(sender, KikoCatNFTCapability { mint });
    }

    // mint nft
    fun mint_nft(
        sender: &signer,
        name: vector<u8>,
        image: vector<u8>,
        description: vector<u8>,
        background: vector<u8>,
        breed: vector<u8>,
        decorate: vector<u8>,
    ) acquires KikoCatNFTCapability {
        let sender_address = Signer::address_of(sender);
        let cap = borrow_global_mut<KikoCatNFTCapability>(sender_address);
        let metadata = NFT::new_meta_with_image(name, image, description);
        let nft = NFT::mint_with_cap<KikoCatMeta, KikoCatBody, KikoCatTypeInfo>(
            sender_address,
            &mut cap.mint,
            metadata,
            KikoCatMeta {
                background: background,
                breed: breed,
                decorate: decorate,
            },
            KikoCatBody {}
        );
        KikoCatGallery::deposit<KikoCatMeta, KikoCatBody>(sender_address, nft);
    }

    // ******************** NFT Gallery ********************
    // kiko gallery
    struct KikoCatGallery has key, store {
        items: vector<NFT<KikoCatMeta, KikoCatBody>>,
        box_open_events: Event::EventHandle<BoxOpenEvent>,
    }

    // box open event
    struct BoxOpenEvent has drop, store {
        owner: address,
        id: u64,
    }

    // init kiko gallery
    fun init_gallery(sender: &signer) {
        if (!is_accept<KikoCatMeta, KikoCatBody>(sender_addr)) {
            let gallery = KikoCatGallery {
                items: Vector::empty<NFT<KikoCatMeta, KikoCatBody>>(),
                box_open_events: Event::new_event_handle<BoxOpenEvent>(sender),
            };
            move_to(sender, gallery);
        }
    }

    // deposit to someone
    fun deposit(sender: address, nft: NFT<KikoCatMeta, KikoCatBody>)
    acquires KikoCatGallery {
        let gallery = borrow_global_mut<KikoCatGallery>(sender);
        Vector::push_back(&mut gallery.items, nft);
    }

    // withdraw nft by index
    fun withdraw_by_idx(sender: address, idx: u64): NFT<KikoCatMeta, KikoCatBody>
    acquires KikoCatGallery {
        let gallery = borrow_global_mut<KikoCatGallery>(sender);
        Vector::remove<NFT<KikoCatMeta, KikoCatBody>>(&gallery.items, idx);
    }

    // ******************** NFT Box ********************
    // box
    struct KikoCatBox has copy, drop, store {}

    const PRECISION: u8 = 9;

    struct KikoCatBoxCapability has key, store {
        mint: Token::MintCapability<KikoCatBoxCapability>,
        burn: Token::BurnCapability<KikoCatBoxCapability>,
    }

    // init box
    fun init_box(sender: &signer) {
        Token::register_token<KikoCatBox>(sender, PRECISION);
        let mint_cap = Token::remove_mint_capability<KikoCatBox>(sender);
        let burn_cap = Token::remove_burn_capability<KikoCatBox>(sender);
        move_to(account, KikoCatBoxCapability { mint: mint_cap, burn: burn_cap });
    }

    // mint box
    fun mint_box(sender: &signer, amount: u128)
    acquires KikoCatBoxCapability {
        let cap = borrow_global<KikoCatBoxCapability>(NFT_ADDRESS);
        let token = Token::mint_with_capability<KikoCatBox>(&mut cap.mint, amount);
        Account::deposit_to_self(sender, token);
    }

    // Count all NFTs assigned to an owner
    public fun count_of(owner: address): u64
    acquires KikoCatBoxCapability {
        let gallery = borrow_global_mut<KikoCatBoxCapability>(owner);
        Vector::length(&gallery.items)
    }

    // ******************** NFT public function ********************

    // init nft and box
    public fun init(sender: &signer) {
        assert(Signer::address_of(sender) == NFT_ADDRESS, PERMISSION_DENIED);
        init_nft(sender);
        init_box(sender);
        init_gallery(sender);
        NFTGallery::accept<KikoCatMeta, KikoCatBody>(sender);
    }

    // mint NFT and box
    public fun mint(sender: &signer, name: vector<u8>, image: vector<u8>, description: vector<u8>, meta: vector<u64>)
    acquires KikoCatNFTCapability {
        let signer_address = Signer::address_of(sender);
        assert(signer_address == NFT_ADDRESS, PERMISSION_DENIED);
        mint_nft(signer_address, name, image, description, meta);
        mint_box(sender, 1);
    }

    // open box and get a random NFT
    public fun open_box(sender: &signer) {
        let signer_address = Signer::address_of(sender);
        // get hash last 64 bit and mod nft_size
        let i = 0;
        let x = 0;
        let y = 0;
        let hash = Block::get_parent_hash();
        while (i < 8) {
            x = Vector::pop_back<u8>(&mut hash) as u64;
            y = x << (i * 8) + y;
        };
        let idx = y % count_of(signer_address);
        // get a nft
        let nft = withdraw_by_idx(signer_address, idx);
        NFTGallery::accept<KikoCatMeta, KikoCatBody>(sender);
        NFTGallery::deposit<KikoCatMeta, KikoCatBody>(sender, nft);
    }
}
}
