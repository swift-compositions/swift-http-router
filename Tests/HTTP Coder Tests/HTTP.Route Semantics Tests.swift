import Byte
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

private struct Unprintable: Coding {

    enum Error: Swift.Error {
        case refused
    }

    typealias Input = ArraySlice<Byte>
    typealias Output = String
    typealias Buffer = [Byte]
    typealias Failure = Error

    func parse(_ input: inout ArraySlice<Byte>) throws(Error) -> String {
        throw .refused
    }

    func serialize(_ output: String, into buffer: inout [Byte]) throws(Error) {
        throw .refused
    }
}

@Suite
struct `HTTP.Route Semantics Tests` {

    @Test
    func `every field coder mismatches and never malforms`() throws {
        var request = HTTP.Route.Request(method: .get, target: .asterisk)
        #expect(throws: HTTP.Route.Error.mismatch) { try HTTP.Route.Method(.post).parse(&request) }
        #expect(throws: HTTP.Route.Error.mismatch) {
            try HTTP.Route.Target(.resource(.init(unchecked: "/x"))).parse(&request)
        }
        try HTTP.Route.Method(.get).parse(&request)
        try HTTP.Route.Target(.asterisk).parse(&request)

        var response = HTTP.Route.Response(status: .notFound)
        #expect(throws: HTTP.Route.Error.mismatch) { try HTTP.Route.Status(.ok).parse(&response) }
        try HTTP.Route.Status(.notFound).parse(&response)
    }

    @Test
    func `the content bridge malforms on bytes and is unprintable on values`() throws {
        var request = HTTP.Route.Request(method: .post, target: .asterisk)
        request.content = bytes("anything")
        #expect(throws: HTTP.Route.Error.malformed) {
            try HTTP.Content(Unprintable()).parse(&request)
        }
        var buffer = HTTP.Route.Request.blank
        #expect(throws: HTTP.Route.Error.unprintable) {
            try HTTP.Content(Unprintable()).serialize("anything", into: &buffer)
        }
        #expect(buffer.content == nil)
    }

    @Test
    func `serializing a call no arm owns is a mismatch`() throws {
        var buffer = HTTP.Route.Request.blank
        #expect(throws: HTTP.Route.Error.mismatch) {
            try HTTP.Route.Case(Root.Call.cases.ping) { HTTP.Method.get }
                .serialize(.middle(.leaf(.op("x"))), into: &buffer)
        }
        #expect(buffer == HTTP.Route.Request.blank)
    }

    @Test
    func `a three-level domain routes through nested cases`() throws {
        let describe = Root.Call.Eliminator<String>(
            ping: { _ in "ping" },
            middle: { middle in
                Middle.Call.Eliminator<String>(leaf: { leaf in
                    Leaf.Call.Eliminator<String>(op: { "op:\($0.input)" })(leaf)
                })(middle)
            }
        )
        let deep = Root.Call.middle(.leaf(.op("deep")))
        let request = try HTTP.request(Root.self, for: deep)
        #expect(request.method == .put)
        #expect(request.target == .resource(.init(unchecked: "/leaf")))
        #expect(request.content == bytes("deep"))
        #expect(describe(try HTTP.route(Root.self, request)) == "op:deep")

        let ping = try HTTP.request(Root.self, for: .ping())
        #expect(ping.method == .get)
        #expect(ping.content == nil)
        #expect(describe(try HTTP.route(Root.self, ping)) == "ping")

        var extra = ping
        extra.content = bytes("noise")
        #expect(throws: HTTP.Route.Error.malformed) {
            try HTTP.route(Root.self, extra)
        }
    }

    @Test
    func `sixteen request routes type-check as one committed choice`() throws {
        let describe = Wide.Call.Eliminator<String>(
            c1: { "c1:\($0.input)" }, c2: { "c2:\($0.input)" }, c3: { "c3:\($0.input)" }, c4: { "c4:\($0.input)" },
            c5: { "c5:\($0.input)" }, c6: { "c6:\($0.input)" }, c7: { "c7:\($0.input)" }, c8: { "c8:\($0.input)" },
            c9: { "c9:\($0.input)" }, c10: { "c10:\($0.input)" }, c11: { "c11:\($0.input)" }, c12: { "c12:\($0.input)" },
            c13: { "c13:\($0.input)" }, c14: { "c14:\($0.input)" }, c15: { "c15:\($0.input)" }, c16: { "c16:\($0.input)" }
        )
        for call in [Wide.Call.c1("a"), .c9("i"), .c16("p")] {
            let request = try HTTP.request(Wide.self, for: call)
            #expect(describe(try HTTP.route(Wide.self, request)) == describe(call))
        }
        let unknown = HTTP.Route.Request(method: .post, target: .resource(.init(unchecked: "/c17")))
        #expect(throws: HTTP.Route.Error.mismatch) {
            try HTTP.route(Wide.self, unknown)
        }
    }
}
