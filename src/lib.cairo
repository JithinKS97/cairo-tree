#[starknet::interface]
pub trait IRBTree<TContractState> {
    fn insert(ref self: TContractState, value: u256);
    fn delete(ref self: TContractState, value: u256);
    fn get_root(self: @TContractState) -> felt252;
    fn traverse_postorder(ref self: TContractState);
    fn get_height(ref self: TContractState) -> u256;
    fn display_tree(ref self: TContractState);
    fn get_tree_structure(ref self: TContractState) -> Array<Array<(u256, u8, u256)>>;
}

const BLACK: u8 = 0;
const RED: u8 = 1;

#[starknet::contract]
mod RBTree {
    use super::{BLACK, RED};
    use core::traits::TryInto;
    use core::traits::IndexView;
    use tree::IRBTree;
    use core::array::ArrayTrait;
    use core::option::OptionTrait;
    #[storage]
    struct Storage {
        root: felt252,
        tree: LegacyMap::<felt252, Node>,
        node_position: LegacyMap::<felt252, u256>,
        next_id: felt252,
    }

    #[derive(Copy, Drop, Serde, starknet::Store)]
    struct Node {
        value: u256,
        left: felt252,
        right: felt252,
        parent: felt252,
        color: u8,
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        self.root.write(0);
        self.next_id.write(1);
    }

    #[abi(embed_v0)]
    impl RBTree of super::IRBTree<ContractState> {
        fn insert(ref self: ContractState, value: u256) {
            let new_node_id = self.create_new_node(value);

            if self.root.read() == 0 {
                self.root.write(new_node_id);
                return;
            }

            self.find_and_attach_node(self.root.read(), new_node_id, value);
            self.balance_after_insertion(new_node_id);
        }

        fn delete(ref self: ContractState, value: u256) {
            let node_to_delete_id = self.find_node(self.root.read(), value);
            if node_to_delete_id == 0 {
                return;
            }
            self.delete_node(node_to_delete_id);
        }

        fn get_root(self: @ContractState) -> felt252 {
            self.root.read()
        }

        fn traverse_postorder(ref self: ContractState) {
            self.traverse_postorder_from_node(self.root.read());
        }

        fn get_height(ref self: ContractState) -> u256 {
            return self.find_height_impl(self.root.read());
        }

        fn display_tree(ref self: ContractState) {
            self.render_tree_structure(self.root.read());
        }

        fn get_tree_structure(ref self: ContractState) -> Array<Array<(u256, u8, u256)>> {
            self.get_tree_structure_impl()
        }
    }

    #[generate_trait]
    impl InternalFunctions of InternalFunctionsTrait {
        fn traverse_postorder_from_node(ref self: ContractState, current_id: felt252) {
            if (current_id == 0) {
                return;
            }
            let current_node = self.tree.read(current_id);

            self.traverse_postorder_from_node(current_node.right);
            println!("{}", current_node.value);
            self.traverse_postorder_from_node(current_node.left);
        }

        fn find_node(ref self: ContractState, current: felt252, value: u256) -> felt252 {
            if current == 0 {
                return 0;
            }

            let node = self.tree.read(current);
            if value == node.value {
                return current;
            } else if value < node.value {
                return self.find_node(node.left, value);
            } else {
                return self.find_node(node.right, value);
            }
        }

        fn find_and_attach_node(
            ref self: ContractState, current_id: felt252, new_node_id: felt252, value: u256
        ) {
            let mut current_node = self.tree.read(current_id);

            if (value == current_node.value) {
                return;
            } else if value < current_node.value {
                if current_node.left == 0 {
                    current_node.left = new_node_id;

                    // update parent
                    self.update_parent(new_node_id, current_id);

                    self.tree.write(current_id, current_node);
                    return;
                }

                self.find_and_attach_node(current_node.left, new_node_id, value);
            } else {
                if current_node.right == 0 {
                    current_node.right = new_node_id;

                    // update parent
                    self.update_parent(new_node_id, current_id);

                    self.tree.write(current_id, current_node);
                    return;
                }

                self.find_and_attach_node(current_node.right, new_node_id, value);
            }
        }

        fn create_new_node(ref self: ContractState, value: u256) -> felt252 {
            let new_node_id = self.next_id.read();
            self.next_id.write(new_node_id + 1);

            let mut color = RED;
            if (self.root.read() == 0) {
                color = BLACK;
            }

            let new_node = Node { value, left: 0, right: 0, parent: 0, color: color };

            self.tree.write(new_node_id, new_node);
            return new_node_id;
        }

