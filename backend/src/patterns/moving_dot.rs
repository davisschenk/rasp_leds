use super::common::*;
use serde::Deserialize;

#[derive(Deserialize)]
pub struct MovingDot {
    pub tick_rate: u64,
    pub tick_cycle: u64,
    pub color: [u8; 4],
}

impl Pattern for MovingDot {
    fn tick_rate(&self) -> u64 {
        self.tick_rate
    }

    fn tick_cycle(&self) -> Option<u64> {
        Some(self.tick_cycle)
    }

    fn tick(&mut self, tick: u64, leds: &mut [[u8; 4]]) -> TickResult {
        leds[tick as usize] = self.color;

        if tick > 0 {
            leds[(tick - 1) as usize] = [0, 0, 0, 0];
        }

        Ok(TickAction::Render)
    }
}
