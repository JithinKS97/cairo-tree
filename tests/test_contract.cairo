use starknet::ContractAddress;

use snforge_std::{declare, ContractClassTrait};

use tree::IRBTreeSafeDispatcher;
use tree::IRBTreeSafeDispatcherTrait;
use tree::IRBTreeDispatcher;
use tree::IRBTreeDispatcherTrait;
use core::pedersen::pedersen;

fn deploy_contract(name: ByteArray) -> ContractAddress {
    let contract = declare(name).unwrap();
    let (contract_address, _) = contract.deploy(@ArrayTrait::new()).unwrap();
    contract_address
}

// Test insertion

const BLACK: bool = false;
const RED: bool = true;

// #[test]
// fn test_insert_into_empty_tree() {
//     let contract_address = deploy_contract("RBTree");
//     let dispatcher = IRBTreeDispatcher { contract_address };

//     dispatcher.insert(5);
//     dispatcher.insert(2);
//     dispatcher.insert(1);
//     dispatcher.insert(4);
//     dispatcher.insert(3);
//     dispatcher.insert(7);
//     dispatcher.insert(6);
//     dispatcher.insert(9);
//     dispatcher.insert(15);

//     let node_5 = dispatcher.find(5);
//     assert(node_5 == 1, 'Error in find(5)');

//     let node_2 = dispatcher.find(2);
//     assert(node_2 == 2, 'Error in find(2)');

//     let node_1 = dispatcher.find(1);
//     assert(node_1 == 3, 'Error in find(1)');

//     let node_4 = dispatcher.find(4);
//     assert(node_4 == 4, 'Error in find(4)');

//     let node_3 = dispatcher.find(3);
//     assert(node_3 == 5, 'Error in find(3)');

//     let node_7 = dispatcher.find(7);
//     assert(node_7 == 6, 'Error in find(7)');

//     let node_6 = dispatcher.find(6);
//     assert(node_6 == 7, 'Error in find(6)');

//     let node_9 = dispatcher.find(9);
//     assert(node_9 == 8, 'Error in find(9)');

//     let node_15 = dispatcher.find(15);
//     assert(node_15 == 9, 'Error in find(15)');

//     let node_10 = dispatcher.find(10);
//     assert(node_10 == 0, 'Error in find(10)');

//     let node_11 = dispatcher.find(11);
//     assert(node_11 == 0, 'Error in find(11)');

//     let node_12 = dispatcher.find(12);
//     assert(node_12 == 0, 'Error in find(12)');
// }

// #[test]
// fn test_recoloring_only() {
//     let contract_address = deploy_contract("RBTree");
//     let dispatcher = IRBTreeDispatcher { contract_address };

//     dispatcher.insert(31);

//     let node_11 = dispatcher.create_node(11, RED, 1); 
//     let node_41 = dispatcher.create_node(41, RED, 1);

//     dispatcher.create_node(1, BLACK, node_11);
//     let node_27 = dispatcher.create_node(27, BLACK, node_11);

//     dispatcher.create_node(36, BLACK, node_41);
//     dispatcher.create_node(46, BLACK, node_41);

//     dispatcher.create_node(23, RED, node_27);
//     dispatcher.create_node(29, RED, node_27);

//     // Insert 25
//     dispatcher.insert(25);

//     let result = dispatcher.get_tree_structure();

//     let (value_23, color_23, pos_23) = *result.at(3).at(0);
//     let (value_29, color_29, pos_29) = *result.at(3).at(1);

//     // 23 should become black
//     assert(value_23 == 23, 'Error in value_23');
//     assert(color_23 == BLACK, 'Error in color_27');
//     assert(pos_23 == 2, 'Error in pos_23');

//     // 29 should become black
//     assert(value_29 == 29, 'Error in value_29');
//     assert(color_29 == BLACK, 'Error in color_29');
//     assert(pos_29 == 3, 'Error in pos_29');

//     // 27 should become red
//     let (value_27, color_27, pos_27) = *result.at(2).at(1);
    
//     assert(value_27 == 27, 'Error in value_27');
//     assert(color_27 == RED, 'Error in color_27');
//     assert(pos_27 == 1, 'Error in pos_27');

//     let (value_11, color_11, pos_11) = *result.at(1).at(0);
//     let (value_41, color_41, pos_41) = *result.at(1).at(1);

