address 0x111 {
module KikoCat {

    // NFT自定义描述信息
    struct KikoCatMeta has copy, store, drop {
        owner: address,
        background: u64,
        breed: u64,
        decorate: u64,
    }

    // NFT资源信息
    struct KikoCatBody has copy, store, drop {}

    // NFT所属系列额外信息
    struct KikoCatTypeInfo has copy, store, drop {}

    // 盲盒
    struct KikoCatBox has copy, drop, store {}

    // 铸造NFT+box
    public fun mint() {

    }

    // 打开盲盒，随机获取NFT
    public fun open_box() {

    }

}
}
