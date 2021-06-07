use super::common::*;
use crate::led_driver::runner;
use chrono::{DateTime, Utc};
use serde::Deserialize;

#[derive(Deserialize)]
pub struct Timer {
    pub tick_rate: u64,
    pub color: [u8; 4],
    #[serde(with = "my_date_format")]
    pub timestamp: DateTime<Utc>,
    #[serde(skip, default = "Utc::now")]
    pub start_time: DateTime<Utc>,
}

impl Pattern for Timer {
    fn init(&self, _: &runner::RunnerInner) -> Result<(), String> {
        if self.timestamp < Utc::now() {
            Err(String::from("Timestamp is in the past, cant countdown."))
        } else {
            Ok(())
        }
    }

    fn tick_rate(&self) -> u64 {
        self.tick_rate
    }
    fn tick_cycle(&self) -> Option<u64> {
        None
    }
    fn tick(&mut self, _tick: u64, leds: &mut [[u8; 4]]) -> TickResult {
        let total_time_until = self
            .timestamp
            .signed_duration_since(self.start_time)
            .to_std();
        let time_from_now = self.timestamp.signed_duration_since(Utc::now()).to_std();

        if let (Ok(total_time), Ok(time_from)) = (total_time_until, time_from_now) {
            let percent = time_from.as_millis() as f64 / total_time.as_millis() as f64;

            reset(leds);
            for i in 0..(crate::COUNT as f64 * percent) as usize {
                leds[i] = self.color;
            }

            Ok(TickAction::Render)
        } else {
            Ok(TickAction::Idle)
        }
    }
}

mod my_date_format {
    use chrono::{DateTime, TimeZone, Utc};
    use serde::{self, Deserialize, Deserializer};

    const FORMAT: &'static str = "%Y-%m-%d %H:%M:%S";

    pub fn deserialize<'de, D>(deserializer: D) -> Result<DateTime<Utc>, D::Error>
    where
        D: Deserializer<'de>,
    {
        let s = String::deserialize(deserializer)?;
        Utc.datetime_from_str(&s, FORMAT)
            .map_err(serde::de::Error::custom)
    }
}