//     // 11 should become black
//     assert(value_11 == 11, 'Error in value_11');
//     assert(color_11 == BLACK, 'Error in color_11');
//     assert(pos_11 == 0, 'Error in pos_11');

//     // 41 should become black
//     assert(value_41 == 41, 'Error in value_41');
//     assert(color_41 == BLACK, 'Error in color_41');
//     assert(pos_41 == 1, 'Error in pos_41');

//     // 31 should be the root
//     let (value_31, color_31, pos_31) = *result.at(0).at(0);

//     assert(value_31 == 31, 'Error in value 31');
//     assert(color_31 == BLACK, 'Error in color 31');
//     assert(pos_31 == 0, 'Error in pos 31');

//     let is_tree_valid = dispatcher.is_tree_valid();
//     assert(is_tree_valid == true, 'Tree invalid');
// }

// #[test]
// fn test_recoloring_two() {
//     let contract_address = deploy_contract("RBTree");
//     let dispatcher = IRBTreeDispatcher { contract_address };

//     dispatcher.insert(31);

//     let node_11 = dispatcher.create_node(11, RED, 1); 
//     let node_41 = dispatcher.create_node(41, RED, 1);

//     dispatcher.create_node(1, BLACK, node_11);
//     dispatcher.create_node(27, BLACK, node_11);

//     let node_36 = dispatcher.create_node(36, BLACK, node_41);
//     dispatcher.create_node(46, BLACK, node_41);

//     dispatcher.create_node(33, RED, node_36);
//     dispatcher.create_node(38, RED, node_36);

//     dispatcher.insert(40);

//     let result = dispatcher.get_tree_structure();

//     let (value_40, color_40, pos_40) = *result.at(4).at(0);
//     let (value_33, color_33, pos_33) = *result.at(3).at(0);
//     let (value_38, color_38, pos_38) = *result.at(3).at(1);
//     let (value_36, color_36, pos_36) = *result.at(2).at(2);
//     let (value_41, color_41, pos_41) = *result.at(1).at(1);
//     let (value_46, color_46, pos_46) = *result.at(2).at(3);
//     let (value_11, color_11, pos_11) = *result.at(1).at(0);
//     let (value_31, color_31, pos_31) = *result.at(0).at(0);

//     assert(value_40 == 40, 'Error in value_40');
//     assert(color_40 == RED, 'Error in color_40');
//     assert(pos_40 == 11, 'Error in pos_40');

//     assert(value_33 == 33, 'Error in value_33');
//     assert(color_33 == BLACK, 'Error in color_33');
//     assert(pos_33 == 4, 'Error in pos_33');

//     assert(value_38 == 38, 'Error in value_38');
//     assert(color_38 == BLACK, 'Error in color_38');
//     assert(pos_38 == 5, 'Error in pos_38');

//     assert(value_36 == 36, 'Error in value_36');
//     assert(color_36 == RED, 'Error in color_36');
//     assert(pos_36 == 2, 'Error in pos_36');

//     assert(value_41 == 41, 'Error in value_41');
//     assert(color_41 == BLACK, 'Error in color_41');
//     assert(pos_41 == 1, 'Error in pos_41');

//     assert(value_46 == 46, 'Error in value_46');
//     assert(color_46 == BLACK, 'Error in color_46');
//     assert(pos_46 == 3, 'Error in pos_46');

//     assert(value_11 == 11, 'Error in value_11');
//     assert(color_11 == BLACK, 'Error in color_11');
//     assert(pos_11 == 0, 'Error in pos_11');

//     assert(value_31 == 31, 'Error in value_31');
//     assert(color_31 == BLACK, 'Error in color_31');
//     assert(pos_31 == 0, 'Error in pos_31');

//     let is_tree_valid = dispatcher.is_tree_valid();
//     assert(is_tree_valid == true, 'Tree invalid');
// }

// #[test]
// fn test_right_rotation() {
//     let contract_address = deploy_contract("RBTree");
//     let dispatcher = IRBTreeDispatcher { contract_address };

//     dispatcher.insert(21);

//     let node_1 = dispatcher.create_node(1, BLACK, 1); 
//     let node_31 = dispatcher.create_node(31, BLACK, 1);

//     dispatcher.create_node(18, RED, node_1);

//     dispatcher.create_node(1, BLACK, node_1);
//     dispatcher.create_node(18, RED, node_1);

//     dispatcher.create_node(26, RED, node_31);

//     // Insert 24
//     dispatcher.insert(24);

