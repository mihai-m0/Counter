module counter_project::counter ;

use sui::tx_context::{TxContext, epoch};
use sui::coin::{Self, Coin};
use sui::event;
use sui::sui::SUI;

public struct Counter has key {
    id: UID,
    owner: address,
    count_value: u64,
    created_at: u64,
}

public struct CounterCreated has copy,drop{
    counter_id:ID,
    owner:address,
}

public struct CounterIncremented has copy,drop{
    increaser: address, 
    total_incremented_value: u64,
}

fun init(ctx: &mut TxContext) {
    let owner = ctx.sender();
    let counter = Counter {
        id: object::new(ctx),
        owner: owner,
        count_value: 0,
        created_at: epoch(ctx),
    };
 
    let counter_id = object::id(&counter);
 
    event::emit(CounterCreated {
        counter_id,
        owner,
    });
    transfer::share_object(counter)
}

public fun increment(counter: &mut Counter, payment: Coin<SUI>, ctx: &mut TxContext) {
    let increase_amount = coin::value(&payment);
 
    transfer::public_transfer(payment, counter.owner);
 
    counter.count_value = counter.count_value + 1;
 
    event::emit(CounterIncremented {
        increaser: ctx.sender(),
        total_incremented_value: counter.count_value,
    })
}

public fun get_owner(counter: &Counter): address {
    counter.owner
}
 
public fun get_value(counter: &Counter): u64 {
    counter.count_value
}
 
 
#[test_only]
public fun init_for_testing(ctx: &mut TxContext) {
    init(ctx);
}