use super::common::*;
use serde::Deserialize;

#[derive(Deserialize)]
pub struct RainbowCycle {
    pub tick_rate: u64,
}

impl RainbowCycle {
    pub fn new(tick_rate: u64) -> RainbowCycle {
        RainbowCycle { tick_rate }
    }
}

impl Pattern for RainbowCycle {
    fn tick_rate(&self) -> u64 {
        self.tick_rate
    }
    fn tick_cycle(&self) -> Option<u64> {
        Some(256 * 5)
    }
    fn tick(&mut self, tick: u64, leds: &mut [[u8; 4]]) -> TickResult {
        for i in 0..leds.len() {
            leds[i] = wheel((((i as f64 * 256.0 / crate::COUNT as f64) as u64 + tick) & 255) as u8);
        }

        Ok(TickAction::Render)
    }
}
