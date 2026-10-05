import Case_Macro
import Coder
import HTTP
import HTTP_Router
import RFC_3986
import RFC_9110
import Tagged
import Testing

@Prisms
@Folds
@Cases
enum Member: Equatable, Sendable {
    case show(Limit)
    case logout
}

@Prisms
@Folds
@Cases
enum Portal: Equatable, Sendable {
    case account(Member)
    case items(Limit)
    case item(Word)
    case home
}

extension Member: HTTP.Routable {

    static var router: some HTTP.Router.`Protocol`<Member> {
        Coder::Case(Member.cases.show.prism, Member.cases.show.fold, absent: .mismatch) {
            .get
            HTTP.Segment.Value<Limit>()
        }
        Coder::Case(Member.cases.logout.prism, Member.cases.logout.fold, absent: .mismatch) {
            .post
            HTTP.Segment("logout")
        }
    }
}

extension Portal: HTTP.Routable {

    static var router: some HTTP.Router.`Protocol`<Portal> {
        Coder::Case(Portal.cases.account.prism, Portal.cases.account.fold, absent: .mismatch) {
            HTTP.Segment("account")
            Member.router
        }
        Coder::Case(Portal.cases.items.prism, Portal.cases.items.fold, absent: .mismatch) {
            .get
            HTTP.Segment("items")
            HTTP.Segment.End()
            HTTP.Query.Field<Limit>("page", default: Limit(1))
        }
        Coder::Case(Portal.cases.item.prism, Portal.cases.item.fold, absent: .mismatch) {
            .get
            HTTP.Segment("items")
            HTTP.Segment.Value<Word>()
        }
        Coder::Case(Portal.cases.home.prism, Portal.cases.home.fold, absent: .mismatch) {
            .get
            HTTP.Segment.End()
        }
    }
}

@Suite
struct `HTTP.Segment.Nesting Tests` {

    static func request(_ method: HTTP.Method, _ target: String) -> HTTP.Router.Request {
        HTTP.Router.Request(method: method, target: .resource(RFC_3986.URI(unchecked: target)))
    }

    static func roundTrip(_ site: Portal, _ method: HTTP.Method, _ target: String) throws {
        let request = try HTTP.request(Portal.self, for: site)
        #expect(request.method == method)
        #expect(request.target == Self.request(method, target).target)
        #expect(try HTTP.route(Portal.self, request) == site)
        #expect(try HTTP.route(Portal.self, Self.request(method, target)) == site)
    }

    @Test
    func `a child router nests under its prefix`() throws {
        try Self.roundTrip(.account(.show(Limit(7))), .get, "/account/7")
        try Self.roundTrip(.account(.logout), .post, "/account/logout")
    }

    @Test
    func `overlapping paths pick the case that consumes the whole path`() throws {
        try Self.roundTrip(.items(Limit(1)), .get, "/items")
        try Self.roundTrip(.items(Limit(3)), .get, "/items?page=3")
        try Self.roundTrip(.item(Word("seven")), .get, "/items/seven")
        try Self.roundTrip(.home, .get, "/")
    }

    @Test
    func `a percent-encoded segment decodes and re-encodes`() throws {
        try Self.roundTrip(.item(Word("a b/c")), .get, "/items/a%20b%2Fc")
    }

    @Test
    func `the whole remaining path must be consumed`() {
        #expect(throws: HTTP.Router.Error.self) {
            try HTTP.route(Portal.self, Self.request(.post, "/account/logout/now"))
        }
        #expect(throws: HTTP.Router.Error.self) {
            try HTTP.route(Portal.self, Self.request(.get, "/items/seven/eight"))
        }
    }

    @Test
    func `a failed branch leaves no trace on the next branch`() throws {
        #expect(try HTTP.route(Portal.self, Self.request(.get, "/account/7")) == .account(.show(Limit(7))))
        #expect(throws: HTTP.Router.Error.self) {
            try HTTP.route(Portal.self, Self.request(.delete, "/account/logout"))
        }
    }

    @Test
    func `query fields use the first occurrence, decode values and keep others`() throws {
        #expect(try HTTP.route(Portal.self, Self.request(.get, "/items?page=2&page=5")) == .items(Limit(2)))
        #expect(try HTTP.route(Portal.self, Self.request(.get, "/items?other=x&page=%34")) == .items(Limit(4)))
        #expect(throws: HTTP.Router.Error.self) {
            try HTTP.route(Portal.self, Self.request(.get, "/items?page=many"))
        }
    }
}

@Suite
struct `HTTP.Query.Field.Optional Tests` {

    static func request(_ target: String) -> HTTP.Router.Request {
        HTTP.Router.Request(method: .get, target: .resource(RFC_3986.URI(unchecked: target)))
    }

    @Test
    func `a missing optional field is nil and a present one is parsed`() throws {
        var missing = Self.request("/x?a=1")
        #expect(try HTTP.Query.Field<Limit>.Optional("b").parse(&missing) == nil)
        var present = Self.request("/x?b=7")
        #expect(try HTTP.Query.Field<Limit>.Optional("b").parse(&present) == Limit(7))
        #expect(present.target == Self.request("/x").target)
    }

    @Test
    func `nil writes nothing and a value writes the field`() throws {
        var none = Self.request("/x")
        try HTTP.Query.Field<Limit>.Optional("b").serialize(nil, into: &none)
        #expect(none.target == Self.request("/x").target)
        var some = Self.request("/x")
        try HTTP.Query.Field<Limit>.Optional("b").serialize(Limit(7), into: &some)
        #expect(some.target == Self.request("/x?b=7").target)
    }

    @Test
    func `an unparseable present value is a mismatch`() {
        var bad = Self.request("/x?b=seven")
        #expect(throws: HTTP.Router.Error.mismatch) {
            try HTTP.Query.Field<Limit>.Optional("b").parse(&bad)
        }
    }
}
