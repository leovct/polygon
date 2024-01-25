// Credits to jhilliard.
// Copy-pasted from https://github.com/maticnetwork/jhilliard/blob/main/plonky-test/src/main.rs.

use plonky2::field::goldilocks_field::GoldilocksField;
use plonky2::hash::poseidon::{Poseidon, SPONGE_WIDTH};

use std::env;
use std::thread;
use std::time::Instant;

fn test_poseidon<F: Poseidon>(num_iterations: usize) -> f64 {
    let start_time = Instant::now();
    for _ in 0..num_iterations {
        let state = F::rand_array::<SPONGE_WIDTH>();
        let _result = F::poseidon(state);
    }
    let elapsed = start_time.elapsed().as_secs_f64();
    elapsed
}

fn main() {
    // Read the number of iterations and threads from the command line
    let args: Vec<String> = env::args().collect();
    if args.len() < 3 {
        println!("Usage: {} <num_iterations> <num_threads>", args[0]);
        return;
    }
    let num_iterations: usize = args[1].parse().expect("Invalid number of iterations");
    let num_threads: usize = args[2].parse().expect("Invalid number of threads");

    let mut handles = vec![];

    let start_time = Instant::now();

    for i in 0..num_threads {
        let handle = thread::spawn(move || {
            test_poseidon::<GoldilocksField>(num_iterations)
        });
        handles.push((handle,i));
    }

    for handle in handles {
        let elapsed = handle.0.join().unwrap();
        println!("Thread {} finished in {} seconds", handle.1, elapsed);
    }

    let total_elapsed = start_time.elapsed().as_secs_f64();
    let avg_time_per_hash = total_elapsed / (num_iterations as f64);

    println!("Total time: {} seconds", total_elapsed);
    println!("Average time per hash: {} seconds", avg_time_per_hash);
}
