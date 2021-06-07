pub use crate::led_driver::runner::RunnerInner;

use super::*;
use crate::led_driver::runner;
use enum_dispatch::enum_dispatch;
use serde::Deserialize;

pub type TickResult = Result<TickAction, String>;

#[enum_dispatch(Pattern)]
#[derive(Deserialize)]
#[serde(rename_all = "snake_case")]
#[serde(tag = "pattern")]
pub enum Patterns {
    Random(Random),
    MovingDot(MovingDot),
    Strobe(Strobe),
    Meteor(Meteor),
    RainbowCycle(RainbowCycle),
    Timer(Timer),
    Solid(Solid),
    Alternating(Alternating),
}

#[derive(Deserialize)]
#[serde(rename_all = "snake_case")]
#[serde(tag = "type", content = "data")]
pub enum Message {
    Pattern(Patterns),
    Idle { clear: bool },
}

pub enum TickAction {
    Render,
    None,
    Idle,
}

#[enum_dispatch]
pub trait Pattern {
    fn init(&self, _runner: &runner::RunnerInner) -> Result<(), String> {
        Ok(())
    }
    fn tick_rate(&self) -> u64;
    fn tick_cycle(&self) -> Option<u64>;
    fn start_tick(&mut self, raw_tick: u64, leds: &mut [[u8; 4]]) -> TickResult {
        match self.tick_cycle() {
            Some(cycle) => self.tick(raw_tick % cycle, leds),
            None => self.tick(raw_tick, leds),
        }
    }
    fn tick(&mut self, tick: u64, leds: &mut [[u8; 4]]) -> TickResult;
}


pub fn reset(leds: &mut [[u8; 4]]) {
    for i in leds.iter_mut() {
        *i = [0, 0, 0, 0];
    }
}

pub fn wheel(position: u8) -> [u8; 4] {
    let mut c = [0; 4];

    if position < 85 {
        c[0] = position * 3;
        c[1] = 255 - position * 3;
        c[2] = 0;
    } else if position < 170 {
        c[0] = 255 - (position - 85) * 3;
        c[1] = 0;
        c[2] = (position - 85) * 3;
    } else {
        c[0] = 0;
        c[1] = (position - 170) * 3;
        c[2] = 255 - (position - 170) * 3;
    }

    c
}
