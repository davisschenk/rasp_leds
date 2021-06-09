use crate::led_driver::LedResponse;
use crate::patterns::*;

use rs_ws281x::{ChannelBuilder, Controller, ControllerBuilder, StripType};
use std::boxed::Box;
use std::sync::mpsc;
use std::sync::{Arc, Mutex};
use std::thread;
use std::time::Duration;

type MessageSender = mpsc::Sender<String>;
type MessageReceiver = mpsc::Receiver<String>;
type ResultSender = mpsc::Sender<LedResponse>;
type ResultReceiver = mpsc::Receiver<LedResponse>;
type BoxedPattern = Box<dyn Pattern + Send>;

enum RunnerState {
    Idle(bool),
    Pattern(BoxedPattern),
}

impl std::fmt::Display for RunnerState {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match *self {
            RunnerState::Idle(_) => write!(f, "Idle"),
            RunnerState::Pattern(_) => write!(f, "Pattern"),
        }
    }
}

pub struct Runner {
    runner: Arc<Mutex<RunnerInner>>,
    message_sender: MessageSender,
    result_receiver: ResultReceiver,
}
pub struct RunnerInner {
    pub pin: i32,
    pub count: i32,
    pub brightness: u8,
    state: RunnerState,
    message_receiver: MessageReceiver,
    result_sender: ResultSender,
}

impl Runner {
    /// Returns a new runner and channels for sending json control messages and receieving the results
    ///
    /// # Arguments
    /// * 'pin' - The pin that the LEDs are on
    /// * 'count' - The number of leds
    /// * 'brightness' - The brightness of the leds
    pub fn new(pin: i32, count: i32, brightness: u8) -> Self {
        let (message_sender, message_receiver): (MessageSender, MessageReceiver) = mpsc::channel();
        let (result_sender, result_receiver): (ResultSender, ResultReceiver) = mpsc::channel();

        Runner {
            runner: Arc::new(Mutex::new(RunnerInner {
                pin,
                count,
                brightness,
                state: RunnerState::Idle(true),
                result_sender: result_sender,
                message_receiver: message_receiver,
            })),
            message_sender,
            result_receiver,
        }
    }
    /// Starts the runner in a seperate thread.
    pub fn start(&mut self) {
        let local_self = self.runner.clone();

        thread::spawn(move || {
            let mut locked_self = local_self.lock().unwrap();

            let channel = ChannelBuilder::new()
                .pin(locked_self.pin)
                .count(locked_self.count)
                .strip_type(StripType::Ws2812)
                .brightness(locked_self.brightness)
                .build();

            let mut controller = ControllerBuilder::new()
                .freq(800_000)
                .dma(10)
                .channel(0, channel)
                .build()
                .expect("Failed to create controller");

            loop {
                match locked_self.state {
                    RunnerState::Idle(clear) => locked_self.run_idle(clear, &mut controller),
                    RunnerState::Pattern(_) => locked_self.run_pattern(&mut controller),
                };
            }
        });
    }

    pub fn send(&self, message: String) -> LedResponse {
        self.message_sender.send(message).unwrap();

        self.result_receiver.recv().unwrap()
    }
}

impl RunnerInner {
    /// Clears LEDs if clear is true, then waits for a new message
    ///
    /// # Arguments
    ///
    /// 'clear' if LEDs should be cleared
    /// 'controller' Mutable reference to LED controller
    fn run_idle(&mut self, clear: bool, controller: &mut Controller) {
        if clear {
            let leds = controller.leds_mut(0);
            reset(leds);
            println!("Clearing in idle");
            controller.render().unwrap();
        }

        if let Ok(message) = self.message_receiver.recv() {
            self.handle_message(message);
        }
    }

    /// Runs a pattern and checks for new messages
    ///
    /// # Arguments
    ///
    /// 'controller' Mutable reference to LED controller
    fn run_pattern(&mut self, controller: &mut Controller) {
        let mut tick = 0;
        let leds = controller.leds_mut(0);
        reset(leds);
        controller.render().unwrap();

        while let RunnerState::Pattern(pattern) = &mut self.state {
            let leds = controller.leds_mut(0);

            match pattern.start_tick(tick, leds) {
                Ok(TickAction::Render) => controller.render().unwrap(),
                Ok(TickAction::Idle) => {
                    self.state = RunnerState::Idle(false);
                    break;
                }
                Ok(_) => (),
                Err(error) => println!("Error running tick: {:?}", error),
            }

            thread::sleep(Duration::from_millis(pattern.tick_rate()));
            tick += 1;

            if let Ok(message) = self.message_receiver.try_recv() {
                self.handle_message(message);
                break;
            }
        }
    }

    /// Takes in a JSON String, converts it to a Message and handles the state change or function call
    ///
    /// # Arguments
    /// `raw_message` JSON message as a String
    fn handle_message(&mut self, raw_message: String) {
        let mut sent = false;
        match serde_json::from_str::<Message>(&raw_message) {
            Ok(message) => match message {
                Message::Idle { clear } => self.state = RunnerState::Idle(clear),
                Message::Pattern(pattern) => {
                    self.handle_pattern_message(pattern)
                        .map_err(|e| {
                            sent = true;
                            self.result_sender
                                .send(LedResponse::Error { message: e })
                                .unwrap();
                        })
                        .unwrap();
                }
            },
            Err(error) => {
                sent = true;
                self.result_sender
                    .send(LedResponse::Error {
                        message: error.to_string(),
                    })
                    .unwrap();
            }
        }

        if !sent {
            self.result_sender.send(LedResponse::Ok).unwrap();
        }
    }

    /// Takes a pattern and modifys runner state
    ///
    /// # Arguments
    /// `pattern` A varient of Patterns
    fn handle_pattern_message(&mut self, pattern: Patterns) -> Result<(), String> {
        if let Err(s) = pattern.init(self) {
            println!("error in pattern init {}", s);
            return Err(s);
        }

        let boxed: BoxedPattern = Box::new(Patterns::from(pattern));

        self.state = RunnerState::Pattern(boxed);

        Ok(())
    }
}
