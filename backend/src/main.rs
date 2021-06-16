#![feature(proc_macro_hygiene, decl_macro)]
#[macro_use]
extern crate rocket;
mod led_driver;
mod patterns;

use rocket::Data;
use rocket::State;
use rocket_contrib::serve::StaticFiles;
use std::io::Read;
use std::sync::{Arc, Mutex};

type StateRunner<'a> = State<'a, Arc<Mutex<led_driver::Runner>>>;

const PIN: i32 = 18;
const COUNT: i32 = 286;
const BRIGHTNESS: u8 = 32;

#[get("/")]
fn index() -> &'static str {
    "Hello, world!"
}

#[post("/pattern", data = "<data>")]
fn pattern(data: Data, runner: StateRunner) -> led_driver::LedResponse {
    let mut buffer = String::new();
    data.open().read_to_string(&mut buffer).unwrap();

    let locked = runner.lock().unwrap();
    (*locked).send(buffer)
}

fn main() {
    let mut runner = led_driver::Runner::new(PIN, COUNT, BRIGHTNESS);
    runner.start();

    let managed_runner = Arc::new(Mutex::new(runner));

    rocket::ignite()
        .manage(managed_runner)
        .mount("/", StaticFiles::from("/home/pi/rasp_leds/web"))
        .mount("/api", routes![pattern])
        .launch();
}
