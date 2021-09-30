//TODO: COME BACK TO THIS, rs_ws281x::Controller.leds_mut doesnt keep any state :/

use super::common::*;
use serde::Deserialize;

#[derive(Deserialize)]
#[serde(rename_all="snake_case")]
pub enum Direction {
    Counter,
    Clockwise
}

#[derive(Deserialize)]
pub struct Rotate {
    pub tick_rate: u64,
    pub direction: Direction
}

impl Pattern for Rotate {
    fn tick_rate(&self) -> u64 {
        self.tick_rate
    }
    fn tick_cycle(&self) -> Option<u64> {
        None
    }
    fn tick(&mut self, tick: u64, leds: &mut [[u8; 4]]) -> TickResult {
        println!("{:?}", leds);
        match self.direction {
            Direction::Counter => leds.rotate_right(1),
            Direction::Clockwise => leds.rotate_left(1),
        }

        Ok(TickAction::Render)
    }
}
