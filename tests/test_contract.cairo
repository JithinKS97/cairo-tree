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


    dispatcher.insert(20);
    dispatcher.insert(10);
    dispatcher.insert(30);
    dispatcher.insert(5);
    dispatcher.insert(15);
    dispatcher.insert(25);
    dispatcher.insert(40);
    dispatcher.insert(3);
    dispatcher.insert(7);
    println!("Tree after insertions");
}

// #[test]
// #[feature("safe_dispatcher")]
// fn test_cannot_increase_balance_with_zero_value() {
//     let contract_address = deploy_contract("Tree");

//     let safe_dispatcher = ITreeSafeDispatcher { contract_address };

//     let root_before = safe_dispatcher.get_root().unwrap();
//     assert(root_before == 0, 'Invalid balance');

//     match safe_dispatcher.insert(0) {
//         Result::Ok(_) => core::panic_with_felt252('Should have panicked'),
//         Result::Err(panic_data) => {
//             assert(*panic_data.at(0) == 'Value cannot be 0', *panic_data.at(0));
//         }
//     };
// }
