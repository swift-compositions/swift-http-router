import Byte
import Byte_Standard_Library_Integration
import Cursor_Standard_Library_Integration
import Call_Algebra
import Client
import Coder
import Either
import HTTP
import HTTP_Coder
import Optic
import Optic_Coder
import Parser
import Parser_Skip
import RFC_3986
import RFC_9110
import Serializer
import Testing

enum Fixture {}

extension Fixture {

    enum Call: Equatable {
        case echo(String)
        case shout(String)
    }

    enum Refusal: Swift.Error, Equatable {
        case refused
    }
}

extension Fixture.Call {

    enum Branch {
        enum Echo {}
        enum Shout {}
    }

    struct Branches {

        var echo: Call_Algebra.Call.Branch<Fixture.Call, String, Branch.Echo> {
            .init(
                .init(
                    embed: Fixture.Call.echo,
                    extract: { call in
                        switch call {
                        case .echo(let text): text
                        case .shout: nil
                        }
                    }
                )
            )
        }

        var shout: Call_Algebra.Call.Branch<Fixture.Call, String, Branch.Shout> {
            .init(
                .init(
                    embed: Fixture.Call.shout,
                    extract: { call in
                        switch call {
                        case .echo: nil
                        case .shout(let text): text
                        }
                    }
                )
            )
        }
    }
}

extension Fixture.Call.Branch.Echo: Call_Algebra.Call.Operation {
    typealias Input = String
    typealias Output = String
    typealias Failure = Never
}

extension Fixture.Call.Branch.Shout: Call_Algebra.Call.Operation {
    typealias Input = String
    typealias Output = String
    typealias Failure = Fixture.Refusal
}

extension Fixture.Call: Call_Algebra.Call.`Protocol` {
    typealias Coverage = Call_Algebra.Call.Coverage<Branch.Echo, Branch.Shout>

    static var branches: Branches { .init() }
}

extension Fixture: HTTP.Routable {

    static var route: some HTTP.Routing<Call> {
        HTTP.Route.Case(\.echo) {
            .post
            HTTP.Target.resource(.init(unchecked: "/echo"))
            HTTP.Content(HTTP.Message.Content.Text())
        }
        HTTP.Route.Case(\.shout) {
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

enum Single {}

extension Single {

    enum Call: Equatable {
        case respond(Int)
    }
}

extension Single.Call {

    enum Branch {
        enum Respond {}
    }

    struct Branches {

        var respond: Call_Algebra.Call.Branch<Single.Call, Int, Branch.Respond> {
            .init(
                .init(
                    embed: Single.Call.respond,
                    extract: { call in
                        switch call {
                        case .respond(let digit): digit
                        }
                    }
                )
            )
        }
    }
}

extension Single.Call.Branch.Respond: Call_Algebra.Call.Operation {
    typealias Input = Int
    typealias Output = String
    typealias Failure = Fixture.Refusal
}

extension Single.Call: Call_Algebra.Call.Singleton {
    typealias Operation = Branch.Respond
    typealias Coverage = Branch.Respond

    static var branches: Branches { .init() }

    static var value: Optic<Self, Self, Int, Int>.Prism {
        branches.respond.prism
    }
}

extension Single: HTTP.Routable {

    static var route: some HTTP.Routing<Call> {
        HTTP.Route.Case(\.respond) {
            .post
            HTTP.Target.resource(.init(unchecked: "/respond"))
            HTTP.Content(Digit())
        }
    }
}

extension Single: HTTP.Respondable {

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

enum Committed {}

extension Committed {

    enum Call: Equatable {
        case digit(Int)
        case text(String)
    }
}

extension Committed.Call {

    enum Branch {
        enum Digit {}
        enum Text {}
    }

    struct Branches {

        var digit: Call_Algebra.Call.Branch<Committed.Call, Int, Branch.Digit> {
            .init(
                .init(
                    embed: Committed.Call.digit,
                    extract: { call in
                        switch call {
                        case .digit(let digit): digit
                        case .text: nil
                        }
                    }
                )
            )
        }

        var text: Call_Algebra.Call.Branch<Committed.Call, String, Branch.Text> {
            .init(
                .init(
                    embed: Committed.Call.text,
                    extract: { call in
                        switch call {
                        case .digit: nil
                        case .text(let text): text
                        }
                    }
                )
            )
        }
    }
}

extension Committed.Call: Call_Algebra.Call.`Protocol` {
    typealias Coverage = Call_Algebra.Call.Coverage<Branch.Digit, Branch.Text>

    static var branches: Branches { .init() }
}

extension Committed: HTTP.Routable {

    static var route: some HTTP.Routing<Call> {
        HTTP.Route.Case(\.digit) {
            .post
            HTTP.Target.resource(.init(unchecked: "/same"))
            HTTP.Content(Digit())
        }
        HTTP.Route.Case(\.text) {
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
        #expect(try HTTP.route(Committed.self, digit) == .digit(4))

        var unknown = HTTP.Route.Request(method: .get, target: .resource(.init(unchecked: "/same")))
        unknown.content = bytes("4")
        #expect(throws: HTTP.Route.Error.mismatch) {
            try HTTP.route(Committed.self, unknown)
        }
    }

    @Test
    func `the domain router round trips both calls`() throws {
        for call in [Fixture.Call.echo("Ada"), .shout("Ada")] {
            let request = try HTTP.request(Fixture.self, for: call)
            #expect(request.method == .post)
            #expect(request.content == bytes("Ada"))
            #expect(try HTTP.route(Fixture.self, request) == call)
        }
        #expect(
            try HTTP.request(Fixture.self, for: .shout("x")).target
                == .resource(.init(unchecked: "/shout"))
        )
    }

    @Test
    func `a response round trips its success and refusal rows`() throws {
        for result in [Swift.Result<String, Fixture.Refusal>.success("hello"), .failure(.refused)] {
            var response = HTTP.Route.Response.blank
            try Single.response.serialize(result, into: &response)
            var input = response
            #expect(try Single.response.parse(&input) == result)
            #expect(input.content == nil)
        }
        var response = HTTP.Route.Response.blank
        try Single.response.serialize(.failure(.refused), into: &response)
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
                case .respond(let digit):
                    return try await HTTP.response(Single.self, to: digit, using: operation)
                }
            }
        )
        let remote = HTTP.client(Single.self, transport: responder)

        #expect(try await remote(3) == "xxx")

        do throws(Either<Either<HTTP.Route.Error, HTTP.Route.Error>, Fixture.Refusal>) {
            _ = try await remote(7)
            Issue.record("expected a refusal")
        } catch {
            #expect(error == .right(.refused))
        }
    }
}