//     let result = dispatcher.get_tree_structure();

//     let (value_24, color_24, pos_24) = *result.at(2).at(1);
//     let (value_26, color_26, pos_26) = *result.at(1).at(1);
//     let (value_31, color_31, pos_31) = *result.at(2).at(2);

//     assert(value_24 == 24, 'Error in value_24');
//     assert(color_24 == RED, 'Error in color_24');
//     assert(pos_24 == 2, 'Error in pos_24');

//     // Rotated at 26 with 26 as root
//     assert(value_26 == 26, 'Error in value_26');
//     assert(color_26 == BLACK, 'Error in color_26');
//     assert(pos_26 == 1, 'Error in pos_26');

//     assert(value_31 == 31, 'Error in value_31');
//     assert(color_31 == RED, 'Error in color_31');
//     assert(pos_31 == 3, 'Error in pos_31');
// }

// #[test]
// fn test_left_rotation_no_sibling() {
//     let contract_address = deploy_contract("RBTree");
//     let dispatcher = IRBTreeDispatcher { contract_address };

//     dispatcher.insert(10);

//     let node_7 = dispatcher.create_node(7, BLACK, 1);
//     dispatcher.create_node(20, BLACK, 1);

//     dispatcher.create_node(8, RED, node_7);

//     dispatcher.create_node(7, BLACK, node_7);
//     dispatcher.create_node(8, RED, node_7);

//     // Insert 9
//     dispatcher.insert(9);

//     let result = dispatcher.get_tree_structure();

//     let (value_8, color_8, pos_8) = *result.at(1).at(0);
//     let (value_7, color_7, pos_7) = *result.at(2).at(0);
//     let (value_9, color_9, pos_9) = *result.at(2).at(1);

//     assert(value_8 == 8, 'Error in value_8');
//     assert(color_8 == BLACK, 'Error in color_8');
//     assert(pos_8 == 0, 'Error in pos_8');

//     // Rotated at 8 with 8 as new root of subtree
//     assert(value_7 == 7, 'Error in value_7');
//     assert(color_7 == RED, 'Error in color_7');
//     assert(pos_7 == 0, 'Error in pos_7');

//     assert(value_9 == 9, 'Error in value_9');
//     assert(color_9 == RED, 'Error in color_9');
//     assert(pos_9 == 1, 'Error in pos_9');

//     let is_tree_valid = dispatcher.is_tree_valid();
//     assert(is_tree_valid == true, 'Tree invalid');
// }

// #[test]
// fn test_right_rotation_no_sibling_left_subtree() {
//     let contract_address = deploy_contract("RBTree");
//     let dispatcher = IRBTreeDispatcher { contract_address };

//     dispatcher.insert(23);

//     let node_3 = dispatcher.create_node(3, BLACK, 1);
//     let node_33 = dispatcher.create_node(33, BLACK, 1);

//     dispatcher.create_node(2, RED, node_3);
//     dispatcher.create_node(28, RED, node_33);

//     // Insert 1
//     dispatcher.insert(1);

//     let result = dispatcher.get_tree_structure();

//     let (value_1, color_1, pos_1) = *result.at(2).at(0);
//     let (value_2, color_2, pos_2) = *result.at(1).at(0);
//     let (value_3, color_3, pos_3) = *result.at(2).at(1);

//     assert(value_1 == 1, 'Error in value_1');
//     assert(color_1 == RED, 'Error in color_1');
//     assert(pos_1 == 0, 'Error in pos_1');

//     // Rotated at 2 with 2 as new root of subtree
//     assert(value_2 == 2, 'Error in value_2');
//     assert(color_2 == BLACK, 'Error in color_2');
//     assert(pos_2 == 0, 'Error in pos_2');

//     assert(value_3 == 3, 'Error in value_3');
//     assert(color_3 == RED, 'Error in color_3');
//     assert(pos_3 == 1, 'Error in pos_3');
// }

// #[test]
// fn test_left_right_rotation_no_sibling() {
//     let contract_address = deploy_contract("RBTree");
//     let dispatcher = IRBTreeDispatcher { contract_address };

//     dispatcher.insert(21);
//     let node_1 = dispatcher.create_node(1, BLACK, 1);
//     dispatcher.create_node(18, RED, node_1);
//     let node_31 = dispatcher.create_node(31, BLACK, 1);
//     dispatcher.create_node(26, RED, node_31);

//     // Insert 24
//     dispatcher.insert(28);

