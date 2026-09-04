# swift-http-router

Routes and replies over the `HTTP` namespace, one coder per domain call.

## HTTP Router

`import HTTP_Router` for `HTTP.Routable`, `HTTP.Router.Protocol`, `HTTP.Router.Builder`, `HTTP.Router.Request`, `HTTP.Router.Response`, `HTTP.Router.Error`, `HTTP.Content`, the `HTTP.Method` and `HTTP.Target` field coders, and `HTTP.route`, `HTTP.request`, `HTTP.target`.

```swift
extension Greeting: HTTP.Routable {

    static var router: some HTTP.Router.`Protocol`<Call> {
        Call.Router(
            absent: .mismatch,
            greet: HTTP.route {
                .post
                HTTP.Target(unchecked: "/greet")
                HTTP.Content(Greeting.Name.self)
            }
        )
    }
}

let request = try HTTP.request(Greeting.self, for: .greet(Greeting.Name("Ada")))
let call = try HTTP.route(Greeting.self, request)
```

## HTTP Reply

`import HTTP_Reply` for `HTTP.Reply.Builder`, `HTTP.Reply.Status`, `HTTP.Reply.Success`, `HTTP.Reply.Refusal`, `HTTP.Reply.Empty`, `HTTP.Reply.Pair`, `HTTP.reply`, `HTTP.success`, `HTTP.refusal`, the status shorthands `HTTP.ok`, `HTTP.created`, `HTTP.badRequest`, `HTTP.notFound` and their siblings, and `HTTP.Router.Response.ok`, `.badRequest`, `.decoded`.

```swift
let reply = HTTP.reply {
    HTTP.ok(Greeting.Message.self)
    HTTP.badRequest(Greeting.Error.self)
}

var response = HTTP.Router.Response.blank
try reply.serialize(.right(Greeting.Message("Hello, Ada")), into: &response)
let outcome = try reply.parse(&response)
```

A reply infers bottom-up: `HTTP.Reply.Success` codes `Either<Never, Value>`, `HTTP.Reply.Refusal` codes `Either<Reason, Never>`, and the builder pairs them into `Either<Reason, Value>`.

## Dependencies

`HTTP` from [swift-standards/swift-http](https://github.com/swift-standards/swift-http), `RFC 9110` from [swift-ietf/swift-rfc-9110](https://github.com/swift-ietf/swift-rfc-9110), and the coder atoms and molecules named in `Package.swift`.
