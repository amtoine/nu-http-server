#!/usr/bin/env nu
use std log

const RESPONSE_FILE = "response"
const PORT = 3000

rm -f $RESPONSE_FILE
mkfifo $RESPONSE_FILE

def handle_request [request: string]: nothing -> nothing {
    log warning $"incoming request: ($request)"
}

log info $"listening on port ($PORT)..."

let request = cat $RESPONSE_FILE | nc --listen --close --local-port $PORT
handle_request $request