//     let result = dispatcher.get_tree_structure();

//     let (value_26, color_26, pos_26) = *result.at(2).at(1);
//     let (value_28, color_28, pos_28) = *result.at(1).at(1);
//     let (value_31, color_31, pos_31) = *result.at(2).at(2);

//     assert(value_26 == 26, 'Error in value_26');
//     assert(color_26 == RED, 'Error in color_26');
//     assert(pos_26 == 2, 'Error in pos_26');

//     // Rotated at 26 with 26 as new root of subtree
//     assert(value_28 == 28, 'Error in value_28');
//     assert(color_28 == BLACK, 'Error in color_28');
//     assert(pos_28 == 1, 'Error in pos_28');

//     assert(value_31 == 31, 'Error in value_31');
//     assert(color_31 == RED, 'Error in color_31');
//     assert(pos_31 == 3, 'Error in pos_31');

//     let is_tree_valid = dispatcher.is_tree_valid();
//     assert(is_tree_valid == true, 'Tree invalid');
// }

// #[test]
// fn test_right_left_rotation_no_sibling() {
//     let contract_address = deploy_contract("RBTree");
//     let dispatcher = IRBTreeDispatcher { contract_address };

//     dispatcher.insert(21);
//     let node_1 = dispatcher.create_node(1, BLACK, 1);
//     dispatcher.create_node(18, RED, node_1);
//     let node_31 = dispatcher.create_node(31, BLACK, 1);
//     dispatcher.create_node(18, RED, node_1);
//     dispatcher.create_node(26, RED, node_31);

//     // Insert 13
//     dispatcher.insert(13);
//     let result = dispatcher.get_tree_structure();

//     let (value_13, color_13, pos_13) = *result.at(1).at(0);
//     let (value_18, color_18, pos_18) = *result.at(2).at(1);
//     let (value_1, color_1, pos_1) = *result.at(2).at(0);

//     assert(value_13 == 13, 'Error in value_13');
//     assert(color_13 == BLACK, 'Error in color_13');
//     assert(pos_13 == 0, 'Error in pos_13');

//     // Rotated at 18 with 18 as new root of subtree
//     assert(value_18 == 18, 'Error in value_18');
//     assert(color_18 == RED, 'Error in color_18');
//     assert(pos_18 == 1, 'Error in pos_18');

//     assert(value_1 == 1, 'Error in value_1');
//     assert(color_1 == RED, 'Error in color_1');
//     assert(pos_1 == 0, 'Error in pos_1');
// }

// #[test]
// fn test_recolor_lr() {
//     let contract_address = deploy_contract("RBTree");
//     let dispatcher = IRBTreeDispatcher { contract_address };

//     dispatcher.insert(31);
//     let node_11 = dispatcher.create_node(11, RED, 1);
//     let node_41 = dispatcher.create_node(41, BLACK, 1);
//     dispatcher.create_node(1, BLACK, node_11);
//     let node_27 = dispatcher.create_node(27, BLACK, node_11);
//     dispatcher.create_node(22, RED, node_27);
//     dispatcher.create_node(30, RED, node_27);
//     dispatcher.create_node(36, RED, node_41);
//     dispatcher.create_node(51, RED, node_41);

//     // Insert 25
//     dispatcher.insert(25);  

//     let result = dispatcher.get_tree_structure();

//     let (value_27, color_27, pos_27) = *result.at(0).at(0);
//     let (value_31, color_31, pos_31) = *result.at(1).at(1);
//     let (value_22, color_22, pos_22) = *result.at(2).at(1);
//     let (value_25, color_25, pos_25) = *result.at(3).at(0);
//     let (value_30, color_30, pos_30) = *result.at(2).at(2);

//     assert(value_27 == 27, 'Error in value_27');
//     assert(color_27 == BLACK, 'Error in color_27');
//     assert(pos_27 == 0, 'Error in pos_27');

//     assert(value_31 == 31, 'Error in value_31');
//     assert(color_31 == RED, 'Error in color_31');
//     assert(pos_31 == 1, 'Error in pos_31');

//     assert(value_22 == 22, 'Error in value_22');
//     assert(color_22 == BLACK, 'Error in color_22');
//     assert(pos_22 == 1, 'Error in pos_22');

//     assert(value_25 == 25, 'Error in value_25');
//     assert(color_25 == RED, 'Error in color_25');
//     assert(pos_25 == 3, 'Error in pos_25');

