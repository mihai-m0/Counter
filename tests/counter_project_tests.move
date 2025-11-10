#[test_only]
module counter::counter_project_tests;
 
use sui::coin::{Self, Coin};
use sui::sui::SUI;
use sui::test_scenario;
use counter::counter::{Self, Counter};
 
const OWNER: address = @0xA11CE;
const INCREASER_1: address = @0xB0B;
 
fun create_test_coin(amount: u64, ctx: &mut TxContext): Coin<SUI> {
    coin::mint_for_testing<SUI>(amount, ctx)
}
 
#[test]
fun test_init_creates_counter() {
    let mut scenario = test_scenario::begin(OWNER);
    let ctx = test_scenario::ctx(&mut scenario);
 
    counter::init_for_testing(ctx);
 
    test_scenario::next_tx(&mut scenario, OWNER);
 
    let counter = test_scenario::take_shared<Counter>(&scenario);
 
    assert!(counter::get_owner(&counter) == OWNER, 0);
    assert!(counter::get_value(&counter) == 0, 1);
 
    test_scenario::return_shared(counter);
    test_scenario::end(scenario);
}
 
#[test]
fun test_increase_counter() {
    let mut scenario = test_scenario::begin(OWNER);
 
    {
        let ctx = test_scenario::ctx(&mut scenario);
        counter::init_for_testing(ctx);
    };
 
    test_scenario::next_tx(&mut scenario, INCREASER_1);
    {
        let mut counter = test_scenario::take_shared<TipJar>(&scenario);
        let ctx = test_scenario::ctx(&mut scenario);
        let increase_once= create_test_coin(1_000_000_000, ctx);
 
        counter::increment(&mut counter, increase_once, ctx);
 
        assert!(counter::get_value(&counter) == 1_000_000_000, 0);
 
        test_scenario::return_shared(counter);
    };
 
    test_scenario::next_tx(&mut scenario, OWNER);
    {
        let counter_increased = test_scenario::take_from_sender<Coin<SUI>>(&scenario);
        assert!(coin::value(&counter_increased) == 1_000_000_000, 2);
        test_scenario::return_to_sender(&scenario, counter_increased);
    };
 
    test_scenario::end(scenario);
}
 
