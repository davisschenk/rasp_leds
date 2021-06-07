use super::common::*;
use serde::Deserialize;

#[derive(Deserialize)]
pub struct Strobe {
    pub tick_rate: u64,
    pub color: [u8; 4],
}

impl Pattern for Strobe {
    fn tick_rate(&self) -> u64 {
        self.tick_rate
    }
    fn tick_cycle(&self) -> Option<u64> {
        None
    }
    fn tick(&mut self, tick: u64, leds: &mut [[u8; 4]]) -> TickResult {
        if tick % 2 == 0 {
            for i in leds.iter_mut() {
                *i = self.color;
            }
        } else {
            reset(leds);
        }

        Ok(TickAction::Render)
    }
}
