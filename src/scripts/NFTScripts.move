address 0x333 {
module NFTScripts {

    use 0x111::KikoCat01;
    use 0x222::NFTMarket;

    public(script) fun init_nft(sender: signer) {
        KikoCat01::init(&sender);
    }

    public(script) fun mint_nft(
        sender: signer,
        name: vector<u8>,
        image: vector<u8>,
        description: vector<u8>,
        background: vector<u8>,
        breed: vector<u8>,
        decorate: vector<u8>,
    ) {
        KikoCat01::mint(
            &sender,
            name,
            image,
            description,
            background,
            breed,
            decorate,
        );
    }

    public(script) fun open_box(sender: signer) {
        KikoCat01::open_box(&sender);
    }

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

}
}