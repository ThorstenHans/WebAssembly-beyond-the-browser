use anyhow::Result;
use spin_sdk::{
    http::{Request, Response},
    http_component,
};

/// A simple Spin HTTP component.
#[http_component]
fn hello_cloudland2022(req: Request) -> Result<Response> {
    println!("{:?}", req.headers());
    Ok(http::Response::builder()
        .status(200)
        .header("X-Custom-Header", "FooBar")
        .header("foo", "bar")
        .body(Some("Hello, Cloudland 2022".into()))?)
}
