use super::common::*;
use rand::Rng;
use serde::Deserialize;

#[derive(Deserialize)]
pub struct Random {
    pub tick_rate: u64,
}

impl Pattern for Random {
    fn tick_rate(&self) -> u64 {
        self.tick_rate
    }
    fn tick_cycle(&self) -> Option<u64> {
        None
    }
    fn tick(&mut self, tick: u64, leds: &mut [[u8; 4]]) -> TickResult {
        let mut rng = rand::thread_rng();

        for i in leds.iter_mut() {
            (*i)[(tick % 3) as usize] = rng.gen();

            let a0 = tick + rng.gen_range(0..=1) + 1;
            let a1 = 255 - (*i)[(tick % 3) as usize];
            if a1 != 0 {
                (*i)[(a0 % 3) as usize] = rng.gen_range(0..a1);
            } else {
                (*i)[(a0 % 3) as usize] = 0;
            }
            (*i)[((a0 + 1) % 3) as usize] =
                255 - (*i)[(a0 % 3) as usize] - (*i)[(tick % 3) as usize];
        }

        Ok(TickAction::Render)
    }
}
