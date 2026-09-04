import Byte
import Client
import Coder
import Either
import HTTP
import HTTP_Coder
import Operation
import RFC_3986
import RFC_9110
import Testing

private enum Transport: Swift.Error, Equatable {
    case down
}

@Suite
struct `HTTP.Client Tests` {

    @Test
    func `a value and a refusal become responses and decode back`() throws {
        let word = try HTTP.Route.Response.ok(Word("hello"))
        #expect(word.status == .ok)
        #expect(word.content == bytes("hello"))
        #expect(try word.decoded(as: Word.self) == Word("hello"))

        let refusal = try HTTP.Route.Response.badRequest(Refusal.refused)
        #expect(refusal.status == .badRequest)
        #expect(refusal.content == bytes("refused"))
        #expect(try refusal.decoded(as: Refusal.self) == .refused)

        let created = try HTTP.Route.Response(201, Numeral(3))
        #expect(created.status == 201)
        #expect(created.content == bytes("3"))

        let empty = HTTP.Route.Response.ok()
        #expect(empty.status == .ok)
        #expect(empty.content == nil)

        #expect(throws: HTTP.Route.Error.malformed) {
            try word.decoded(as: Numeral.self)
        }
        #expect(throws: HTTP.Route.Error.malformed) {
            try empty.decoded(as: Word.self)
        }
        #expect(throws: HTTP.Route.Error.unprintable) {
            try HTTP.Route.Response.ok(Numeral(42))
        }
    }

    @Test
    func `a client and a server compose through one domain`() async throws {
        let server = HTTP.Client<HTTP.Route.Error> { request throws(HTTP.Route.Error) in
            switch try HTTP.route(Single.self, request) {
            case .respond(let application):
                guard application.input.value < 5 else {
                    return try .badRequest(Refusal.refused)
                }
                return try .ok(Word(String(repeating: "x", count: application.input.value)))
            }
        }
        let remote = HTTP.client(Single.self, Single.Respond.self, transport: server)

        #expect(try await remote(Numeral(3)) == Word("xxx"))

        do throws(Either<Either<HTTP.Route.Error, HTTP.Route.Error>, Refusal>) {
            _ = try await remote(Numeral(7))
            Issue.record("expected a refusal")
        } catch {
            #expect(error == .right(.refused))
        }
    }

    @Test
    func `a transport failure and an unexpected status stay outside the domain`() async throws {
        let down = HTTP.Client<Transport> { _ throws(Transport) in
            throw .down
        }
        let unreachable = HTTP.client(Single.self, Single.Respond.self, transport: down)
        do throws(Either<Either<Transport, HTTP.Route.Error>, Refusal>) {
            _ = try await unreachable(Numeral(1))
            Issue.record("expected the transport failure")
        } catch {
            #expect(error == .left(.left(.down)))
        }

        let broken = HTTP.Client<HTTP.Route.Error> { _ throws(HTTP.Route.Error) in
            HTTP.Route.Response(status: 500)
        }
        let strange = HTTP.client(Single.self, Single.Respond.self, transport: broken)
        do throws(Either<Either<HTTP.Route.Error, HTTP.Route.Error>, Refusal>) {
            _ = try await strange(Numeral(1))
            Issue.record("expected a mismatch")
        } catch {
            #expect(error == .left(.right(.mismatch)))
        }
    }

    @Test
    func `an infallible operation without content has a client too`() async throws {
        var pinged = false
        let server = HTTP.Client<HTTP.Route.Error> { request throws(HTTP.Route.Error) in
            switch try HTTP.route(Root.self, request) {
            case .ping:
                pinged = true
                return .ok()
            case .middle(.leaf(.op(let op))):
                return try .ok(op.input)
            }
        }
        let ping = HTTP.client(Root.self, Root.Ping.self, transport: server)
        try await ping(())
        #expect(pinged)
    }
}
