#[starknet::interface]
pub trait ITree<TContractState> {
    fn insert(ref self: TContractState, value: u64);
    fn get_root(self: @TContractState) -> u64;
    fn get_value(self: @TContractState, node_id: u64) -> u64;
    fn traverse(ref self: TContractState);
    fn rotate_left(ref self: TContractState, y: u64);
    fn rotate_right(ref self: TContractState, y: u64);
    fn rotate_left_right(ref self: TContractState, z: u64);
    fn rotate_right_left(ref self: TContractState, z: u64);
    fn get_left_child(self: @TContractState, node_id: u64) -> u64;
    fn get_right_child(self: @TContractState, node_id: u64) -> u64;
    fn get_height(ref self: TContractState) -> u64;
    fn print_tree(ref self: TContractState);
}

#[starknet::contract]
mod Tree {
    use core::option::OptionTrait;
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
            let new_node_id = self.create_new_node(value);

            if self.root.read() == 0 {
                self.root.write(new_node_id);
                return;
            }

            self.insert_recursive(self.root.read(), new_node_id, value);
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

        fn rotate_left(ref self: ContractState, y: u64) {
            self.rotate_left_impl(y);
        }

        fn rotate_right(ref self: ContractState, y: u64) {
            self.rotate_right_impl(y);
        }

        fn rotate_left_right(ref self: ContractState, z: u64) {
            self.rotate_left_right_impl(z);
        }

        fn rotate_right_left(ref self: ContractState, z: u64) {
            self.rotate_right_left_impl(z);
        }

        fn get_left_child(self: @ContractState, node_id: u64) -> u64 {
            let node_id = self.tree.read(node_id).left;
            return self.tree.read(node_id).value;
        }

        fn get_right_child(self: @ContractState, node_id: u64) -> u64 {
            let node_id = self.tree.read(node_id).right;
            return self.tree.read(node_id).value;
        }

        fn get_height(ref self: ContractState) -> u64 {
            return self.find_height_impl(self.root.read());
        }

