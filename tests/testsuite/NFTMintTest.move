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

