#!/usr/bin/env nu
use std log

const RESPONSE_FILE = "response"
const PORT = 3000

rm -f $RESPONSE_FILE
mkfifo $RESPONSE_FILE

def handle_request [request: string]: nothing -> nothing {
    log debug $"incoming request: ($request)"

    let request = $request | split row "\r\n"
    let headline = $request | first | parse "{http_verb} {path} {protocol_version}" | into record

    let res = $request | skip 1 | split list ""
    let _headers = $res | first | parse "{key}: {value}"
    let _body = $res | skip 1 | flatten

    let response = match $"($headline.http_verb) ($headline.path)" {
        "GET /" => "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n</h1>PONG</h1>",
        _ => "HTTP/1.1 404 NotFound\r\n\r\n\r\nNot Found",
    }

    log debug $"outgoing response: ($response)"
    $response | save --force $RESPONSE_FILE
}

log info $"listening on port ($PORT)..."

while true {
    let request = cat $RESPONSE_FILE | nc --listen --close --local-port $PORT
    handle_request $request
}

log info $"server on port ($PORT) is now down."
