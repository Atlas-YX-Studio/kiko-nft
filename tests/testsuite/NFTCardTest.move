//! new-transaction
//! account: kiko, 0x69F1E543A3BeF043B63BEd825fcd2cf6, 10000000000 0x1::STC::STC
//! sender: kiko
address kiko = {{kiko}};
script {
    use 0x69F1E543A3BeF043B63BEd825fcd2cf6::KikoCatElement05;

    fun init(sender: signer) {
        KikoCatElement05::f_init_with_image(&sender, b"kiko cat", b"www.baidu.com", b"this is a cat");
        KikoCatElement05::f_mint_with_image(&sender,
            b"kiko cat", b"www.baidu.com", b"this is a cat", b"background",
            1, b"Bored", 1
        );
        KikoCatElement05::f_mint_with_image(&sender,
            b"kiko cat", b"www.baidu.com", b"this is a cat", b"background",
            2, b"Bored", 1
        );
        KikoCatElement05::f_mint_with_image(&sender,
            b"kiko cat", b"www.baidu.com", b"this is a cat", b"background",
            3, b"Bored", 1
        );
        KikoCatElement05::f_mint_with_image(&sender,
            b"kiko cat", b"www.baidu.com", b"this is a cat", b"background",
            4, b"Bored", 1
        );
        KikoCatElement05::f_mint_with_image(&sender,
            b"kiko cat", b"www.baidu.com", b"this is a cat", b"background",
            1, b"Bored", 1
        );
        KikoCatElement05::f_mint_with_image(&sender,
            b"kiko cat", b"www.baidu.com", b"this is a cat", b"background",
            2, b"Bored", 1
        );
        KikoCatElement05::f_mint_with_image(&sender,
            b"kiko cat", b"www.baidu.com", b"this is a cat", b"background",
            3, b"Bored", 1
        );
        KikoCatElement05::f_mint_with_image(&sender,
            b"kiko cat", b"www.baidu.com", b"this is a cat", b"background",
            4, b"Bored", 1
        );
        KikoCatElement05::f_mint_with_image(&sender,
            b"kiko cat", b"www.baidu.com", b"this is a cat", b"background",
            1, b"Bored", 1
        );
        KikoCatElement05::f_mint_with_image(&sender,
            b"kiko cat", b"www.baidu.com", b"this is a cat", b"background",
            2, b"Bored", 1
        );
        KikoCatElement05::f_mint_with_image(&sender,
            b"kiko cat", b"www.baidu.com", b"this is a cat", b"background",
            3, b"Bored", 1
        );
        KikoCatElement05::f_mint_with_image(&sender,
            b"kiko cat", b"www.baidu.com", b"this is a cat", b"background",
            4, b"Bored", 1
        );
    }
}
// check: EXECUTED

//! new-transaction
//! sender: kiko
address kiko = {{kiko}};
script {
    //    use 0x1::Debug;
    use 0x69F1E543A3BeF043B63BEd825fcd2cf6::KikoCatCard05;

    fun mint(sender: signer) {
        KikoCatCard05::init_with_image(sender, b"kiko cat", b"www.baidu.com", b"this is a cat", 1000000000);
    }
}
// check: EXECUTED

//! new-transaction
//! sender: kiko
address kiko = {{kiko}};
script {
    //    use 0x1::Debug;
    use 0x69F1E543A3BeF043B63BEd825fcd2cf6::KikoCatCard05;

    fun mint(sender: signer) {
        KikoCatCard05::composite_custom_card(sender,
            b"kiko cat", b"www.baidu.com", b"this is a cat", b"miner", b"test1", 1,
            1, 2, 3, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        );
    }
}
// check: EXECUTED

//! new-transaction
//! sender: kiko
address kiko = {{kiko}};
script {
    //    use 0x1::Debug;
    use 0x69F1E543A3BeF043B63BEd825fcd2cf6::KikoCatCard05;

    fun mint(sender: signer) {
        KikoCatCard05::composite_custom_card(sender,
            b"kiko cat", b"www.baidu.com", b"this is a cat", b"miner", b"test1", 1,
            5, 6, 7, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        );
    }
}
// check: EXECUTED

//! new-transaction
//! sender: kiko
address kiko = {{kiko}};
script {
    //    use 0x1::Debug;
    use 0x69F1E543A3BeF043B63BEd825fcd2cf6::KikoCatCard05;

    fun mint(sender: signer) {
        KikoCatCard05::composite_custom_card(sender,
            b"kiko cat", b"www.baidu.com", b"this is a cat", b"miner", b"test1", 1,
            9, 10, 11, 12, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        );
    }
}
// check: EXECUTED

//! new-transaction
//! account: alice, 10000000000 0x1::STC::STC
//! sender: alice
script {
    //    use 0x1::Debug;
    use 0x1::NFTGallery;
    use 0x69F1E543A3BeF043B63BEd825fcd2cf6::KikoCatCard05;

    fun mint(sender: signer) {
        NFTGallery::accept<KikoCatCard05::KikoCatMeta, KikoCatCard05::KikoCatBody>(&sender);
    }
}
// check: EXECUTED

//! new-transaction
//! sender: kiko
address alice = {{alice}};
script {
    //    use 0x1::Debug;
    use 0x1::NFTGallery;
    use 0x69F1E543A3BeF043B63BEd825fcd2cf6::KikoCatCard05;

    fun mint(sender: signer) {
        NFTGallery::transfer<KikoCatCard05::KikoCatMeta, KikoCatCard05::KikoCatBody>(&sender, 2, @alice);
    }
}
// check: EXECUTED

//! new-transaction
//! sender: alice
script {
    //    use 0x1::Debug;
    use 0x69F1E543A3BeF043B63BEd825fcd2cf6::KikoCatCard05;

    fun mint(sender: signer) {
        KikoCatCard05::resolve_card(sender, 2);
    }
}
// check: EXECUTED
