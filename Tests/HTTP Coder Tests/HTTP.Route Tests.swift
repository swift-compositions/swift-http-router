import Byte
import Byte_Standard_Library_Integration
import Cursor_Standard_Library_Integration
import Client
import Coder
import Either
import HTTP
import HTTP_Coder
import Operation
import Optic
import Optic_Coder
import Parser
import Parser_Skip
import RFC_3986
import RFC_9110
import Serializer
import Testing

enum Fixture {
    enum Echo: Operation.Symbol {
        typealias Input = String
        typealias Output = String
        typealias Failure = Never
    }

    enum Shout: Operation.Symbol {
        typealias Input = String
        typealias Output = String
        typealias Failure = Fixture.Refusal
    }

    enum Call {
        case echo(Operation.Application<Echo>)
        case shout(Operation.Application<Shout>)
    }

    enum Refusal: Swift.Error, Equatable {
        case refused
    }
}

extension Fixture.Call: Operation.Coproduct {

    typealias Operations = Either<Fixture.Echo, Fixture.Shout>

    struct Prisms {
        var echo: Optic<Fixture.Call, Fixture.Call, Operation.Application<Fixture.Echo>, Operation.Application<Fixture.Echo>>.Prism {
            .init(
                embed: Fixture.Call.echo,
                extract: { call in if case .echo(let focus) = call { focus } else { nil } }
            )
        }

        var shout: Optic<Fixture.Call, Fixture.Call, Operation.Application<Fixture.Shout>, Operation.Application<Fixture.Shout>>.Prism {
            .init(
                embed: Fixture.Call.shout,
                extract: { call in if case .shout(let focus) = call { focus } else { nil } }
            )
        }
    }

    static var prisms: Prisms { .init() }
}

extension Fixture.Call: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.echo(let left), .echo(let right)): left.input == right.input
        case (.shout(let left), .shout(let right)): left.input == right.input
        default: false
        }
    }
}

extension Fixture: HTTP.Routable {

    static var route: some HTTP.Routing<Call> {
        HTTP.Route.Case(Call.prisms.echo) {
            .post
            HTTP.Target.resource(.init(unchecked: "/echo"))
            HTTP.Content(HTTP.Message.Content.Text())
        }
        HTTP.Route.Case(Call.prisms.shout) {
            .post
            HTTP.Target.resource(.init(unchecked: "/shout"))
            HTTP.Content(HTTP.Message.Content.Text())
        }
    }
}

struct Digit: Coding {

    enum Error: Swift.Error, Equatable {
        case notADigit
    }

    typealias Input = ArraySlice<Byte>
    typealias Output = Int
    typealias Buffer = [Byte]
    typealias Failure = Error

    func parse(_ input: inout ArraySlice<Byte>) throws(Error) -> Int {
        guard let byte = input.next(), (0x30...0x39).contains(byte.bitPattern) else {
            throw .notADigit
        }
        return Int(byte.bitPattern - 0x30)
    }

    func serialize(_ output: Int, into buffer: inout [Byte]) throws(Error) {
        guard (0...9).contains(output) else {
            throw .notADigit
        }
        buffer.append(Byte(bitPattern: UInt8(0x30 + output)))
    }
}

enum Single {
    enum Respond: Operation.Symbol {
        typealias Input = Int
        typealias Output = String
        typealias Failure = Fixture.Refusal
    }

    enum Call {
        case respond(Operation.Application<Respond>)
    }
}

extension Single.Call: Operation.Coproduct {

    typealias Operations = Single.Respond

    struct Prisms {
        var respond: Optic<Single.Call, Single.Call, Operation.Application<Single.Respond>, Operation.Application<Single.Respond>>.Prism {
            .init(
                embed: Single.Call.respond,
                extract: { call in if case .respond(let focus) = call { focus } else { nil } }
            )
        }
    }

    static var prisms: Prisms { .init() }
}

extension Single: HTTP.Routable {

    static var route: some HTTP.Routing<Call> {
        HTTP.Route.Case(Call.prisms.respond) {
            .post
            HTTP.Target.resource(.init(unchecked: "/respond"))
            HTTP.Content(Digit())
        }
    }
}

extension Single.Respond: HTTP.Respondable {

    static var response: some HTTP.Replying<Swift.Result<String, Fixture.Refusal>> {
        Coder.Case(Swift.Result<String, Fixture.Refusal>.prisms.success, absent: .mismatch) {
            HTTP.Status.ok {
                HTTP.Content(HTTP.Message.Content.Text())
            }
        }
        Coder.Case(Swift.Result<String, Fixture.Refusal>.prisms.failure, absent: .mismatch) {
            .badRequest
            HTTP.Content(
                HTTP.Message.Content.Text().map(
                    to: { _ in Fixture.Refusal.refused },
                    from: { _ in "refused" }
                )
            )
        }
    }
}

