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

#[test]
fn test_insert_into_empty_tree() {
    let contract_address = deploy_contract("RBTree");
    let dispatcher = IRBTreeDispatcher { contract_address };

    dispatcher.insert(5);
    dispatcher.insert(2);
    dispatcher.insert(1);
    dispatcher.insert(4);
    dispatcher.insert(3);
    dispatcher.insert(7);
    dispatcher.insert(6);
    dispatcher.insert(9);
    dispatcher.insert(15);

    let node_5 = dispatcher.find(5);
    assert(node_5 == 1, 'Error in find(5)');

    let node_2 = dispatcher.find(2);
    assert(node_2 == 2, 'Error in find(2)');

    let node_1 = dispatcher.find(1);
    assert(node_1 == 3, 'Error in find(1)');

    let node_4 = dispatcher.find(4);
    assert(node_4 == 4, 'Error in find(4)');

    let node_3 = dispatcher.find(3);
    assert(node_3 == 5, 'Error in find(3)');

    let node_7 = dispatcher.find(7);
    assert(node_7 == 6, 'Error in find(7)');

    let node_6 = dispatcher.find(6);
    assert(node_6 == 7, 'Error in find(6)');

    let node_9 = dispatcher.find(9);
    assert(node_9 == 8, 'Error in find(9)');

    let node_15 = dispatcher.find(15);
    assert(node_15 == 9, 'Error in find(15)');

    let node_10 = dispatcher.find(10);
    assert(node_10 == 0, 'Error in find(10)');

    let node_11 = dispatcher.find(11);
    assert(node_11 == 0, 'Error in find(11)');

    let node_12 = dispatcher.find(12);
    assert(node_12 == 0, 'Error in find(12)');
}

#[test]
fn test_recoloring_only() {
    let contract_address = deploy_contract("RBTree");
    let dispatcher = IRBTreeDispatcher { contract_address };

    dispatcher.insert(31);

    let node_11 = dispatcher.create_node(11, RED, 1); 
    let node_41 = dispatcher.create_node(41, RED, 1);

    dispatcher.create_node(1, BLACK, node_11);
    let node_27 = dispatcher.create_node(27, BLACK, node_11);

    dispatcher.create_node(36, BLACK, node_41);
    dispatcher.create_node(46, BLACK, node_41);

    dispatcher.create_node(23, RED, node_27);
    dispatcher.create_node(29, RED, node_27);

    // Insert 25
    dispatcher.insert(25);

    let result = dispatcher.get_tree_structure();

    let (value_23, color_23, pos_23) = *result.at(3).at(0);
    let (value_29, color_29, pos_29) = *result.at(3).at(1);

    // 23 should become black
    assert(value_23 == 23, 'Error in value_23');
    assert(color_23 == BLACK, 'Error in color_27');
    assert(pos_23 == 2, 'Error in pos_23');

    // 29 should become black
    assert(value_29 == 29, 'Error in value_29');
    assert(color_29 == BLACK, 'Error in color_29');
    assert(pos_29 == 3, 'Error in pos_29');

    // 27 should become red
    let (value_27, color_27, pos_27) = *result.at(2).at(1);
    
    assert(value_27 == 27, 'Error in value_27');
    assert(color_27 == RED, 'Error in color_27');
    assert(pos_27 == 1, 'Error in pos_27');

    let (value_11, color_11, pos_11) = *result.at(1).at(0);
    let (value_41, color_41, pos_41) = *result.at(1).at(1);

    // 11 should become black
    assert(value_11 == 11, 'Error in value_11');
    assert(color_11 == BLACK, 'Error in color_11');
    assert(pos_11 == 0, 'Error in pos_11');

    // 41 should become black
    assert(value_41 == 41, 'Error in value_41');
    assert(color_41 == BLACK, 'Error in color_41');
    assert(pos_41 == 1, 'Error in pos_41');

    // 31 should be the root
    let (value_31, color_31, pos_31) = *result.at(0).at(0);

    assert(value_31 == 31, 'Error in value 31');
    assert(color_31 == BLACK, 'Error in color 31');
    assert(pos_31 == 0, 'Error in pos 31');

    let is_tree_valid = dispatcher.is_tree_valid();
    assert(is_tree_valid == true, 'Tree invalid');
}