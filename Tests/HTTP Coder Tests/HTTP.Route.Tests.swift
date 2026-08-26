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
func routeInputSplitsBeforeDecodingSoAnEncodedSolidusIsNeverASeparator() throws {
    let request = HTTP.Request(
        method: .get,
        target: .origin(path: try RFC_3986.URI.Path("/a%2Fb/c"), query: nil)
    )

    let input = HTTP.Route.Input(request)

    #expect(input.path == ["a/b", "c"])
}

@Test
func routeInputRoundTripsARequestThroughDecodedComponents() throws {
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
func methodLeafMatchesConsumesAndPrints() throws {
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
func pathLiteralMatchesOneSegmentAndRefusesAnother() throws {
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
func pathCaptureBindsASegmentAndRoundTrips() throws {
    let coder = HTTP.Route.Path.Capture(DecimalConversion())
    var input = HTTP.Route.Input(path: ["42", "rest"])

    #expect(try coder.parse(&input) == 42)
    #expect(input.path == ["rest"])

    var buffer = HTTP.Route.Input()
    try coder.serialize(42, into: &buffer)
    #expect(buffer.path == ["42"])
}

@Test
func pathCaptureDistinguishesAbsenceFromMalformedness() {
    let coder = HTTP.Route.Path.Capture(DecimalConversion())

    var empty = HTTP.Route.Input(path: [])
    #expect(throws: HTTP.Route.Error.noMatch) {
        _ = try coder.parse(&empty)
    }

    var malformed = HTTP.Route.Input(path: ["twelve"])
    #expect(throws: HTTP.Route.Error.malformed) {
        _ = try coder.parse(&malformed)
    }
    #expect(malformed.path == ["twelve"])
}

@Test
func queryFieldBindsByNameAndRoundTrips() throws {
    let coder = HTTP.Route.Query.Field("limit", DecimalConversion())
    var input = HTTP.Route.Input(
        query: [.init(name: "other", value: "x"), .init(name: "limit", value: "9")]
    )

    #expect(try coder.parse(&input) == 9)
    #expect(input.query == [.init(name: "other", value: "x")])

    #expect(throws: HTTP.Route.Error.noMatch) {
        _ = try coder.parse(&input)
    }

    var buffer = HTTP.Route.Input()
    try coder.serialize(9, into: &buffer)
    #expect(buffer.query == [.init(name: "limit", value: "9")])
}

@Test
func headerFieldBindsByNameAndRoundTrips() throws {
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
func bodyLeafLiftsAValueCoderAndRejectsAResidualPayload() throws {
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
