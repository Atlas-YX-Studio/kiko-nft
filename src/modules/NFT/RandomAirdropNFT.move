address 0x6a1aFD96c67ef709E533730F6aEA2353 {
module sdfsdf {

    use 0x1::Block;
    use 0x1::Signer;
    use 0x1::Vector;
    use 0x1::NFTGallery;
    use 0x1::Option::{Self, Option};
    use 0x1::NFT::{NFT};

    const SELF_ADDRESS: address = @0x6a1aFD96c67ef709E533730F6aEA2353;

    struct NFTInfo<NFTMeta: store, NFTBody: store> has key, store {
        items: vector<NFT<NFTMeta, NFTBody>>,
        items_v2: Option<NFT<NFTMeta, NFTBody>>
    }

    public(script) fun deposit_to<NFTMeta: copy + store + drop, NFTBody: store + drop>(sender: signer, to: address) acquires NFTInfo {
        assert(SELF_ADDRESS == Signer::address_of(&sender), 100000002);
        let hash = Block::get_parent_hash();
        let k = 0u64;
        let i = 0;
        while (i < 8) {
            let tmp = (Vector::pop_back<u8>(&mut hash) as u128);
            k = (tmp << (i * 8) as u64) + k;
            i = i + 1;
        };
        let nft_info = borrow_global_mut<NFTInfo<NFTMeta, NFTBody>>(SELF_ADDRESS);
        let len = Vector::length(&nft_info.items);
        let idx = k % len;
        let nft = Vector::swap_remove<NFT<NFTMeta, NFTBody>>(&mut nft_info.items, idx);
        NFTGallery::deposit_to<NFTMeta, NFTBody>(to, nft);
    }

    public(script) fun deposit<NFTMeta: copy + store + drop, NFTBody: store + drop>(sender: signer, ids: vector<u64>) acquires NFTInfo {
        let nft_info = borrow_global_mut<NFTInfo<NFTMeta, NFTBody>>(SELF_ADDRESS);
        let len = Vector::length(&ids);
        let i = 0u64;        
        while (i < len) {
            let id = Vector::borrow(&ids, i);
            let option_nft = NFTGallery::withdraw<NFTMeta, NFTBody>(&sender, *id);
            assert(Option::is_some<NFT<NFTMeta, NFTBody>>(&option_nft), 100000001);
            let nft = Option::extract(&mut option_nft);
            Vector::push_back(&mut nft_info.items, nft);
            Option::destroy_none(option_nft);
            i = i + 1;
        };
    }
}
}