        fn print_tree(ref self: ContractState) {
            self.print_tree_impl(self.root.read());
        }
    }

    #[generate_trait]
    impl InternalFunctions of InternalFunctionsTrait {
        fn insert_recursive(
            ref self: ContractState, current_id: u64, new_node_id: u64, value: u64
        ) {
            let mut current_node = self.tree.read(current_id);

            if value < current_node.value {
                if current_node.left == 0 {
                    current_node.left = new_node_id;

                    // update parent
                    self.update_parent(new_node_id, current_id);

                    self.tree.write(current_id, current_node);
                    return;
                }

                self.insert_recursive(current_node.left, new_node_id, value);
            } else {
                if current_node.right == 0 {
                    current_node.right = new_node_id;

                    // update parent
                    self.update_parent(new_node_id, current_id);

                    self.tree.write(current_id, current_node);
                    return;
                }

                self.insert_recursive(current_node.right, new_node_id, value);
            }
        }

        fn create_new_node(ref self: ContractState, value: u64) -> u64 {
            let new_node_id = self.next_id.read();
            self.next_id.write(new_node_id + 1);

            let new_node = Node { value, left: 0, right: 0, parent: 0, };

            self.tree.write(new_node_id, new_node);
            return new_node_id;
        }

        fn traverse_recursive(ref self: ContractState, current_id: u64) {
            if (current_id == 0) {
                return;
            }
            let current_node = self.tree.read(current_id);

            // in-order traversal prints in ascending order
            self.traverse_recursive(current_node.left);
            println!("{}", current_node.value);
            self.traverse_recursive(current_node.right);
        }

        fn is_left_child(ref self: ContractState, node_id: u64) -> bool {
            let parent_id = self.tree.read(node_id).parent;
            let parent = self.tree.read(parent_id);
            return parent.left == node_id;
        }
    }

    #[generate_trait]
    impl TreeRotations of TreeRotationsTrait {
        //     y       
        //    / \
        //   x   C
        //  / \
        // A   B
        //
        //     to
        //    
        //     x
        //    / \
        //   A   y
        //      / \
        //     B   C
        fn rotate_right_impl(ref self: ContractState, y: u64) -> u64 {
            let x = self.tree.read(y).left;
            let B = self.tree.read(x).right;

            // Perform rotation
            self.update_right(x, y);
            self.update_left(y, B);

            // Update parent pointers
            let y_parent = self.tree.read(y).parent;
            self.update_parent(x, y_parent);
            self.update_parent(y, x);
            if B != 0 {
                self.update_parent(B, y);
            }

            // Update root if necessary
            if y_parent == 0 {
                self.root.write(x);
            } else {
                let mut parent = self.tree.read(y_parent);
                if parent.left == y {
                    parent.left = x;
                } else {
                    parent.right = x;
                }
                self.tree.write(y_parent, parent);
            }

            // Return the new root of the subtree
            x
        }

        //    x       
        //   / \
        //  A   y
        //     / \
        //    B   C
        //
        //     to
        //    
        //     y
        //    / \
        //   x   C
        //  / \ 
        // A   B
        fn rotate_left_impl(ref self: ContractState, x: u64) -> u64 {
            let y = self.tree.read(x).right;
            let B = self.tree.read(y).left;

            // Perform rotation
            self.update_left(y, x);
            self.update_right(x, B);

            // Update parent pointers
            let x_parent = self.tree.read(x).parent;
            self.update_parent(y, x_parent);
            self.update_parent(x, y);
            if B != 0 {
                self.update_parent(B, x);
            }

            // Update root if necessary
            if x_parent == 0 {
                self.root.write(y);
            } else {
                let mut parent = self.tree.read(x_parent);
                if parent.left == x {
                    parent.left = y;
                } else {
                    parent.right = y;
                }
                self.tree.write(x_parent, parent);
            }

            // Return the new root of the subtree
            y
        }

        //   z
        //  /
        // y
        //  \
        //   x
        //  
        //  to
        //
        //   x
        //  / \
        // y   z
        fn rotate_left_right_impl(ref self: ContractState, z: u64) -> u64 {
            let y = self.tree.read(z).left;
            self.rotate_left_impl(y);
            self.rotate_right_impl(z)
        }

        //    z
        //     \
        //      y
        //     /
        //    x
        //
        //   to
        // 
        //    x
        //   / \
        //  z   y
        fn rotate_right_left_impl(ref self: ContractState, z: u64) -> u64 {
            let y = self.tree.read(z).right;
            self.rotate_right_impl(y);
            self.rotate_left_impl(z)
        }

        // Helper functions
        fn update_left(ref self: ContractState, node_id: u64, left_id: u64) {
            let mut node = self.tree.read(node_id);
            node.left = left_id;
            self.tree.write(node_id, node);
        }

        fn update_right(ref self: ContractState, node_id: u64, right_id: u64) {
            let mut node = self.tree.read(node_id);
            node.right = right_id;
            self.tree.write(node_id, node);
        }

        fn update_parent(ref self: ContractState, node_id: u64, parent_id: u64) {
            let mut node = self.tree.read(node_id);
            node.parent = parent_id;
            self.tree.write(node_id, node);
        }
    }

    #[generate_trait]
    impl PrintTree of PrintTreeTrait {
        fn find_height_impl(ref self: ContractState, node_id: u64) -> u64 {
            let node = self.tree.read(node_id);

            if (node_id == 0) {
                return 0;
            } else {
                let left_height = self.find_height_impl(node.left);
                let right_height = self.find_height_impl(node.right);

                if (left_height > right_height) {
                    return left_height + 1;
                } else {
                    return right_height + 1;
                }
            }
        }

        // Prints tree in the below format
        //
        //                          00B                         
        //            00B                         00B    
        //     00B           00B           00B           00B 
        // 00B     00B   00B     00B   00B     00B   00B     00B
        fn print_tree_impl(ref self: ContractState, node_id: u64) {
            let root_id = self.root.read();
            let no_of_levels = self.find_height_impl(root_id) - 1;

            let mut middle_spacing = 3*self.power(2, no_of_levels) + 5*self.power(2, no_of_levels-1) + 3 * (self.power(2, no_of_levels-1) - 1);
            let mut begin_spacing = (middle_spacing - 3)/2;
            
            println!("");

            if root_id == 0 {
                println!("Tree is empty");
                return;
            }

            let mut queue: Array<(u64, u64)> = ArrayTrait::new();
            queue.append((root_id, 0));
            let mut current_level = 0;
            
            while !queue.is_empty() {
                let (node_id, level) = queue.pop_front().unwrap();
                let node = self.tree.read(node_id);

                if(current_level == 0) {
                    self.print_n_spaces(begin_spacing);
                }

                if level > current_level {
                    println!("");
                    middle_spacing = begin_spacing;
                    begin_spacing = (begin_spacing - 3)/2;
                    self.print_n_spaces(begin_spacing);
                    current_level = level;
                } else {
                    if(current_level == no_of_levels) {
                        if(self.is_left_child(node_id)) {
                            self.print_n_spaces(3);
                        } else {
                            self.print_n_spaces(5);
                        }
                    } else if(current_level != 0) {
                        self.print_n_spaces(middle_spacing);
                    }
                }

                if(node.value<10) {
                    print!("0");
                }
                
                print!("{}B", node.value);  

                if node.left != 0 {
                    queue.append((node.left, current_level + 1));
                }

                if node.right != 0 {
                    queue.append((node.right, current_level + 1));
                }
            };
            println!("");
            
        }

        fn print_n_spaces(ref self: ContractState, n: u64) {
            let mut i = 0;
            while i < n {
                print!(" ");
                i += 1;
            }
        }

        fn power(ref self: ContractState, base: u64, exponent: u64) -> u64 {
            let mut result = 1;
            let mut i = 0;
            while i < exponent {
                result *= base;
                i += 1;
            };
            return result;
        }
    }
}

