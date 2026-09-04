import Byte
import Coder
import Either
import HTTP
import HTTP_Coder
import Operation
import Optic
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
        try HTTP.Target.resource(.init(unchecked: "/echo")).parse(&input)
        #expect(throws: HTTP.Route.Error.mismatch) {
            try HTTP.Method.get.parse(&input)
        }
        #expect(throws: HTTP.Route.Error.mismatch) {
            try HTTP.Target.asterisk.parse(&input)
        }
    }

    @Test
    func `the content bridge round trips and commits on trailing or missing bytes`() throws {
        let content = HTTP.Content<HTTP.Route.Request, Numeral.Coder>(Numeral.coder)
        var request = HTTP.Route.Request.blank
        try content.serialize(Numeral(7), into: &request)
        #expect(request.content == bytes("7"))

        var input = request
        #expect(try content.parse(&input) == Numeral(7))
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
            try content.serialize(Numeral(42), into: &unprintable)
        }

        var refused = HTTP.Route.Request(method: .post, target: .asterisk)
        refused.content = bytes("anything")
        #expect(throws: HTTP.Route.Error.malformed) {
            try HTTP.Content(Unprintable()).parse(&refused)
        }
        var buffer = HTTP.Route.Request.blank
        #expect(throws: HTTP.Route.Error.unprintable) {
            try HTTP.Content(Unprintable()).serialize("anything", into: &buffer)
        }
        #expect(buffer.content == nil)
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
        guard case .digit(let application) = try HTTP.route(Committed.self, digit) else {
            Issue.record("expected the digit branch")
            return
        }
        #expect(application.input == Numeral(4))

        var unknown = HTTP.Route.Request(method: .get, target: .resource(.init(unchecked: "/same")))
        unknown.content = bytes("4")
        #expect(throws: HTTP.Route.Error.mismatch) {
            try HTTP.route(Committed.self, unknown)
        }
    }

    @Test
    func `a domain router round trips its calls`() throws {
        let echo = try HTTP.request(Fixture.self, for: .echo(Word("Ada")))
        #expect(echo.method == .post)
        #expect(echo.target == .resource(.init(unchecked: "/echo")))
        #expect(echo.content == bytes("Ada"))
        guard case .echo(let application) = try HTTP.route(Fixture.self, echo) else {
            Issue.record("expected the echo branch")
            return
        }
        #expect(application.input == Word("Ada"))

        let shout = try HTTP.request(Fixture.self, for: .shout(Word("Ada")))
        #expect(shout.target == .resource(.init(unchecked: "/shout")))
        guard case .shout(let shouted) = try HTTP.route(Fixture.self, shout) else {
            Issue.record("expected the shout branch")
            return
        }
        #expect(shouted.input == Word("Ada"))
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

        let respond = Linear.Call.single(.respond(Numeral(4)))
        let respondRequest = try HTTP.request(Linear.self, for: respond)
        #expect(respondRequest.target == .resource(.init(unchecked: "/respond")))
        let routedRespond = try HTTP.route(Linear.self, respondRequest)
        var digit = Numeral(0)
        _ = Linear.Call.folds.single(routedRespond) { single in
            digit = Single.Call.folds.respond.extract(single)?.input ?? Numeral(0)
        }
        #expect(digit == Numeral(4))

        var buffer = HTTP.Route.Request.blank
        #expect(throws: HTTP.Route.Error.mismatch) {
            try HTTP.Route.Case(Linear.Call.cases.single) { Single.router }
                .serialize(Linear.Call.owned(.consume(Owned.Token(value: 1))), into: &buffer)
        }
        #expect(buffer == HTTP.Route.Request.blank)
    }

    @Test
    func `a three-level domain routes through nested cases`() throws {
        let deep = try HTTP.request(Root.self, for: .middle(.leaf(.op(Word("deep")))))
        #expect(deep.method == .put)
        #expect(deep.target == .resource(.init(unchecked: "/leaf")))
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
        #expect(throws: HTTP.Route.Error.malformed) {
            try HTTP.route(Root.self, extra)
        }
    }

    @Test
    func `serializing a call no arm owns is a mismatch`() throws {
        var buffer = HTTP.Route.Request.blank
        #expect(throws: HTTP.Route.Error.mismatch) {
            try HTTP.Route.Case(Root.Ping.self) { HTTP.Method.get }
                .serialize(.middle(.leaf(.op(Word("x")))), into: &buffer)
        }
        #expect(buffer == HTTP.Route.Request.blank)
    }

    @Test
    func `sixteen request routes type-check as one committed choice`() throws {
        for call in [Wide.Call.c1(Word("a")), .c9(Word("i")), .c16(Word("p"))] {
            let request = try HTTP.request(Wide.self, for: call)
            let routed = try HTTP.route(Wide.self, request)
            #expect(try HTTP.request(Wide.self, for: routed) == request)
        }
        let unknown = HTTP.Route.Request(method: .post, target: .resource(.init(unchecked: "/c17")))
        #expect(throws: HTTP.Route.Error.mismatch) {
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
        #expect(try HTTP.target(Site.self, for: .home) == .resource(.init(unchecked: "/")))
        #expect(try HTTP.target(Site.self, for: .api(.shout(Word("a")))) == .resource(.init(unchecked: "/shout")))

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
}