        fn is_left_child(ref self: ContractState, node_id: felt252) -> bool {
            let parent_id = self.tree.read(node_id).parent;
            let parent = self.tree.read(parent_id);
            return parent.left == node_id;
        }

        fn update_left(ref self: ContractState, node_id: felt252, left_id: felt252) {
            let mut node = self.tree.read(node_id);
            node.left = left_id;
            self.tree.write(node_id, node);
        }

        fn update_right(ref self: ContractState, node_id: felt252, right_id: felt252) {
            let mut node = self.tree.read(node_id);
            node.right = right_id;
            self.tree.write(node_id, node);
        }

        fn update_parent(ref self: ContractState, node_id: felt252, parent_id: felt252) {
            let mut node = self.tree.read(node_id);
            node.parent = parent_id;
            self.tree.write(node_id, node);
        }

        fn find_height_impl(ref self: ContractState, node_id: felt252) -> u256 {
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

        fn power(ref self: ContractState, base: u256, exponent: u256) -> u256 {
            let mut result = 1;
            let mut i = 0;
            while i < exponent {
                result *= base;
                i += 1;
            };
            return result;
        }

        fn get_parent(ref self: ContractState, node: felt252) -> felt252 {
            if node == 0 {
                0
            } else {
                self.tree.read(node).parent
            }
        }

        fn is_black(ref self: ContractState, node: felt252) -> bool {
            node == 0 || self.tree.read(node).color == BLACK
        }

        fn is_red(ref self: ContractState, node_id: felt252) -> bool {
            if node_id == 0 {
                return false;
            }
            self.tree.read(node_id).color == RED
        }

        fn ensure_root_is_black(ref self: ContractState) {
            let root = self.root.read();
            self.set_color(root, BLACK); // Black
        }

        fn set_color(ref self: ContractState, node_id: felt252, color: u8) {
            if node_id == 0 {
                return; // Can't set color of null node
            }
            let mut node = self.tree.read(node_id);
            node.color = color;
            self.tree.write(node_id, node);
        }
    }

    #[generate_trait]
    impl DeleteBalance of DeleteBalanceTrait {
        fn delete_node(ref self: ContractState, node_to_delete: felt252) {
            if node_to_delete == 0 {
                return; // Node not found
            }

            let mut y = node_to_delete;
            let mut y_original_color = self.tree.read(y).color;
            let mut x: felt252 = 0;
            let mut x_parent: felt252 = 0;

            if self.tree.read(node_to_delete).left == 0 {
                x = self.tree.read(node_to_delete).right;
                x_parent = self.tree.read(node_to_delete).parent;
                self.transplant(node_to_delete, x);
            } else if self.tree.read(node_to_delete).right == 0 {
                x = self.tree.read(node_to_delete).left;
                x_parent = self.tree.read(node_to_delete).parent;
                self.transplant(node_to_delete, x);
            } else {
                y = self.minimum(self.tree.read(node_to_delete).right);
                y_original_color = self.tree.read(y).color;
                x = self.tree.read(y).right;

                if self.tree.read(y).parent == node_to_delete {
                    x_parent = y;
                } else {
                    x_parent = self.tree.read(y).parent;
                    self.transplant(y, x);
                    let mut y_node = self.tree.read(y);
                    y_node.right = self.tree.read(node_to_delete).right;
                    self.tree.write(y, y_node);
                    self.update_parent(self.tree.read(node_to_delete).right, y);
                }

                self.transplant(node_to_delete, y);
                let mut y_node = self.tree.read(y);
                y_node.left = self.tree.read(node_to_delete).left;
                y_node.color = self.tree.read(node_to_delete).color;
                self.tree.write(y, y_node);
                self.update_parent(self.tree.read(node_to_delete).left, y);
            }

            if y_original_color == BLACK {
                self.delete_fixup(x, x_parent);
            }

            // Ensure root is black
            let root = self.root.read();
            if root != 0 {
                self.set_color(root, BLACK);
            }
        }

