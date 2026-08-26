import Byte_Primitive
import Coder_Primitive
import HTTP
import HTTP_Coder
import Parser_Conversion_Primitives
import Parser_Primitive
import RFC_3986
import Serializer_Primitive
import Testing

private struct DecimalConversion: Parser.Conversion.`Protocol` {

    typealias Input = String
    typealias Output = Int
    typealias Failure = Parser.Conversion.Error

    func apply(_ input: String) throws(Parser.Conversion.Error) -> Int {
        guard let value = Int(input) else {
            throw .mismatch
        }
        return value
    }

    func unapply(_ output: Int) -> String {
        String(output)
    }
}

private struct TextConversion: Parser.Conversion.`Protocol` {

    typealias Input = String
    typealias Output = String
    typealias Failure = Never

    func apply(_ input: String) -> String { input }

    func unapply(_ output: String) -> String { output }
}

@Test
func `route input splits before decoding, so an encoded solidus is never a separator`() throws {
    let request = HTTP.Request(
        method: .get,
        target: .origin(path: try RFC_3986.URI.Path("/a%2Fb/c"), query: nil)
    )

    let input = HTTP.Route.Input(request)

    #expect(input.path == ["a/b", "c"])
}

@Test
func `route input round trips a request through decoded components`() throws {
    let request = HTTP.Request(
        method: .post,
        target: .origin(
            path: try RFC_3986.URI.Path("/counter/a%2Fb"),
            query: try RFC_3986.URI.Query("q=one%20two")
        ),
        body: [Byte(7)]
    )

    let input = HTTP.Route.Input(request)
    #expect(input.query == [.init(name: "q", value: "one two")])

    #expect(try input.request() == request)
}

@Test
func `the method leaf matches, consumes, and prints`() throws {
    let coder = HTTP.Route.Method(.post)
    var input = HTTP.Route.Input(method: .post)

    try coder.parse(&input)
    #expect(input.method == nil)

    #expect(throws: HTTP.Route.Error.noMatch) {
        try coder.parse(&input)
    }

    var buffer = HTTP.Route.Input()
    coder.serialize((), into: &buffer)
    #expect(buffer.method == .post)
}

@Test
func `a path literal matches one segment and refuses another`() throws {
    let coder = HTTP.Route.Path.Literal("counter")
    var input = HTTP.Route.Input(path: ["counter", "rest"])

    try coder.parse(&input)
    #expect(input.path == ["rest"])

    #expect(throws: HTTP.Route.Error.noMatch) {
        try coder.parse(&input)
    }

    var buffer = HTTP.Route.Input()
    coder.serialize((), into: &buffer)
    #expect(buffer.path == ["counter"])
}

@Test
func `a path capture binds a segment and round trips`() throws {
    let coder = HTTP.Route.Path.Capture(DecimalConversion())
    var input = HTTP.Route.Input(path: ["42", "rest"])

    #expect(try coder.parse(&input) == 42)
    #expect(input.path == ["rest"])

    var buffer = HTTP.Route.Input()
    try coder.serialize(42, into: &buffer)
    #expect(buffer.path == ["42"])
}

@Test
func `a path capture refuses an inadmissible segment without halting the alternation`() {
    let coder = HTTP.Route.Path.Capture(DecimalConversion())

    var empty = HTTP.Route.Input(path: [])
    #expect(throws: HTTP.Route.Error.noMatch) {
        _ = try coder.parse(&empty)
    }

    // A head component is a routing discriminator: an inadmissible segment is
    // noMatch, so `OneOf` still reaches the sibling branch.
    var inadmissible = HTTP.Route.Input(path: ["new"])
    #expect(throws: HTTP.Route.Error.noMatch) {
        _ = try coder.parse(&inadmissible)
    }
    #expect(inadmissible.path == ["new"])
}

@Test
func `a failed capture leaves the input for a sibling literal branch`() throws {
    let capture = HTTP.Route.Path.Capture(DecimalConversion())
    let literal = HTTP.Route.Path.Literal("new")
    var input = HTTP.Route.Input(path: ["new"])

    #expect(throws: HTTP.Route.Error.noMatch) {
        _ = try capture.parse(&input)
    }

    try literal.parse(&input)
    #expect(input.path.isEmpty)
}

@Test
func `a query field binds by name and round trips`() throws {
    let coder = HTTP.Route.Query.Field("limit", DecimalConversion())
    var input = HTTP.Route.Input(
        query: [.init(name: "other", value: "x"), .init(name: "limit", value: "9")]
    )

    #expect(try coder.parse(&input) == 9)
    #expect(input.query == [.init(name: "other", value: "x")])

    #expect(throws: HTTP.Route.Error.noMatch) {
        _ = try coder.parse(&input)
    }

    var valueless = HTTP.Route.Input(query: [.init(name: "limit", value: nil)])
    #expect(throws: HTTP.Route.Error.noMatch) {
        _ = try coder.parse(&valueless)
    }

    var inadmissible = HTTP.Route.Input(query: [.init(name: "limit", value: "nine")])
    #expect(throws: HTTP.Route.Error.noMatch) {
        _ = try coder.parse(&inadmissible)
    }

    var buffer = HTTP.Route.Input()
    try coder.serialize(9, into: &buffer)
    #expect(buffer.query == [.init(name: "limit", value: "9")])
}

@Test
func `a header field binds by name and round trips`() throws {
    let coder = HTTP.Route.Header.Field(.userAgent, TextConversion())
    var input = HTTP.Route.Input(
        headers: [.init(name: .userAgent, value: .init(unchecked: "canary"))]
    )

    #expect(try coder.parse(&input) == "canary")
    #expect(input.headers.isEmpty)

    #expect(throws: HTTP.Route.Error.noMatch) {
        _ = try coder.parse(&input)
    }

    var buffer = HTTP.Route.Input()
    try coder.serialize("canary", into: &buffer)
    #expect(buffer.headers[HTTP.Header.Field.Name.userAgent]?.first?.rawValue == "canary")
}

@Test
func `the body leaf lifts a value coder and rejects a residual payload`() throws {
    let content = HTTP.Coding.Body.Text<String>(decode: { $0 }, encode: { $0 })
    let coder = HTTP.Route.Body(content)

    var buffer = HTTP.Route.Input()
    try coder.serialize("hello", into: &buffer)

    var input = buffer
    #expect(try coder.parse(&input) == "hello")
    #expect(input.body == nil)

    var residual = HTTP.Route.Input(body: [Byte(1)])
    let unconsuming = HTTP.Route.Body(UnconsumingBody())
    #expect(throws: HTTP.Route.Error.malformed) {
        _ = try unconsuming.parse(&residual)
    }
    #expect(residual.body == [Byte(1)])
}