//     assert(value_30 == 30, 'Error in value_30');
//     assert(color_30 == BLACK, 'Error in color_30');
//     assert(pos_30 == 2, 'Error in pos_30');

//     let is_tree_valid = dispatcher.is_tree_valid();
//     assert(is_tree_valid == true, 'Tree invalid');
// }

// #[test]
// fn test_functional_test_build_tree() {
//     let contract_address = deploy_contract("RBTree");
//     let dispatcher = IRBTreeDispatcher { contract_address };

//     dispatcher.insert(2);
//     dispatcher.insert(1);
//     dispatcher.insert(4);
//     dispatcher.insert(5);
//     dispatcher.insert(9);
//     dispatcher.insert(3);
//     dispatcher.insert(6);
//     dispatcher.insert(7);
//     dispatcher.insert(15);

//     let result = dispatcher.get_tree_structure();

//     let (value_5, color_5, pos_5) = *result.at(0).at(0);
//     let (value_2, color_2, pos_2) = *result.at(1).at(0);
//     let (value_7, color_7, pos_7) = *result.at(1).at(1);
//     let (value_1, color_1, pos_1) = *result.at(2).at(0);
//     let (value_4, color_4, pos_4) = *result.at(2).at(1);
//     let (value_6, color_6, pos_6) = *result.at(2).at(2);
//     let (value_9, color_9, pos_9) = *result.at(2).at(3);
//     let (value_3, color_3, pos_3) = *result.at(3).at(0);
//     let (value_15, color_15, pos_15) = *result.at(3).at(1);

//     assert(value_5 == 5, 'Error in value_5');
//     assert(color_5 == BLACK, 'Error in color_5');
//     assert(pos_5 == 0, 'Error in pos_5');

//     assert(value_2 == 2, 'Error in value_2');
//     assert(color_2 == RED, 'Error in color_2');
//     assert(pos_2 == 0, 'Error in pos_2');

//     assert(value_7 == 7, 'Error in value_7');
//     assert(color_7 == RED, 'Error in color_7');
//     assert(pos_7 == 1, 'Error in pos_7');

//     assert(value_1 == 1, 'Error in value_1');
//     assert(color_1 == BLACK, 'Error in color_1');
//     assert(pos_1 == 0, 'Error in pos_1');

//     assert(value_4 == 4, 'Error in value_4');
//     assert(color_4 == BLACK, 'Error in color_4');
//     assert(pos_4 == 1, 'Error in pos_4');

//     assert(value_6 == 6, 'Error in value_6');
//     assert(color_6 == BLACK, 'Error in color_6');
//     assert(pos_6 == 2, 'Error in pos_6');

//     assert(value_9 == 9, 'Error in value_9');
//     assert(color_9 == BLACK, 'Error in color_9');
//     assert(pos_9 == 3, 'Error in pos_9');
    
//     assert(value_3 == 3, 'Error in value_3');
//     assert(color_3 == RED, 'Error in color_3');
//     assert(pos_3 == 2, 'Error in pos_3');

//     assert(value_15 == 15, 'Error in value_15');
//     assert(color_15 == RED, 'Error in color_15');
//     assert(pos_15 == 7, 'Error in pos_15');
    
//     let is_tree_valid = dispatcher.is_tree_valid();
//     assert(is_tree_valid == true, 'Tree invalid');
// }

// #[test]
// fn test_right_left_rotation_after_recolor() {
//     let contract_address = deploy_contract("RBTree");
//     let dispatcher = IRBTreeDispatcher { contract_address };

//     dispatcher.insert(10);
    
//     dispatcher.create_node(5, BLACK, 1);
//     let node_20 = dispatcher.create_node(20, RED, 1);
    
//     let node_15 = dispatcher.create_node(15, BLACK, node_20);
//     dispatcher.create_node(25, BLACK, node_20);
    
//     dispatcher.create_node(12, RED, node_15);
//     dispatcher.create_node(17, RED, node_15);

//     // Insert 19
//     dispatcher.insert(19);

//     let result = dispatcher.get_tree_structure();

//     let (value_15, color_15, pos_15) = *result.at(0).at(0);
//     let (value_10, color_10, pos_10) = *result.at(1).at(0);
//     let (value_20, color_20, pos_20) = *result.at(1).at(1);
//     let (value_5, color_5, pos_5) = *result.at(2).at(0);
//     let (value_12, color_12, pos_12) = *result.at(2).at(1);
//     let (value_17, color_17, pos_17) = *result.at(2).at(2);
//     let (value_25, color_25, pos_25) = *result.at(2).at(3);
//     let (value_19, color_19, pos_19) = *result.at(3).at(0);

