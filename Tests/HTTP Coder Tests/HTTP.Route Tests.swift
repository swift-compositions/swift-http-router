import Byte
import Client
import Coder
import Either
import HTTP
import HTTP_Coder
import Operation
import Optic
import Optic_Coder
import Parser
import RFC_3986
import RFC_9110
import Serializer
import Testing

@Suite
struct `HTTP.Route Tests` {

    @Test
    func `field coders mismatch on parse and set their field on serialize`() throws {
        var request = HTTP.Route.Request.blank
        try HTTP.Route.Method(.post).serialize((), into: &request)
        try HTTP.Route.Target(.resource(.init(unchecked: "/echo"))).serialize((), into: &request)
        #expect(request.method == .post)
        #expect(request.target == .resource(.init(unchecked: "/echo")))

        var input = request
        try HTTP.Route.Method(.post).parse(&input)
        #expect(throws: HTTP.Route.Error.mismatch) {
            try HTTP.Route.Method(.get).parse(&input)
        }

        var response = HTTP.Route.Response.blank
        try HTTP.Route.Status(.badRequest).serialize((), into: &response)
        #expect(response.status == .badRequest)
        #expect(throws: HTTP.Route.Error.mismatch) {
            try HTTP.Route.Status(.ok).parse(&response)
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
        let routed = try HTTP.route(Committed.self, digit)
        #expect(Committed.Call.folds.digit.extract(routed)?.input == 4)

        var unknown = HTTP.Route.Request(method: .get, target: .resource(.init(unchecked: "/same")))
        unknown.content = bytes("4")
        #expect(throws: HTTP.Route.Error.mismatch) {
            try HTTP.route(Committed.self, unknown)
        }
    }

    @Test
    func `the domain router round trips both calls`() throws {
        let describe = Fixture.Call.Eliminator<String>(
            echo: { "echo:\($0.input)" },
            shout: { "shout:\($0.input)" }
        )
        for call in [Fixture.Call.echo("Ada"), .shout("Ada")] {
            let request = try HTTP.request(Fixture.self, for: call)
            #expect(request.method == .post)
            #expect(request.content == bytes("Ada"))
            let routed = try HTTP.route(Fixture.self, request)
            #expect(describe(routed) == describe(call))
        }
        #expect(
            try HTTP.request(Fixture.self, for: .shout("x")).target
                == .resource(.init(unchecked: "/shout"))
        )
    }

    @Test
    func `a noncopyable root routes its calls from a borrow`() throws {
        let consume = Linear.Call.owned(.consume(Owned.Token(value: 4)))
        let consumeRequest = try HTTP.request(Linear.self, for: consume)
        let consumeRequestAgain = try HTTP.request(Linear.self, for: consume)
        #expect(consumeRequest.target == .resource(.init(unchecked: "/consume")))
        #expect(consumeRequest.content == bytes("4"))
        #expect(consumeRequest == consumeRequestAgain)
        let routedConsume = try HTTP.route(Linear.self, consumeRequest)
        var value = 0
        let visited = Linear.Call.folds.owned(routedConsume) { owned in
            _ = Owned.Call.folds.consume(owned) { application in
                value = application.input.value
            }
        }
        #expect(visited)
        #expect(value == 4)

        let respond = Linear.Call.single(.respond(4))
        let respondRequest = try HTTP.request(Linear.self, for: respond)
        #expect(respondRequest.target == .resource(.init(unchecked: "/respond")))
        let routedRespond = try HTTP.route(Linear.self, respondRequest)
        var digit = 0
        _ = Linear.Call.folds.single(routedRespond) { single in
            digit = Single.Call.folds.respond.extract(single)?.input ?? 0
        }
        #expect(digit == 4)

        var buffer = HTTP.Route.Request.blank
        #expect(throws: HTTP.Route.Error.mismatch) {
            try HTTP.Route.Case(Linear.Call.prisms.single, Linear.Call.folds.single) { Single.route }
                .serialize(Linear.Call.owned(.consume(Owned.Token(value: 1))), into: &buffer)
        }
        #expect(buffer == HTTP.Route.Request.blank)
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
