address 0x111 {
module KikoCat01 {
    use 0x1::Signer;
    use 0x1::Event;
    use 0x1::Block;
    use 0x1::Vector;
    use 0x1::Token;
    use 0x1::Account;
    use 0x1::NFT::{Self, NFT};
    use 0x1::NFTGallery;

    const NFT_ADDRESS: address = @0x111;

    const PERMISSION_DENIED: u64 = 100001;

    // ******************** NFT ********************
    // NFT extra meta
    struct KikoCatMeta has copy, store, drop {
        background: vector<u8>,
        fur: vector<u8>,
        clothes: vector<u8>,
        facial_expression: vector<u8>,
        head: vector<u8>,
        accessories: vector<u8>,
        eyes: vector<u8>,
    }

    // NFT body
    struct KikoCatBody has copy, store, drop {}

    // NFT extra type info
    struct KikoCatTypeInfo has copy, store, drop {}

    struct KikoCatNFTCapability has key {
        mint: NFT::MintCapability<KikoCatMeta>,
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
        fur: vector<u8>,
        clothes: vector<u8>,
        facial_expression: vector<u8>,
        head: vector<u8>,
        accessories: vector<u8>,
        eyes: vector<u8>,
    ) acquires KikoCatNFTCapability, KikoCatGallery {
        let sender_address = Signer::address_of(sender);
        let cap = borrow_global_mut<KikoCatNFTCapability>(sender_address);
        let metadata = NFT::new_meta_with_image_data(name, image, description);
        let nft = NFT::mint_with_cap<KikoCatMeta, KikoCatBody, KikoCatTypeInfo>(
            sender_address,
            &mut cap.mint,
            metadata,
            KikoCatMeta {
                background,
                fur,
                clothes,
                facial_expression,
                head,
                accessories,
                eyes,
            },
            KikoCatBody {}
        );
        deposit(sender_address, nft);
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
        if (!exists<KikoCatGallery>(Signer::address_of(sender))) {
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
        Vector::remove<NFT<KikoCatMeta, KikoCatBody>>(&mut gallery.items, idx)
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

    // init nft and box
    public(script) fun init(sender: signer) {
        assert(Signer::address_of(&sender) == NFT_ADDRESS, PERMISSION_DENIED);
        init_nft(&sender);
        init_box(&sender);
        init_gallery(&sender);
        NFTGallery::accept<KikoCatMeta, KikoCatBody>(&sender);
    }

    // mint NFT and box
    public(script) fun mint(
        sender: signer,
        name: vector<u8>,
        image: vector<u8>,
        description: vector<u8>,
        background: vector<u8>,
        fur: vector<u8>,
        clothes: vector<u8>,
        facial_expression: vector<u8>,
        head: vector<u8>,
        accessories: vector<u8>,
        eyes: vector<u8>,
    ) acquires KikoCatNFTCapability, KikoCatBoxCapability, KikoCatGallery {
        let sender_address = Signer::address_of(&sender);
        assert(sender_address == NFT_ADDRESS, PERMISSION_DENIED);
        mint_nft(&sender, name, image, description, background, fur, clothes, facial_expression, head, accessories, eyes);
        mint_box(&sender, 1);
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
        // get a nft
        let nft = withdraw_by_idx(NFT_ADDRESS, idx);
        NFTGallery::accept<KikoCatMeta, KikoCatBody>(&sender);
        NFTGallery::deposit<KikoCatMeta, KikoCatBody>(&sender, nft);
    }
}
}
