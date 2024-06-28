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

    let root_before = dispatcher.get_root();
    assert(root_before == 0, 'Invalid balance');

    dispatcher.insert(42);

    let balance_after = dispatcher.get_root();
    assert(balance_after == 42, 'Invalid balance');
}

#[test]
#[feature("safe_dispatcher")]
fn test_cannot_increase_balance_with_zero_value() {
    let contract_address = deploy_contract("Tree");

    let safe_dispatcher = ITreeSafeDispatcher { contract_address };

    let root_before = safe_dispatcher.get_root().unwrap();
    assert(root_before == 0, 'Invalid balance');

    match safe_dispatcher.insert(0) {
        Result::Ok(_) => core::panic_with_felt252('Should have panicked'),
        Result::Err(panic_data) => {
            assert(*panic_data.at(0) == 'Value cannot be 0', *panic_data.at(0));
        }
    };
}
