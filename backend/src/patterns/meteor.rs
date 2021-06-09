use super::common::*;
use rand::Rng;
use serde::Deserialize;

#[derive(Deserialize)]
pub struct Meteor {
    pub tick_rate: u64,
    pub color: [u8; 4],
    pub random_decay: bool,
    pub decay: u8,
    pub size: u8,
}

impl Pattern for Meteor {
    fn tick_rate(&self) -> u64 {
        self.tick_rate
    }
    fn tick_cycle(&self) -> Option<u64> {
        Some(crate::COUNT as u64 + self.size as u64)
    }
    fn tick(&mut self, tick: u64, leds: &mut [[u8; 4]]) -> TickResult {
        let mut rng = rand::thread_rng();

        for j in 0..crate::COUNT as usize {
            if !self.random_decay || rng.gen::<bool>() {
                leds[j][..3].iter_mut().for_each(|x| {
                    *x = if *x <= 10 {
                        0
                    } else {
                        *x - (*x as f64 * self.decay as f64 / 255.0) as u8
                    }
                });
            }
        }
        for j in 0..self.size {
            if crate::COUNT as u64 > tick - j as u64 {
                leds[(tick - j as u64) as usize] = self.color;
            }
        }
        Ok(TickAction::Render)
    }
}
