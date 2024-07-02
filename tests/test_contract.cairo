use starknet::ContractAddress;

use snforge_std::{declare, ContractClassTrait};

use tree::ITreeSafeDispatcher;
use tree::ITreeSafeDispatcherTrait;
use tree::ITreeDispatcher;
use tree::ITreeDispatcherTrait;

fn deploy_contract(name: ByteArray) -> ContractAddress {
    let contract = declare(name).unwrap();
    let (contract_address, _) = contract.deploy(@ArrayTrait::new()).unwrap();
    contract_address
}

#[test]
fn test_increase_balance() {
    let contract_address = deploy_contract("Tree");

    let dispatcher = ITreeDispatcher { contract_address };


    dispatcher.insert(10);
    dispatcher.insert(5);
    dispatcher.insert(15);
    dispatcher.insert(3);
    dispatcher.insert(7);
    dispatcher.insert(13);
    dispatcher.insert(17);
    dispatcher.print_tree();
}