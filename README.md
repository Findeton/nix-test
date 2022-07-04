# nix-test
 
# C++

    cd cpp && clang++ -Wall -std=c++11 main.cpp -o nix-test

# Rust

    cd rust && rustc main.rs -o nix-test

# Rust wasm

    cd rust-wasm/
    export RUSTFLAGS='-C target-feature=+atomics,+bulk-memory,+mutable-globals'
    rustup run nightly-2022-04-07 wasm-pack build --out-name index --release --target web --features=wasm -- -Z build-std=panic_abort,std
    rustup run nightly-2022-04-07 wasm-pack pack .
