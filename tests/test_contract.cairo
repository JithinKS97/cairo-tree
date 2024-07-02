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
    let (value, color, pos) = *dispatcher.get_tree_structure().at(0).at(0);
    
    assert(value == 10, 'Invalid value');
    assert(color == 0, 'Invalid color');
    assert(pos == 0, 'Invalid position');
}

#[test]
fn test_insert_causes_recoloring() {
    let contract_address = deploy_contract("RBTree");

    let dispatcher = IRBTreeDispatcher { contract_address };

    dispatcher.insert(10);
    dispatcher.insert(20);

    let (value_10, color_10, pos_10) = *dispatcher.get_tree_structure().at(0).at(0);
    let (value_20, color_20, pos_20) = *dispatcher.get_tree_structure().at(1).at(0);

    assert(value_10 == 10, 'Invalid value');
    assert(color_10 == 0, 'Invalid color');
    assert(pos_10 == 0, 'Invalid position');

    assert(value_20 == 20, 'Invalid value');
    assert(color_20 == 1, 'Invalid color');
    assert(pos_20 == 1, 'Invalid position');
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

    assert(value_20 == 20, 'Invalid value');
    assert(color_20 == 0, 'Invalid color');
    assert(pos_20 == 0, 'Invalid position');

    assert(value_10 == 10, 'Invalid value');
    assert(color_10 == 1, 'Invalid color');
    assert(pos_10 == 0, 'Invalid position');

    assert(value_30 == 30, 'Invalid value');
    assert(color_30 == 1, 'Invalid color');
    assert(pos_30 == 1, 'Invalid position');
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

    assert(value_20 == 20, 'Invalid value');
    assert(color_20 == 1, 'Invalid color');
    assert(pos_20 == 1, 'Invalid position');

    assert(value_10 == 10, 'Invalid value');
    assert(color_10 == 1, 'Invalid color');
    assert(pos_10 == 0, 'Invalid position');

    assert(value_15 == 15, 'Invalid value');
    assert(color_15 == 0, 'Invalid color');
    assert(pos_15 == 0, 'Invalid position');
}

#[test]
fn test_deletion() {
    let contract_address = deploy_contract("RBTree");

    let dispatcher = IRBTreeDispatcher { contract_address };

    dispatcher.insert(50);
    dispatcher.insert(25);
    dispatcher.insert(75);
    dispatcher.insert(10);
    dispatcher.insert(40);
    dispatcher.insert(60);
    dispatcher.insert(90);
    dispatcher.insert(5);
    dispatcher.insert(15);
    dispatcher.insert(30);
    dispatcher.insert(45);
    dispatcher.insert(55);
    dispatcher.insert(65);
    dispatcher.insert(80);
    dispatcher.insert(95);

    dispatcher.display_tree();

    dispatcher.delete(25);
    dispatcher.display_tree();

    dispatcher.delete(75);
    dispatcher.display_tree();

    dispatcher.delete(50);
    dispatcher.display_tree();

    dispatcher.delete(5);
    dispatcher.delete(15);
    dispatcher.delete(45);
    dispatcher.delete(65);
    dispatcher.display_tree();

    dispatcher.delete(30);
    dispatcher.display_tree();
}

