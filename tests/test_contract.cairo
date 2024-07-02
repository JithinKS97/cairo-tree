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
fn test_multiple_deletions_round_1() {
    let contract_address = deploy_contract("RBTree");

    let dispatcher = IRBTreeDispatcher { contract_address };

    let elements = array![10, 20, 30, 5, 15, 25, 35, 2, 7, 12, 17];

    let mut i = 0;

    while i < elements.len() {
        dispatcher.insert(*elements.at(i));
        i += 1;
    };
   
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

#[test]
fn test_multiple_deletions_round_2() {
    let contract_address = deploy_contract("RBTree");

    let dispatcher = IRBTreeDispatcher { contract_address };

    let elements = array![13, 8, 17, 1, 11, 15, 25, 6, 22, 27];
    let mut i = 0;
    while i < elements.len() {
        dispatcher.insert(*elements.at(i));
        i += 1;
    };

    dispatcher.delete(1);
    let result = dispatcher.get_tree_structure();
    let (value_6, color_6, pos_6) = *result.at(2).at(0);

    assert(value_6 == 6, 'Invalid value 6');
    assert(color_6 == 0, 'Invalid color 6');
    assert(pos_6 == 0, 'Invalid position 6');

    dispatcher.delete(6);
    let result = dispatcher.get_tree_structure();

    let (value_8, color_8, pos_8) = *result.at(1).at(0);
    let (value_11, color_11, pos_11) = *result.at(2).at(0);

    assert(value_8 == 8, 'Invalid value 8');
    assert(color_8 == 0, 'Invalid color 8');
    assert(pos_8 == 0, 'Invalid position 8');

    assert(value_11 == 11, 'Invalid value 11');
    assert(color_11 == 1, 'Invalid color 11');
    assert(pos_11 == 1, 'Invalid position 11');

    dispatcher.delete(8);
    let result = dispatcher.get_tree_structure();
    let (value_11, color_11, pos_11) = *result.at(1).at(0);
    
    assert(value_11 == 11, 'Invalid value 11');
    assert(color_11 == 0, 'Invalid color 11');
    assert(pos_11 == 0, 'Invalid position 11');

    dispatcher.delete(11);
    let result = dispatcher.get_tree_structure();

    let (value_17, color_17, pos_17) = *result.at(0).at(0);
    let (value_13, color_13, pos_13) = *result.at(1).at(0);
    let (value_15, color_15, pos_15) = *result.at(2).at(0);

    assert(value_17 == 17, 'Invalid value 17');
    assert(color_17 == 0, 'Invalid color 17');
    assert(pos_17 == 0, 'Invalid position 17');

    assert(value_13 == 13, 'Invalid value 13');
    assert(color_13 == 0, 'Invalid color 13');
    assert(pos_13 == 0, 'Invalid position 13');

    assert(value_15 == 15, 'Invalid value 15');
    assert(color_15 == 1, 'Invalid color 15');
    assert(pos_15 == 1, 'Invalid position 15');

    dispatcher.delete(13);
    let result = dispatcher.get_tree_structure();
    let (value_15, color_15, pos_15) = *result.at(1).at(0);
    
    assert(value_15 == 15, 'Invalid value 15');
    assert(color_15 == 0, 'Invalid color 15');
    assert(pos_15 == 0, 'Invalid position 15');

    dispatcher.delete(15);
    let result = dispatcher.get_tree_structure();
    let (value_25, color_25, pos_25) = *result.at(0).at(0);
    let (value_17, color_17, pos_17) = *result.at(1).at(0);
    let (value_27, color_27, pos_27) = *result.at(1).at(1);
    let (value_22, color_22, pos_22) = *result.at(2).at(0);

    assert(value_25 == 25, 'Invalid value 25');
    assert(color_25 == 0, 'Invalid color 25');
    assert(pos_25 == 0, 'Invalid position 25');

    assert(value_17 == 17, 'Invalid value 17');
    assert(color_17 == 0, 'Invalid color 17');
    assert(pos_17 == 0, 'Invalid position 17');

    assert(value_27 == 27, 'Invalid value 27');
    assert(color_27 == 0, 'Invalid color 27');
    assert(pos_27 == 1, 'Invalid position 27');

    assert(value_22 == 22, 'Invalid value 22');
    assert(color_22 == 1, 'Invalid color 22');
    assert(pos_22 == 1, 'Invalid position 22');

    dispatcher.delete(17);
    let result = dispatcher.get_tree_structure();

    let (value_22, color_22, pos_22) = *result.at(1).at(0);
    let (value_27, color_27, pos_27) = *result.at(1).at(1);

    assert(value_22 == 22, 'Invalid value 22');
    assert(color_22 == 0, 'Invalid color 22');
    assert(pos_22 == 0, 'Invalid position 22');

    assert(value_27 == 27, 'Invalid value 27');
    assert(color_27 == 0, 'Invalid color 27');
    assert(pos_27 == 1, 'Invalid position 27');

    dispatcher.delete(22);
    let result = dispatcher.get_tree_structure();

    let (value_25, color_25, pos_25) = *result.at(0).at(0);
    let (value_27, color_27, pos_27) = *result.at(1).at(0);
    
    assert(value_25 == 25, 'Invalid value 25');
    assert(color_25 == 0, 'Invalid color 25');
    assert(pos_25 == 0, 'Invalid position 25');

    assert(value_27 == 27, 'Invalid value 27');
    assert(color_27 == 1, 'Invalid color 27');
    assert(pos_27 == 1, 'Invalid position 27');

    dispatcher.delete(25);
    let result = dispatcher.get_tree_structure();
    let (value_27, color_27, pos_27) = *result.at(0).at(0);

    assert(value_27 == 27, 'Invalid value 27');
    assert(color_27 == 0, 'Invalid color 27');
    assert(pos_27 == 0, 'Invalid position 27');

    dispatcher.delete(27);
    let result = dispatcher.get_tree_structure();

    assert(result.len() == 0, 'Empty tree check failed');
}

