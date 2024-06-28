#[starknet::interface]
pub trait ITree<TContractState> {
    fn insert(ref self: TContractState, value: felt252);
    fn get_root(self: @TContractState) -> felt252;
}

#[starknet::contract]
mod Tree {
    #[storage]
    struct Storage {
        root: felt252, 
    }

    #[abi(embed_v0)]
    impl Tree of super::ITree<ContractState> {
        fn insert(ref self: ContractState, value: felt252) {
            assert(value != 0, 'Value cannot be 0');
            self.root.write(value);
        }

        fn get_root(self: @ContractState) -> felt252 {
            self.root.read()
        }
    }
}
