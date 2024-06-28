#[starknet::interface]
pub trait ITree<TContractState> {
    fn insert(ref self: TContractState, value: u64);
    fn get_root(self: @TContractState) -> u64;
    fn get_value(self: @TContractState, node_id: u64) -> u64;
    fn traverse(ref self: TContractState);
}

#[starknet::contract]
mod Tree {
    #[storage]
    struct Storage {
        root: u64, 
        tree: LegacyMap::<u64, Node>,
        next_id: u64,
    }

    #[derive(Copy, Drop, Serde, starknet::Store)]
    struct Node {
        value: u64,
        left: u64,
        right: u64,
        parent: u64,
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        self.root.write(0);
        self.next_id.write(1);
    }

    #[abi(embed_v0)]
    impl Tree of super::ITree<ContractState> {
        fn insert(ref self: ContractState, value: u64) {
            let new_node_id = self.next_id.read();
            self.next_id.write(new_node_id + 1);

            let new_node = Node {
                value,
                left: 0,
                right: 0,
                parent: 0,
            };

            self.tree.write(new_node_id, new_node);

            if self.root.read() == 0 {
                self.root.write(new_node_id);
                return;
            }

            self.insert_recursive(self.root.read().try_into().unwrap(), new_node_id, value);
        }

        fn get_root(self: @ContractState) -> u64 {
            self.root.read()
        }

        fn get_value(self: @ContractState, node_id: u64) -> u64 {
            self.tree.read(node_id).value
        }

        fn traverse(ref self: ContractState) {
            self.traverse_recursive(self.root.read());
        }
    }

    #[generate_trait]
    impl InternalFunctions of InternalFunctionsTrait {
        fn insert_recursive(
            ref self: ContractState, 
            current_id: u64, 
            new_node_id: u64, 
            value: u64
        ) {
            let mut current_node = self.tree.read(current_id);

            if value < current_node.value {
                if current_node.left == 0 {
                    current_node.left = new_node_id;
                    self.tree.write(current_id, current_node);
                    return;
                }

                self.insert_recursive(current_node.left, new_node_id, value);
            } else {
                if current_node.right == 0 {
                    current_node.right = new_node_id;

                    self.tree.write(current_id, current_node);
                    return;
                }

                self.insert_recursive(current_node.right, new_node_id, value);
            }
        }

        fn traverse_recursive(ref self: ContractState, current_id: u64) {
            if(current_id == 0) {
                return;
            }
            let current_node = self.tree.read(current_id);
            self.traverse_recursive(current_node.left);
            println!("Node value: {}", current_node.value);
            self.traverse_recursive(current_node.right);
        }
    }
}