        fn delete_fixup(ref self: ContractState, mut x: felt252, mut x_parent: felt252) {
            while x != self.root.read()
                && (x == 0 || self.is_black(x)) {
                    if x == self.tree.read(x_parent).left {
                        let mut w = self.tree.read(x_parent).right;
                        if self.is_red(w) {
                            self.set_color(w, BLACK);
                            self.set_color(x_parent, RED);
                            self.rotate_left(x_parent);
                            w = self.tree.read(x_parent).right;
                        }
                        if (self.tree.read(w).left == 0 || self.is_black(self.tree.read(w).left))
                            && (self.tree.read(w).right == 0
                                || self.is_black(self.tree.read(w).right)) {
                            self.set_color(w, RED);
                            x = x_parent;
                            x_parent = self.get_parent(x);
                        } else {
                            if self.tree.read(w).right == 0
                                || self.is_black(self.tree.read(w).right) {
                                if self.tree.read(w).left != 0 {
                                    self.set_color(self.tree.read(w).left, BLACK);
                                }
                                self.set_color(w, RED);
                                self.rotate_right(w);
                                w = self.tree.read(x_parent).right;
                            }
                            self.set_color(w, self.tree.read(x_parent).color);
                            self.set_color(x_parent, BLACK);
                            if self.tree.read(w).right != 0 {
                                self.set_color(self.tree.read(w).right, BLACK);
                            }
                            self.rotate_left(x_parent);
                            x = self.root.read();
                            break;
                        }
                    } else {
                        // Mirror case for right child
                        let mut w = self.tree.read(x_parent).left;
                        if self.is_red(w) {
                            self.set_color(w, BLACK);
                            self.set_color(x_parent, RED);
                            self.rotate_right(x_parent);
                            w = self.tree.read(x_parent).left;
                        }
                        if (self.tree.read(w).right == 0 || self.is_black(self.tree.read(w).right))
                            && (self.tree.read(w).left == 0
                                || self.is_black(self.tree.read(w).left)) {
                            self.set_color(w, RED);
                            x = x_parent;
                            x_parent = self.get_parent(x);
                        } else {
                            if self.tree.read(w).left == 0
                                || self.is_black(self.tree.read(w).left) {
                                if self.tree.read(w).right != 0 {
                                    self.set_color(self.tree.read(w).right, BLACK);
                                }
                                self.set_color(w, RED);
                                self.rotate_left(w);
                                w = self.tree.read(x_parent).left;
                            }
                            self.set_color(w, self.tree.read(x_parent).color);
                            self.set_color(x_parent, BLACK);
                            if self.tree.read(w).left != 0 {
                                self.set_color(self.tree.read(w).left, BLACK);
                            }
                            self.rotate_right(x_parent);
                            x = self.root.read();
                            break;
                        }
                    }
                };
            if x != 0 {
                self.set_color(x, BLACK);
            }
        }

        fn transplant(ref self: ContractState, u: felt252, v: felt252) {
            let u_node = self.tree.read(u);
            if u_node.parent == 0 {
                self.root.write(v);
            } else if self.is_left_child(u) {
                self.update_left(u_node.parent, v);
            } else {
                self.update_right(u_node.parent, v);
            }
            if v != 0 {
                self.update_parent(v, u_node.parent);
            }
        }

        fn minimum(ref self: ContractState, node_id: felt252) -> felt252 {
            let mut current = node_id;
            let mut node = self.tree.read(current);
            while node.left != 0 {
                current = node.left;
                node = self.tree.read(current);
            };
            current
        }
    }

    #[generate_trait]
    impl InsertBalance of InsertBalanceTrait {
        fn balance_after_insertion(ref self: ContractState, node_id: felt252) {
            let mut current = node_id;
            while current != self.root.read()
                && self
                    .is_red(self.tree.read(current).parent) {
                        let parent = self.tree.read(current).parent;
                        let grandparent = self.tree.read(parent).parent;

                        if self.is_left_child(parent) {
                            current = self.balance_left_case(current, parent, grandparent);
                        } else {
                            current = self.balance_right_case(current, parent, grandparent);
                        }
                    };
            self.ensure_root_is_black();
        }

        fn balance_left_case(
            ref self: ContractState, current: felt252, parent: felt252, grandparent: felt252
        ) -> felt252 {
            let uncle = self.tree.read(grandparent).right;

            if self.is_red(uncle) {
                return self.handle_red_uncle(current, parent, grandparent, uncle);
            } else {
                return self.handle_black_uncle_left(current, parent, grandparent);
            }
        }