enum Committed {
    enum Digit: Operation.Symbol {
        typealias Input = Int
        typealias Output = Int
        typealias Failure = Never
    }

    enum Text: Operation.Symbol {
        typealias Input = String
        typealias Output = String
        typealias Failure = Never
    }

    enum Call {
        case digit(Operation.Application<Digit>)
        case text(Operation.Application<Text>)
    }
}

extension Committed.Call: Operation.Coproduct {

    typealias Operations = Either<Committed.Digit, Committed.Text>

    struct Prisms {
        var digit: Optic<Committed.Call, Committed.Call, Operation.Application<Committed.Digit>, Operation.Application<Committed.Digit>>.Prism {
            .init(
                embed: Committed.Call.digit,
                extract: { call in if case .digit(let focus) = call { focus } else { nil } }
            )
        }

        var text: Optic<Committed.Call, Committed.Call, Operation.Application<Committed.Text>, Operation.Application<Committed.Text>>.Prism {
            .init(
                embed: Committed.Call.text,
                extract: { call in if case .text(let focus) = call { focus } else { nil } }
            )
        }
    }

    static var prisms: Prisms { .init() }
}

extension Committed.Call: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.digit(let left), .digit(let right)): left.input == right.input
        case (.text(let left), .text(let right)): left.input == right.input
        default: false
        }
    }
}

extension Committed: HTTP.Routable {

    static var route: some HTTP.Routing<Call> {
        HTTP.Route.Case(Call.prisms.digit) {
            .post
            HTTP.Target.resource(.init(unchecked: "/same"))
            HTTP.Content(Digit())
        }
        HTTP.Route.Case(Call.prisms.text) {
            .post
            HTTP.Target.resource(.init(unchecked: "/same"))
            HTTP.Content(HTTP.Message.Content.Text())
        }
    }
}

enum Sixteen: Equatable, Sendable {
    case c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16
}

extension Sixteen {

    static func row(_ value: Self) -> Optic<Self, Self, Void, Void>.Prism {
        .fixed(value)
    }

    @HTTP.Route.Builder<Sixteen>
    static var rows: some HTTP.Replying<Sixteen> {
        Coder.Case(row(.c1), absent: .mismatch) { HTTP.Status(201) }
        Coder.Case(row(.c2), absent: .mismatch) { HTTP.Status(202) }
        Coder.Case(row(.c3), absent: .mismatch) { HTTP.Status(203) }
        Coder.Case(row(.c4), absent: .mismatch) { HTTP.Status(204) }
        Coder.Case(row(.c5), absent: .mismatch) { HTTP.Status(205) }
        Coder.Case(row(.c6), absent: .mismatch) { HTTP.Status(206) }
        Coder.Case(row(.c7), absent: .mismatch) { HTTP.Status(207) }
        Coder.Case(row(.c8), absent: .mismatch) { HTTP.Status(208) }
        Coder.Case(row(.c9), absent: .mismatch) { HTTP.Status(209) }
        Coder.Case(row(.c10), absent: .mismatch) { HTTP.Status(210) }
        Coder.Case(row(.c11), absent: .mismatch) { HTTP.Status(211) }
        Coder.Case(row(.c12), absent: .mismatch) { HTTP.Status(212) }
        Coder.Case(row(.c13), absent: .mismatch) { HTTP.Status(213) }
        Coder.Case(row(.c14), absent: .mismatch) { HTTP.Status(214) }
        Coder.Case(row(.c15), absent: .mismatch) { HTTP.Status(215) }
        Coder.Case(row(.c16), absent: .mismatch) { HTTP.Status(216) }
    }
}

func bytes(_ text: String) -> [Byte] {
    text.utf8.map(Byte.init(bitPattern:))
}

@Suite
struct `HTTP.Route Tests` {

    @Test
    func `field coders mismatch on parse and set their field on serialize`() throws {
        var request = HTTP.Route.Request.blank
        try HTTP.Method.post.serialize((), into: &request)
        try HTTP.Target.resource(.init(unchecked: "/echo")).serialize((), into: &request)
        #expect(request.method == .post)
        #expect(request.target == .resource(.init(unchecked: "/echo")))

        var input = request
        try HTTP.Method.post.parse(&input)
        #expect(throws: HTTP.Route.Error.mismatch) {
            try HTTP.Method.get.parse(&input)
        }

