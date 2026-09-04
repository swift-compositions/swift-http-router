import Byte
import Byte_Coder
import Byte_Standard_Library_Integration
import Checkpoint_Coder
import Coder
import Either
import HTTP
import HTTP_Coder
import Operation
import Operation_Coder
import Optic
import Optic_Coder
import Parser
import RFC_3986
import Serializer
import String_Coder
import Tagged
import Tagged_Coder
import Tagged_Standard_Library_Integration
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
struct `HTTP.Router Tests` {

    @Test
    func `field coders mismatch on parse and set their field on serialize`() throws {
        var request = HTTP.Router.Request.blank
        try HTTP.Method.post.serialize((), into: &request)
        try HTTP.Target(unchecked: "/echo").serialize((), into: &request)
        #expect(request.method == .post)
        #expect(request.target == HTTP.Target(unchecked: "/echo"))

        var input = request
        try HTTP.Method.post.parse(&input)
        try HTTP.Target(unchecked: "/echo").parse(&input)
        #expect(throws: HTTP.Router.Error.mismatch) {
            try HTTP.Method.get.parse(&input)
        }
        #expect(throws: HTTP.Router.Error.mismatch) {
            try HTTP.Target.asterisk.parse(&input)
        }
    }

    @Test
    func `the content bridge round trips and commits on trailing or missing bytes`() throws {
        let content = HTTP.Content<HTTP.Router.Request, Limit.Coder>(Limit.self)
        var request = HTTP.Router.Request.blank
        try content.serialize(Limit(7), into: &request)
        #expect(request.content == bytes("7"))

        var input = request
        #expect(try content.parse(&input) == Limit(7))
        #expect(input.content == nil)

        var missing = HTTP.Router.Request.blank
        #expect(throws: HTTP.Router.Error.malformed) {
            try content.parse(&missing)
        }

        var refused = HTTP.Router.Request(method: .post, target: .asterisk)
        refused.content = bytes("anything")
        #expect(throws: HTTP.Router.Error.malformed) {
            try HTTP.Content(Unprintable()).parse(&refused)
        }
        var buffer = HTTP.Router.Request.blank
        #expect(throws: HTTP.Router.Error.unprintable) {
            try HTTP.Content(Unprintable()).serialize("anything", into: &buffer)
        }
        #expect(buffer.content == nil)
    }

    @Test
    func `a mismatching arm retries and a malformed arm commits`() throws {
        var name = HTTP.Router.Request(method: .post, target: HTTP.Target(unchecked: "/same"))
        name.content = bytes("hello")
        #expect(throws: HTTP.Router.Error.malformed) {
            try HTTP.route(Committed.self, name)
        }

        var count = name
        count.content = bytes("4")
        guard case .count(let application) = try HTTP.route(Committed.self, count) else {
            Issue.record("expected the count branch")
            return
        }
        #expect(application.input == Limit(4))

        var unknown = HTTP.Router.Request(method: .get, target: HTTP.Target(unchecked: "/same"))
        unknown.content = bytes("4")
        #expect(throws: HTTP.Router.Error.mismatch) {
            try HTTP.route(Committed.self, unknown)
        }
    }

    @Test
    func `a domain router round trips its calls`() throws {
        let echo = try HTTP.request(Fixture.self, for: .echo(Word("Ada")))
        #expect(echo.method == .post)
        #expect(echo.target == HTTP.Target(unchecked: "/echo"))
        #expect(echo.content == bytes("Ada"))
        guard case .echo(let application) = try HTTP.route(Fixture.self, echo) else {
            Issue.record("expected the echo branch")
            return
        }
        #expect(application.input == Word("Ada"))

        let shout = try HTTP.request(Fixture.self, for: .shout(Word("Ada")))
        #expect(shout.target == HTTP.Target(unchecked: "/shout"))
        guard case .shout(let shouted) = try HTTP.route(Fixture.self, shout) else {
            Issue.record("expected the shout branch")
            return
        }
        #expect(shouted.input == Word("Ada"))
    }

    @Test
    func `a noncopyable root routes its calls from a borrow`() throws {
        let consumeRequest = try HTTP.request(
            Linear.self,
            for: Linear.Call.owned(.consume(Owned.Token(value: 4)))
        )
        let consumeRequestAgain = try HTTP.request(
            Linear.self,
            for: Linear.Call.owned(.consume(Owned.Token(value: 4)))
        )
        #expect(consumeRequest.target == HTTP.Target(unchecked: "/consume"))
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

        let respond = Linear.Call.single(.respond(Limit(4)))
        let respondRequest = try HTTP.request(Linear.self, for: respond)
        #expect(respondRequest.target == HTTP.Target(unchecked: "/respond"))
        let routedRespond = try HTTP.route(Linear.self, respondRequest)
        var limit = Limit(0)
        _ = Linear.Call.folds.single(routedRespond) { single in
            limit = Single.Call.folds.respond.extract(single)?.input ?? Limit(0)
        }
        #expect(limit == Limit(4))
    }

    @Test
    func `serializing a call no arm owns is a mismatch`() throws {
        var buffer = HTTP.Router.Request.blank
        #expect(throws: HTTP.Router.Error.mismatch) {
            try Coder.Case(Linear.Call.cases.single, absent: HTTP.Router.Error.mismatch) { Single.router }
                .serialize(Linear.Call.owned(.consume(Owned.Token(value: 1))), into: &buffer)
        }
        #expect(buffer == HTTP.Router.Request.blank)
    }

    @Test
    func `a three-level domain routes through nested cases`() throws {
        let deep = try HTTP.request(Root.self, for: .middle(.leaf(.op(Word("deep")))))
        #expect(deep.method == .put)
        #expect(deep.target == HTTP.Target(unchecked: "/leaf"))
        #expect(deep.content == bytes("deep"))
        guard case .middle(.leaf(.op(let op))) = try HTTP.route(Root.self, deep) else {
            Issue.record("expected the leaf operation")
            return
        }
        #expect(op.input == Word("deep"))

        let ping = try HTTP.request(Root.self, for: .ping())
        #expect(ping.method == .get)
        #expect(ping.content == nil)
        guard case .ping = try HTTP.route(Root.self, ping) else {
            Issue.record("expected the ping branch")
            return
        }

        var extra = ping
        extra.content = bytes("noise")
        #expect(throws: HTTP.Router.Error.malformed) {
            try HTTP.route(Root.self, extra)
        }
    }

    @Test
    func `sixteen request routes are one alternation`() throws {
        for call in [Wide.Call.c1(Word("a")), .c9(Word("i")), .c16(Word("p"))] {
            let request = try HTTP.request(Wide.self, for: call)
            let routed = try HTTP.route(Wide.self, request)
            #expect(try HTTP.request(Wide.self, for: routed) == request)
        }
        let unknown = HTTP.Router.Request(method: .post, target: HTTP.Target(unchecked: "/c17"))
        #expect(throws: HTTP.Router.Error.mismatch) {
            try HTTP.route(Wide.self, unknown)
        }
    }

    @Test
    func `a site embeds a domain's calls beside its own pages`() throws {
        let api = try HTTP.request(Site.self, for: .api(.echo(Word("a"))))
        let domain = try HTTP.request(Fixture.self, for: .echo(Word("a")))
        #expect(api == domain)

        let home = try HTTP.request(Site.self, for: .home)
        #expect(home.method == .get)
        #expect(home.content == nil)
        #expect(try HTTP.target(Site.self, for: .home) == HTTP.Target(unchecked: "/"))
        #expect(try HTTP.target(Site.self, for: .api(.shout(Word("a")))) == HTTP.Target(unchecked: "/shout"))

        guard case .home = try HTTP.route(Site.self, home) else {
            Issue.record("expected the home page")
            return
        }
        guard case .api(.echo(let application)) = try HTTP.route(Site.self, api) else {
            Issue.record("expected the echo operation")
            return
        }
        #expect(application.input == Word("a"))
    }

    @Test
    func `responses carry values and refusals and read them back`() throws {
        let word = try HTTP.Router.Response.ok(Word("hello"))
        #expect(word.status == .ok)
        #expect(word.content == bytes("hello"))
        #expect(try word.decoded(as: Word.self) == Word("hello"))

        let refusal = try HTTP.Router.Response.badRequest(Refusal.refused)
        #expect(refusal.status == .badRequest)
        #expect(refusal.content == bytes("refused"))
        #expect(try refusal.decoded(as: Refusal.self) == .refused)

        let created = try HTTP.Router.Response(201, Limit(3))
        #expect(created.status == 201)
        #expect(created.content == bytes("3"))

        let empty = HTTP.Router.Response.ok()
        #expect(empty.status == .ok)
        #expect(empty.content == nil)

        #expect(throws: HTTP.Router.Error.malformed) {
            try word.decoded(as: Limit.self)
        }
        #expect(throws: HTTP.Router.Error.malformed) {
            try empty.decoded(as: Word.self)
        }
        #expect(throws: HTTP.Router.Error.unprintable) {
            try HTTP.Router.Response.ok(Ineffable.value)
        }
    }
}