        fn balance_right_case(
            ref self: ContractState, current: felt252, parent: felt252, grandparent: felt252
        ) -> felt252 {
            let uncle = self.tree.read(grandparent).left;

            if self.is_red(uncle) {
                return self.handle_red_uncle(current, parent, grandparent, uncle);
            } else {
                return self.handle_black_uncle_right(current, parent, grandparent);
            }
        }

        fn handle_red_uncle(
            ref self: ContractState,
            current: felt252,
            parent: felt252,
            grandparent: felt252,
            uncle: felt252
        ) -> felt252 {
            self.set_color(parent, BLACK); // Black
            self.set_color(uncle, BLACK); // Black
            self.set_color(grandparent, RED); // Red
            grandparent
        }

        fn handle_black_uncle_left(
            ref self: ContractState, current: felt252, parent: felt252, grandparent: felt252
        ) -> felt252 {
            let mut new_current = current;
            if !self.is_left_child(current) {
                new_current = parent;
                self.rotate_left(new_current);
            }
            let new_parent = self.tree.read(new_current).parent;
            self.set_color(new_parent, BLACK); // Black
            self.set_color(grandparent, RED); // Red
            self.rotate_right(grandparent);
            new_current
        }

        fn handle_black_uncle_right(
            ref self: ContractState, current: felt252, parent: felt252, grandparent: felt252
        ) -> felt252 {
            let mut new_current = current;
            if self.is_left_child(current) {
                new_current = parent;
                self.rotate_right(new_current);
            }
            let new_parent = self.tree.read(new_current).parent;
            self.set_color(new_parent, BLACK); // Black
            self.set_color(grandparent, RED); // Red
            self.rotate_left(grandparent);
            new_current
        }
    }

