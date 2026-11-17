# swift-http-router

Pre-Institute: going to swift-compositions once swift-interface, whose `@Interface` its tests use, has moved there. Use this package to route HTTP requests to a domain's calls and to answer them. A router is one coder: the same value parses an `HTTP.Router.Request` into a call and prints the call back into a request, so the two directions cannot drift apart. `HTTP Router` holds the routes (`HTTP.Routable`, `HTTP.route { … }` built from a method, `HTTP.Target`, `HTTP.Segment`, `HTTP.Query.Field`, `HTTP.Cookie.Field`, `HTTP.Bearer` and a body coder); `HTTP Reply` holds the responses (`HTTP.reply { … }` built from status arms such as `HTTP.ok` and `HTTP.badRequest`); `HTTP` is the namespace alone, its RFC 9110 names typealiases into `RFC_9110`, so extending `HTTP.Target` extends the RFC 9110 type. The tests are the examples.

## Laws

- `HTTP.route(router, HTTP.request(router, for: call)) == call` for every call the router can print. `HTTP.route` and `HTTP.request` take a `Routable` type or a router value, for a router built from runtime input.
- A route matches only when it consumes the whole request: a body or path left over after parsing is `.malformed`.
- `HTTP.Router.Error.mismatch` means this route does not apply and the next one is tried; `.malformed` means the route applies but the request is wrong, and stops the search; `.unprintable` means a call could not be printed.
- An origin-form target is read and printed as `RFC_9110.Target.origin(path:query:)`, so `//apps` keeps its empty first segment.
- A body takes an explicit coder value (`HTTP.Content(String.Coder())`). There is no type-based overload and no implicit `Codable` adoption: the representation is chosen at each boundary.
- A reply's types infer bottom-up: `HTTP.Reply.Success` codes `Either<Never, Value>`, `HTTP.Reply.Refusal` codes `Either<Reason, Never>`, and the builder pairs them into `Either<Reason, Value>`. A refusal may come first.
- A status no reply arm owns is `.mismatch`; a body its arm cannot read is `.malformed`. `HTTP.Reply.Empty` carries no content and refuses any.
- `HTTP.Router.Response.ok(value, using:)` and `HTTP.Router.Response(status, value, using:)` write a fresh body and map a failure to `.unprintable`; `response.decoded(using:)` needs a present, fully consumed body and maps a failure or trailing bytes to `.malformed`.
- JSON bodies need Foundation, so `HTTP.Body.JSON<Value>` (any `Codable` value, `application/json`) lives in `HTTP Router Foundation Integration` behind the `Foundation` trait. No other target imports Foundation.
