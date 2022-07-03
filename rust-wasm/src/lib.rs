use wasm_bindgen::prelude::*;

#[wasm_bindgen]
pub fn test_wasm() -> String {
    String::from("hello world")
}