//     assert(value_15 == 15, 'Error in value_15');
//     assert(color_15 == BLACK, 'Error in color_15');
//     assert(pos_15 == 0, 'Error in pos_15');

//     assert(value_10 == 10, 'Error in value_10');
//     assert(color_10 == RED, 'Error in color_10');
//     assert(pos_10 == 0, 'Error in pos_10');

//     assert(value_20 == 20, 'Error in value_20');
//     assert(color_20 == RED, 'Error in color_20');
//     assert(pos_20 == 1, 'Error in pos_20');

//     assert(value_5 == 5, 'Error in value_5');
//     assert(color_5 == BLACK, 'Error in color_5');
//     assert(pos_5 == 0, 'Error in pos_5');

//     assert(value_12 == 12, 'Error in value_12');
//     assert(color_12 == BLACK, 'Error in color_12');
//     assert(pos_12 == 1, 'Error in pos_12');

//     assert(value_17 == 17, 'Error in value_17');
//     assert(color_17 == BLACK, 'Error in color_17');
//     assert(pos_17 == 2, 'Error in pos_17');

//     assert(value_25 == 25, 'Error in value_25');
//     assert(color_25 == BLACK, 'Error in color_25');
//     assert(pos_25 == 3, 'Error in pos_25');

//     assert(value_19 == 19, 'Error in value_19');
//     assert(color_19 == RED, 'Error in color_19');
//     assert(pos_19 == 5, 'Error in pos_19');

//     let is_tree_valid = dispatcher.is_tree_valid();
//     assert(is_tree_valid == true, 'Tree invalid');
// }

// #[test]
// fn test_right_rotation_after_recolor() {
//     let contract_address = deploy_contract("RBTree");
//     let dispatcher = IRBTreeDispatcher { contract_address };

//     dispatcher.insert(33);
//     let node_13 = dispatcher.create_node(13, RED, 1);
//     let node_43 = dispatcher.create_node(43, BLACK, 1);

//     let node_3 = dispatcher.create_node(3, BLACK, node_13);
//     dispatcher.create_node(29, BLACK, node_13);
//     dispatcher.create_node(38, RED, node_43);
//     dispatcher.create_node(48, RED, node_43);

//     dispatcher.create_node(2, RED, node_3);
//     dispatcher.create_node(4, RED, node_3);

//     dispatcher.insert(1);

//     let result = dispatcher.get_tree_structure();

//     let (value_1, color_1, pos_1) = *result.at(3).at(0);
//     let (value_2, color_2, pos_2) = *result.at(2).at(0);
//     let (value_3, color_3, pos_3) = *result.at(1).at(0);
//     let (value_4, color_4, pos_4) = *result.at(2).at(1);
//     let (value_13, color_13, pos_13) = *result.at(0).at(0);
//     let (value_33, color_33, pos_33) = *result.at(1).at(1);
//     let (value_29, color_29, pos_29) = *result.at(2).at(2);

//     assert(value_1 == 1, 'Error in value_1');
//     assert(color_1 == RED, 'Error in color_1');
//     assert(pos_1 == 0, 'Error in pos_1');

//     assert(value_2 == 2, 'Error in value_2');
//     assert(color_2 == BLACK, 'Error in color_2');
//     assert(pos_2 == 0, 'Error in pos_2');

//     assert(value_3 == 3, 'Error in value_3');
//     assert(color_3 == RED, 'Error in color_3');
//     assert(pos_3 == 0, 'Error in pos_3');

//     assert(value_4 == 4, 'Error in value_4');
//     assert(color_4 == BLACK, 'Error in color_4');
//     assert(pos_4 == 1, 'Error in pos_4');

//     assert(value_13 == 13, 'Error in value_13');
//     assert(color_13 == BLACK, 'Error in color_13');
//     assert(pos_13 == 0, 'Error in pos_13');

//     assert(value_33 == 33, 'Error in value_33');
//     assert(color_33 == RED, 'Error in color_33');
//     assert(pos_33 == 1, 'Error in pos_33');

//     assert(value_29 == 29, 'Error in value_29');
//     assert(color_29 == BLACK, 'Error in color_29');
//     assert(pos_29 == 2, 'Error in pos_29');

