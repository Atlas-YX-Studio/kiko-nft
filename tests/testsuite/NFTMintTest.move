//! new-transaction
//! account: kiko, 0x111
//! sender: kiko
address kiko = {{kiko}};
script {
    use 0x333::NFTScripts;

    fun init(sender: signer) {
        NFTScripts::init_nft(sender);
    }
}
// check: EXECUTED

//! new-transaction
//! sender: kiko
address kiko = {{kiko}};
script {
    use 0x333::NFTScripts;

    fun init(sender: signer) {
        NFTScripts::mint_nft(
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
    use 0x333::NFTScripts;

    fun init(sender: signer) {
        NFTScripts::open_box(sender);
    }
}
// check: EXECUTED
