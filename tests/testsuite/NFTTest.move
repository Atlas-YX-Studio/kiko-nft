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
            b"Red",
            b"Gray",
            b"Blue Sky",
            b"Bored",
            b"Banana",
            b"Mask",
            b"Glasses",
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
        KikoCat01::mint(
            sender,
            b"kiko cat",
            b"abcdefg",
            b"this is a cat",
            b"Red",
            b"Gray",
            b"Blue Sky",
            b"Bored",
            b"Banana",
            b"Mask",
            b"Glasses",
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
        KikoCat01::mint(
            sender,
            b"kiko cat",
            b"abcdefg",
            b"this is a cat",
            b"Red",
            b"Gray",
            b"Blue Sky",
            b"Bored",
            b"Banana",
            b"Mask",
            b"Glasses",
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
    use 0x111::KikoCat01;

    fun init(sender: signer) {
        KikoCat01::open_box(sender);
    }
}
// check: EXECUTED

//! new-transaction
//! account: maket, 0x222
//! sender: maket
address maket = {{maket}};
script {
    use 0x333::NFTScripts;
    fun init_config(sender: signer) {
        NFTScripts::init_config(sender, 1 ,1);
    }
}
// check: EXECUTED

//! new-transaction
//! sender: maket
address maket = {{maket}};
script {
    use 0x1::STC::STC;
    use 0x333::NFTScripts;
    use 0x111::KikoCat01::{KikoCatMeta,KikoCatBody,KikoCatBox};
    fun init_config(sender: signer) {
        NFTScripts::init_market<KikoCatMeta, KikoCatBody, KikoCatBox, STC>(sender, @0x111);
    }
}
// check: EXECUTED

//! new-transaction
//! sender: kiko
address kiko = {{kiko}};
script {
    use 0x1::STC::STC;
    use 0x333::NFTScripts;
    use 0x111::KikoCat01::{KikoCatMeta,KikoCatBody};
    const MULTIPLE: u128 = 1000000000;

    fun nft_sell(sender: signer) {
        //Dummy::mint_token<ETH>(&sender, 1 * MULTIPLE);
        NFTScripts::nft_sell<KikoCatMeta, KikoCatBody,STC>(sender, 1 ,2 * MULTIPLE);
    }
}
// check: EXECUTED


//! new-transaction
//! sender: kiko
address kiko = {{kiko}};
script {
    use 0x1::STC::STC;
    use 0x333::NFTScripts;
    use 0x111::KikoCat01::{KikoCatMeta,KikoCatBody};
    const MULTIPLE: u128 = 1000000000;

    fun nft_sell(sender: signer) {
        //Dummy::mint_token<ETH>(&sender, 1 * MULTIPLE);
        NFTScripts::nft_sell<KikoCatMeta, KikoCatBody,STC>(sender, 2 ,2 * MULTIPLE);
    }
}
// check: EXECUTED


//! new-transaction
//! sender: kiko
address kiko = {{kiko}};
script {
    use 0x1::STC::STC;
    use 0x333::NFTScripts;
    use 0x111::KikoCat01::{KikoCatMeta,KikoCatBody};
    const MULTIPLE: u128 = 1000000000;

    fun nft_sell(sender: signer) {
        //Dummy::mint_token<ETH>(&sender, 1 * MULTIPLE);
        NFTScripts::nft_sell<KikoCatMeta, KikoCatBody,STC>(sender, 3 ,2 * MULTIPLE);
    }
}
// check: EXECUTED

//! new-transaction
//! account: tom, 1000000000 0x1::STC::STC
//! sender: tom
address tom = {{tom}};
script {
    use 0x1::Account;
    use 0x1::Debug;
    use 0x1::STC::STC;
    use 0x333::NFTScripts;
    use 0x111::KikoCat01::{KikoCatMeta,KikoCatBody};

    const MULTIPLE: u128 = 1000000000;

    fun nft_bid(sender: signer) {
        NFTScripts::nft_bid<KikoCatMeta, KikoCatBody,STC>(sender, 1 ,1 * MULTIPLE);
        let balance_stc = Account::balance<STC>(@tom);
        Debug::print<u128>(&balance_stc);
    }
}
// check: EXECUTED

//! new-transaction
//! sender: kiko
address kiko = {{kiko}};
script {
    use 0x1::Account;
    use 0x1::Debug;
    use 0x1::STC::STC;
    use 0x333::NFTScripts;
    use 0x111::KikoCat01::{KikoCatMeta,KikoCatBody};

    fun nft_accept_bid(sender: signer) {
        //Dummy::mint_token<ETH>(&sender, 1 * MULTIPLE);
        NFTScripts::nft_accept_bid<KikoCatMeta, KikoCatBody,STC>(sender, 1);

        let balance_stc = Account::balance<STC>(@kiko);
        Debug::print<u128>(&balance_stc);
    }
}
// check: EXECUTED

//! new-transaction
//! account: alise, 3000000000 0x1::STC::STC
//! sender: alise
address alise = {{alise}};
script {
    use 0x1::Account;
    use 0x1::Debug;
    use 0x1::STC::STC;
    use 0x333::NFTScripts;
    use 0x111::KikoCat01::{KikoCatMeta,KikoCatBody};

    const MULTIPLE: u128 = 1000000000;

    fun nft_bid(sender: signer) {
        NFTScripts::nft_bid<KikoCatMeta, KikoCatBody,STC>(sender, 2 ,2 * MULTIPLE);
        let balance_stc = Account::balance<STC>(@alise);
        Debug::print<u128>(&balance_stc);
    }
}
// check: EXECUTED

//! new-transaction
//! account: xin, 2000000000 0x1::STC::STC
//! sender: xin
address xin = {{xin}};
script {
    use 0x1::Account;
    use 0x1::Debug;
    use 0x1::STC::STC;
    use 0x333::NFTScripts;
    use 0x111::KikoCat01::{KikoCatMeta,KikoCatBody};

    fun nft_buy(sender: signer) {
        NFTScripts::nft_buy<KikoCatMeta, KikoCatBody,STC>(sender, 3);
        let balance_stc = Account::balance<STC>(@xin);
        Debug::print<u128>(&balance_stc);
    }
}