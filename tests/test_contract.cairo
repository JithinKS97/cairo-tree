use starknet::ContractAddress;

use snforge_std::{declare, ContractClassTrait};

use tree::IRBTreeSafeDispatcher;
use tree::IRBTreeSafeDispatcherTrait;
use tree::IRBTreeDispatcher;
use tree::IRBTreeDispatcherTrait;

fn deploy_contract(name: ByteArray) -> ContractAddress {
    let contract = declare(name).unwrap();
    let (contract_address, _) = contract.deploy(@ArrayTrait::new()).unwrap();
    contract_address
}

// Test insertion

#[test]
fn test_insert_into_empty_tree() {
    let contract_address = deploy_contract("RBTree");

    let dispatcher = IRBTreeDispatcher { contract_address };

    dispatcher.insert(10);
    let (value_10, color_10, pos_10) = *dispatcher.get_tree_structure().at(0).at(0);
    
    assert(value_10 == 10, 'Invalid value 10');
    assert(color_10 == 0, 'Invalid color 10');
    assert(pos_10 == 0, 'Invalid position 10');
}

#[test]
fn test_insert_causes_recoloring() {
    let contract_address = deploy_contract("RBTree");

    let dispatcher = IRBTreeDispatcher { contract_address };

    dispatcher.insert(10);
    dispatcher.insert(20);

    let (value_10, color_10, pos_10) = *dispatcher.get_tree_structure().at(0).at(0);
    let (value_20, color_20, pos_20) = *dispatcher.get_tree_structure().at(1).at(0);

    assert(value_10 == 10, 'Invalid value 10');
    assert(color_10 == 0, 'Invalid color 10');
    assert(pos_10 == 0, 'Invalid position 10');

    assert(value_20 == 20, 'Invalid value 20');
    assert(color_20 == 1, 'Invalid color 20');
    assert(pos_20 == 1, 'Invalid position 20');
}

#[test]
fn test_insert_causes_rotation() {
    let contract_address = deploy_contract("RBTree");

    let dispatcher = IRBTreeDispatcher { contract_address };

    dispatcher.insert(10);
    dispatcher.insert(20);
    dispatcher.insert(30);

    let (value_20, color_20, pos_20) = *dispatcher.get_tree_structure().at(0).at(0);
    let (value_10, color_10, pos_10) = *dispatcher.get_tree_structure().at(1).at(0);
    let (value_30, color_30, pos_30) = *dispatcher.get_tree_structure().at(1).at(1);

    assert(value_20 == 20, 'Invalid value 10');
    assert(color_20 == 0, 'Invalid color 10');
    assert(pos_20 == 0, 'Invalid position 10');

    assert(value_10 == 10, 'Invalid value 10');
    assert(color_10 == 1, 'Invalid color 10');
    assert(pos_10 == 0, 'Invalid position 10');

    assert(value_30 == 30, 'Invalid value 30');
    assert(color_30 == 1, 'Invalid color 30');
    assert(pos_30 == 1, 'Invalid position 30');
}

#[test]
fn test_insert_causes_recoloring_and_rotation() {
    let contract_address = deploy_contract("RBTree");

    let dispatcher = IRBTreeDispatcher { contract_address };

    dispatcher.insert(10);
    dispatcher.insert(20);
    dispatcher.insert(15);

    let (value_10, color_10, pos_10) = *dispatcher.get_tree_structure().at(1).at(0);
    let (value_20, color_20, pos_20) = *dispatcher.get_tree_structure().at(1).at(1);
    let (value_15, color_15, pos_15) = *dispatcher.get_tree_structure().at(0).at(0);

    assert(value_20 == 20, 'Invalid value 20');
    assert(color_20 == 1, 'Invalid color 20');
    assert(pos_20 == 1, 'Invalid position 20');

    assert(value_10 == 10, 'Invalid value 10');
    assert(color_10 == 1, 'Invalid color 10');
    assert(pos_10 == 0, 'Invalid position 10');

    assert(value_15 == 15, 'Invalid value 15');
    assert(color_15 == 0, 'Invalid color 15');
    assert(pos_15 == 0, 'Invalid position 15');
}

// Test Deletion

#[test]
fn test_delete_red_leaf() {
    let contract_address = deploy_contract("RBTree");

    let dispatcher = IRBTreeDispatcher { contract_address };

    dispatcher.insert(20);
    dispatcher.insert(10);
    dispatcher.insert(30);
    dispatcher.insert(5);
    dispatcher.insert(15);
    dispatcher.insert(25);
    dispatcher.insert(35);
    dispatcher.insert(2);
    dispatcher.insert(7);
    dispatcher.insert(12);
    dispatcher.insert(17);
   
    dispatcher.delete(10);

    let result = dispatcher.get_tree_structure();
    let (value_12, color_12, pos_12) = *result.at(1).at(0);

    assert(value_12 == 12, 'Invalid value 12');
    assert(color_12 == 1, 'Invalid color 12');
    assert(pos_12 == 0, 'Invalid position 12');

    dispatcher.delete(20);
    
    let result = dispatcher.get_tree_structure();
    let (value_25, color_25, pos_25) = *result.at(0).at(0);

    assert(value_25 == 25, 'Invalid value 25');
    assert(color_25 == 0, 'Invalid color 25');
    assert(pos_25 == 0, 'Invalid position 25');

    dispatcher.delete(2);

    let result = dispatcher.get_tree_structure();

    let (value_12, color_12, pos_12) = *result.at(1).at(0);
    let (value_15, color_15, pos_15) = *result.at(2).at(1);
    let (value_7, color_7, pos_7) = *result.at(3).at(0);

    assert(value_12 == 12, 'Invalid value 12');
    assert(color_12 == 1, 'Invalid color 12');
    assert(pos_12 == 0, 'Invalid position 12');

    assert(value_15 == 15, 'Invalid value 15');
    assert(color_15 == 0, 'Invalid color 15');
    assert(pos_15 == 1, 'Invalid position 15');

    assert(value_7 == 7, 'Invalid value 7');
    assert(color_7 == 1, 'Invalid color 7');
    assert(pos_7 == 1, 'Invalid position 7');

    dispatcher.delete(30);

    let result = dispatcher.get_tree_structure();
    
    let (value_35, color_35, pos_35) = *result.at(1).at(1);

    assert(value_35 == 35, 'Invalid value 35');
    assert(color_35 == 0, 'Invalid color 35');
    assert(pos_35 == 1, 'Invalid position 35');

}

