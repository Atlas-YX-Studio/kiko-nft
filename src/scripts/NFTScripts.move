address 0x333 {
module NFTScripts {
    use 0x111::KikoCat01;

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

}
}