    #[generate_trait]
    impl TreeRotations of TreeRotationsTrait {
        fn rotate_right(ref self: ContractState, y: felt252) -> felt252 {
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

        fn rotate_left(ref self: ContractState, x: felt252) -> felt252 {
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
    }

    #[generate_trait]
    impl PrintTree of PrintTreeTrait {
        fn get_filled_position_in_levels(ref self: ContractState) -> Array<Array<(felt252, u256)>> {
            let mut queue: Array<(felt252, u256)> = ArrayTrait::new();
            let root_id = self.root.read();
            let initial_level = 0;
            let mut current_level = 0;
            let mut filled_position_in_levels: Array<Array<(felt252, u256)>> = ArrayTrait::new();
            let mut filled_position_in_level: Array<(felt252, u256)> = ArrayTrait::new();

            self.collect_position_and_levels_of_nodes(root_id, 0, initial_level);
            queue.append((root_id, 0));

            while !queue
                .is_empty() {
                    let (node_id, level) = queue.pop_front().unwrap();
                    let node = self.tree.read(node_id);

                    if level > current_level {
                        current_level = level;
                        filled_position_in_levels.append(filled_position_in_level);
                        filled_position_in_level = ArrayTrait::new();
                    }

                    let position = self.node_position.read(node_id);

                    filled_position_in_level.append((node_id, position));

                    if node.left != 0 {
                        queue.append((node.left, current_level + 1));
                    }

                    if node.right != 0 {
                        queue.append((node.right, current_level + 1));
                    }
                };
            filled_position_in_levels.append(filled_position_in_level);
            return filled_position_in_levels;
        }

        fn render_tree_structure(ref self: ContractState, node_id: felt252) {
            println!("");

            let filled_position_in_levels = self.get_filled_position_in_levels();

            let root_id = self.root.read();

            if root_id == 0 {
                println!("Tree is empty");
                return;
            }

            let no_of_levels = self.find_height_impl(root_id) - 1;

            if (no_of_levels == 0) {
                let root_node = self.tree.read(root_id);
                if (root_node.value < 10) {
                    print!("0");
                }
                println!("{}B", root_node.value);
                return;
            }

            let mut middle_spacing = 3 * self.power(2, no_of_levels)
                + 5 * self.power(2, no_of_levels - 1)
                + 3 * (self.power(2, no_of_levels - 1) - 1);
            let mut begin_spacing = (middle_spacing - 3) / 2;

            let mut queue: Array<(felt252, u256)> = ArrayTrait::new();
            queue.append((root_id, 0));

            let all_nodes = self.construct_list(@filled_position_in_levels);

            let mut i = 0;

            while i < all_nodes
                .len()
                .try_into()
                .unwrap() {
                    let level = all_nodes.at(i.try_into().unwrap());
                    let mut j = 0;

                    while j < level
                        .len() {
                            let node_id = level.at(j.try_into().unwrap());

                            if (j == 0) {
                                self.print_n_spaces(begin_spacing);
                            } else {
                                if (i == no_of_levels) {
                                    if (j % 2 == 0) {
                                        self.print_n_spaces(3);
                                    } else {
                                        self.print_n_spaces(5);
                                    }
                                } else {
                                    self.print_n_spaces(middle_spacing);
                                }
                            }

                            if (*node_id == 0) {
                                print!("...");
                            } else {
                                let node = self.tree.read(*node_id);
                                let node_value = node.value;
                                let node_color = node.color;

                                if (node_value < 10) {
                                    print!("0");
                                }

                                print!("{}", node_value);

                                if (node_color == BLACK) {
                                    print!("B");
                                } else {
                                    print!("R");
                                }
                            }

                            j += 1;
                        };

                    if (i < no_of_levels) {
                        middle_spacing = begin_spacing;
                        begin_spacing = (begin_spacing - 3) / 2;
                    }

                    println!("");
                    i += 1;
                };

            println!("");
        }

        fn get_tree_structure_impl(ref self: ContractState) -> Array<Array<(u256, u8, u256)>> {
            if(self.root.read() == 0) {
                return ArrayTrait::new();
            }
            let filled_position_in_levels_original = self.get_filled_position_in_levels();
            let mut filled_position_in_levels: Array<Array<(u256, u8, u256)>> = ArrayTrait::new();
            let mut filled_position_in_level: Array<(u256, u8, u256)> = ArrayTrait::new();
            let mut i = 0;
            while i < filled_position_in_levels_original
                .len() {
                    let level = filled_position_in_levels_original.at(i.try_into().unwrap());
                    let mut j = 0;
                    while j < level
                        .len() {
                            let (node_id, position) = level.at(j.try_into().unwrap());
                            let node = self.tree.read(*node_id);
                            filled_position_in_level.append((node.value, node.color, *position));
                            j += 1;
                        };
                    filled_position_in_levels.append(filled_position_in_level);
                    filled_position_in_level = ArrayTrait::new();
                    i += 1;
                };
            return filled_position_in_levels;
        }

        fn construct_list(
            ref self: ContractState, filled_levels_info: @Array<Array<(felt252, u256)>>
        ) -> Array<Array<felt252>> {
            let no_of_levels = self.get_height();
            let mut i = 0;
            let mut final_list: Array<Array<felt252>> = ArrayTrait::new();
            while i < no_of_levels {
                let filled_levels = filled_levels_info.at(i.try_into().unwrap());
                let final_levels = self.get_level_list(i, filled_levels);
                final_list.append(final_levels);
                i = i + 1;
            };
            return final_list;
        }

        fn get_level_list(
            ref self: ContractState, level: u256, filled_levels: @Array<(felt252, u256)>
        ) -> Array<felt252> {
            let mut i = 0;
            let max_no_of_nodes = self.power(2, level);
            let mut final_list: Array<felt252> = ArrayTrait::new();
            while i < max_no_of_nodes {
                let node_id = self.get_if_node_id_present(filled_levels, i);
                final_list.append(node_id);
                i += 1;
            };
            return final_list;
        }

        fn get_if_node_id_present(
            ref self: ContractState, filled_levels: @Array<(felt252, u256)>, position: u256
        ) -> felt252 {
            let mut i = 0;
            let mut found_node_id = 0;
            // iterate through filled_levels
            while i < filled_levels
                .len() {
                    let (node_id, pos) = filled_levels.at(i.try_into().unwrap());
                    if (pos == @position) {
                        found_node_id = *node_id;
                    }
                    i += 1;
                };

            return found_node_id;
        }

        fn collect_position_and_levels_of_nodes(
            ref self: ContractState, node_id: felt252, position: u256, level: u256
        ) {
            if node_id == 0 {
                return;
            }

            let node = self.tree.read(node_id);

            self.node_position.write(node_id, position);

            self.collect_position_and_levels_of_nodes(node.left, position * 2, level + 1);
            self.collect_position_and_levels_of_nodes(node.right, position * 2 + 1, level + 1);
        }

        fn print_n_spaces(ref self: ContractState, n: u256) {
            let mut i = 0;
            while i < n {
                print!(" ");
                i += 1;
            }
        }
    }
}