//     let is_tree_valid = dispatcher.is_tree_valid();
//     assert(is_tree_valid == true, 'Tree invalid');
// }   

// // Test deletion

// #[test]
// fn test_deletion_root() {
//     let contract_address = deploy_contract("RBTree");
//     let dispatcher = IRBTreeDispatcher { contract_address };

//     dispatcher.insert(5);
//     dispatcher.insert(3);
//     dispatcher.insert(8);

//     // Delete the root (5)
//     dispatcher.delete(5);

//     let result = dispatcher.get_tree_structure();

//     let (value_8, color_8, pos_8) = *result.at(0).at(0);
//     let (value_3, color_3, pos_3) = *result.at(1).at(0);

//     assert(value_8 == 8, 'Error in value_8');
//     assert(color_8 == BLACK, 'Error in color_8');
//     assert(pos_8 == 0, 'Error in pos_8');

//     assert(value_3 == 3, 'Error in value_3');
//     assert(color_3 == RED, 'Error in color_3');
//     assert(pos_3 == 0, 'Error in pos_3');

//     let is_tree_valid = dispatcher.is_tree_valid();
//     assert(is_tree_valid == true, 'Tree invalid');
// }

// #[test]
// fn test_deletion_root_2_nodes() {
//     let contract_address = deploy_contract("RBTree");
//     let dispatcher = IRBTreeDispatcher { contract_address };

//     dispatcher.insert(5);
//     dispatcher.insert(8);

//     // Delete the root (5)
//     dispatcher.delete(5);

//     let result = dispatcher.get_tree_structure();

//     let (value_8, color_8, pos_8) = *result.at(0).at(0);

//     assert(value_8 == 8, 'Error in value_8');
//     assert(color_8 == BLACK, 'Error in color_8');
//     assert(pos_8 == 0, 'Error in pos_8');

//     // Check that the tree only has one node
//     assert(result.len() == 1, 'Tree should have only one level');
//     assert(result.at(0).len() == 1, 'Root should be the only node');

//     let is_tree_valid = dispatcher.is_tree_valid();
//     assert(is_tree_valid == true, 'Tree invalid');
// }

// #[test]
// fn test_delete_single_child() {
//     let contract_address = deploy_contract("RBTree");
//     let dispatcher = IRBTreeDispatcher { contract_address };

//     dispatcher.insert(5);
//     dispatcher.insert(1);
//     dispatcher.insert(6);

//     // Delete node 6
//     dispatcher.delete(6);

//     let result = dispatcher.get_tree_structure();

//     let (value_5, color_5, pos_5) = *result.at(0).at(0);
//     let (value_1, color_1, pos_1) = *result.at(1).at(0);

//     assert(value_5 == 5, 'val5 err');
//     assert(color_5 == BLACK, 'col5 err');
//     assert(pos_5 == 0, 'pos5 err');

//     assert(value_1 == 1, 'val1 err');
//     assert(color_1 == RED, 'col1 err');
//     assert(pos_1 == 0, 'pos1 err');

//     // Check that the tree has only two nodes
//     assert(result.len() == 2, '2lvl err');
//     assert(result.at(0).len() == 1, 'root err');
//     assert(result.at(1).len() == 1, 'child err');

//     let is_tree_valid = dispatcher.is_tree_valid();
//     assert(is_tree_valid == true, 'inv tree');
// }

#[test]
fn test_delete_single_deep_child() {
    let contract_address = deploy_contract("RBTree");
    let dispatcher = IRBTreeDispatcher { contract_address };

    dispatcher.insert(20);
    dispatcher.insert(10);
    dispatcher.insert(38);
    dispatcher.insert(5);
    dispatcher.insert(15);
    dispatcher.insert(28);
    let node_48 = dispatcher.insert(48);
    dispatcher.insert(23);
    dispatcher.insert(29);
    let node_41 = dispatcher.insert(41);
    dispatcher.insert(49);

    dispatcher.delete(49);

    let (left_child, right_child) = dispatcher.get_children(node_48);

    assert(left_child == node_41, 'Error in l child 48');
    assert(right_child == 0, 'Error in r child 48');

    let (_, color, _) = dispatcher.get_node(node_48);
    assert(color == BLACK, 'Error in color 48');

    let is_tree_valid = dispatcher.is_tree_valid();
    assert(is_tree_valid == true, 'Error in tree');
}