//! new-transaction
//! account: kiko, 0x111
//! sender: kiko
address kiko = {{kiko}};
script {
    use 0x111::KikoCat01;

    fun init(sender: signer) {
        KikoCat01::init(sender);
    }
}
// check: EXECUTED

//! new-transaction
//! sender: kiko
address kiko = {{kiko}};
script {
    use 0x111::KikoCat01;

    fun init(sender: signer) {
        KikoCat01::mint(
            sender,
            b"kiko cat",
            b"abcdefg",
            b"this is a cat",
            b"red",
            b"kaffe",
            b"hat",
        );
    }
}
// check: EXECUTED

//! new-transaction
//! sender: kiko
address kiko = {{kiko}};
script {
    use 0x111::KikoCat01;

    fun init(sender: signer) {
        KikoCat01::open_box(sender);
    }
}
// check: EXECUTED


//! new-transaction
//! sender: kiko
address kiko = {{kiko}};
script {
    use 0x1::STC::STC;
    use 0x300::NFTScripts;
    use 0x111::KikoCat01::{KikoCatMeta,KikoCatBody};

    fun nft_sell(sender: signer) {
        //Dummy::mint_token<ETH>(&sender, 1 * MULTIPLE);
        NFTScripts::nft_sell<KikoCatMeta, KikoCatBody,STC>(sender, 0 ,1000000000);
    }
}
// check: EXECUTED