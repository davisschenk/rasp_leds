use super::common::*;
use serde::Deserialize;
use std::iter;

#[derive(Deserialize)]
pub struct Solid {
    pub color: [u8; 4],
}

impl Pattern for Solid {
    fn tick_rate(&self) -> u64 {
        0
    }
    fn tick_cycle(&self) -> Option<u64> {
        None
    }
    fn tick(&mut self, _tick: u64, leds: &mut [[u8; 4]]) -> TickResult {
        leds
            .iter_mut()
            .for_each(|m| *m = self.color);


        Ok(TickAction::RenderOnce)
    }
}

#[derive(Deserialize)]
pub struct AlternatingColor {
    count: u8,
    color: [u8; 4],
}

#[derive(Deserialize)]
pub struct Alternating {
    pub colors: Vec<AlternatingColor>,
}

impl Pattern for Alternating {
    fn tick_rate(&self) -> u64 {
        0
    }

    fn tick_cycle(&self) -> Option<u64> {
        None
    }

    fn tick(&mut self, tick: u64, leds: &mut [[u8; 4]]) -> TickResult {
        self.colors
            .iter()
            .flat_map(|c| iter::repeat(c.color).take(c.count as usize))
            .cycle()
            .zip(leds.iter_mut())
            .for_each(|(c, l)| *l = c);

        Ok(TickAction::RenderOnce)
    }
}
