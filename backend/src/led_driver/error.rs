use rocket::http::{ContentType, Status};
use rocket::request::Request;
use rocket::response::{self, Responder, Response};
use serde::Serialize;
use serde_json;
use std::io::Cursor;

#[derive(Serialize)]
#[serde(tag = "status", rename_all = "snake_case")]
pub enum LedResponse {
    Ok,
    Error { message: String },
}

/// Custom responder to convert an LedResponse to a json response with a status code
impl<'a> Responder<'a> for LedResponse {
    fn respond_to(self, _: &Request) -> response::Result<'a> {
        Response::build()
            .header(ContentType::JSON)
            .status(if let LedResponse::Ok = &self {
                Status::Ok
            } else {
                Status::BadRequest
            })
            .sized_body(Cursor::new(serde_json::to_string(&self).unwrap()))
            .ok()
    }
}