        var response = HTTP.Route.Response.blank
        try HTTP.Status.badRequest.serialize((), into: &response)
        #expect(response.status == .badRequest)
        #expect(throws: HTTP.Route.Error.mismatch) {
            try HTTP.Status.ok.parse(&response)
        }
    }

    @Test
    func `the content bridge round trips and commits on trailing or missing bytes`() throws {
        let content = HTTP.Content<HTTP.Route.Request, Digit>(Digit())
        var request = HTTP.Route.Request.blank
        try content.serialize(7, into: &request)
        #expect(request.content == bytes("7"))

        var input = request
        #expect(try content.parse(&input) == 7)
        #expect(input.content == nil)

        var trailing = HTTP.Route.Request.blank
        trailing.content = bytes("78")
        #expect(throws: HTTP.Route.Error.malformed) {
            try content.parse(&trailing)
        }

        var missing = HTTP.Route.Request.blank
        #expect(throws: HTTP.Route.Error.malformed) {
            try content.parse(&missing)
        }

        var unprintable = HTTP.Route.Request.blank
        #expect(throws: HTTP.Route.Error.unprintable) {
            try content.serialize(42, into: &unprintable)
        }
    }

    @Test
    func `a mismatching arm retries and a malformed arm commits`() throws {
        var text = HTTP.Route.Request(method: .post, target: .resource(.init(unchecked: "/same")))
        text.content = bytes("hello")
        #expect(throws: HTTP.Route.Error.malformed) {
            try HTTP.route(Committed.self, text)
        }

        var digit = text
        digit.content = bytes("4")
        #expect(try HTTP.route(Committed.self, digit) == .digit(.init(4)))

        var unknown = HTTP.Route.Request(method: .get, target: .resource(.init(unchecked: "/same")))
        unknown.content = bytes("4")
        #expect(throws: HTTP.Route.Error.mismatch) {
            try HTTP.route(Committed.self, unknown)
        }
    }

    @Test
    func `the domain router round trips both calls`() throws {
        for call in [Fixture.Call.echo(.init("Ada")), .shout(.init("Ada"))] {
            let request = try HTTP.request(Fixture.self, for: call)
            #expect(request.method == .post)
            #expect(request.content == bytes("Ada"))
            #expect(try HTTP.route(Fixture.self, request) == call)
        }
        #expect(
            try HTTP.request(Fixture.self, for: .shout(.init("x"))).target
                == .resource(.init(unchecked: "/shout"))
        )
    }

    @Test
    func `a response round trips its success and refusal rows`() throws {
        for result in [Swift.Result<String, Fixture.Refusal>.success("hello"), .failure(.refused)] {
            var response = HTTP.Route.Response.blank
            try Single.Respond.response.serialize(result, into: &response)
            var input = response
            #expect(try Single.Respond.response.parse(&input) == result)
            #expect(input.content == nil)
        }
        var response = HTTP.Route.Response.blank
        try Single.Respond.response.serialize(.failure(.refused), into: &response)
        #expect(response.status == .badRequest)
    }

    @Test
    func `sixteen reply rows type-check as one committed choice`() throws {
        var response = HTTP.Route.Response.blank
        try Sixteen.rows.serialize(.c9, into: &response)
        #expect(response.status == 209)

        var input = HTTP.Route.Response(status: 205)
        #expect(try Sixteen.rows.parse(&input) == .c5)

        var unknown = HTTP.Route.Response(status: 500)
        #expect(throws: HTTP.Route.Error.mismatch) {
            try Sixteen.rows.parse(&unknown)
        }
    }

    @Test
    func `a client and a responder compose through the same domain`() async throws {
        let operation = Client::Client<Int, String, Fixture.Refusal>(
            run: { digit throws(Fixture.Refusal) in
                guard digit < 5 else { throw .refused }
                return String(repeating: "x", count: digit)
            }
        )
        let responder = HTTP.Responder<HTTP.Route.Error>(
            run: { request throws(HTTP.Route.Error) in
                let call = try HTTP.route(Single.self, request)
                switch call {
                case .respond(let application):
                    return try await HTTP.response(Single.Respond.self, to: application.input, using: operation)
                }
            }
        )
        let remote = HTTP.client(Single.self, Single.Call.prisms.respond, transport: responder)

        #expect(try await remote(3) == "xxx")

        do throws(Either<Either<HTTP.Route.Error, HTTP.Route.Error>, Fixture.Refusal>) {
            _ = try await remote(7)
            Issue.record("expected a refusal")
        } catch {
            #expect(error == .right(.refused))
        }
    }
}
