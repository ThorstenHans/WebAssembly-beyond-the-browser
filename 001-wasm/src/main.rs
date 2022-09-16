use std::{thread,time};

fn main() {
    let d = time::Duration::from_secs(3);
    loop{
        
        println!("Hello WebAssembly, this is 🦀   !!!");
        thread::sleep(d);

    }
}
