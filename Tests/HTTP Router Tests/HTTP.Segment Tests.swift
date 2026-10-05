import Coder
import HTTP
import HTTP_Router
import Interface_Macro
import Operation
import Optic
import RFC_3986
import RFC_9110
import Testing

@Interface
struct Items: Items.Interface {
    protocol Interface {
        func show(_ limit: Limit) async -> Word
        func rename(_ word: Word) async -> Word
    }
}

extension Items: HTTP.Routable {

    static var router: some HTTP.Router.`Protocol`<Call> {
        Coder::Case(Call.cases.show.prism, Call.cases.show.fold, absent: .mismatch) {
            .get
            HTTP.Segment("items")
            HTTP.Segment.Value<Limit>().map(to: { Items.Show.Input($0) }, from: { $0.limit })
        }
        Coder::Case(Call.cases.rename.prism, Call.cases.rename.fold, absent: .mismatch) {
            .post
            HTTP.Segment("items")
            HTTP.Segment("rename")
            HTTP.Segment.Value<Word>().map(to: { Items.Rename.Input($0) }, from: { $0.word })
        }
    }
}

@Suite
struct `HTTP.Segment Tests` {

    static func request(_ method: HTTP.Method, _ target: String) -> HTTP.Router.Request {
        HTTP.Router.Request(method: method, target: .resource(RFC_3986.URI(unchecked: target)))
    }

    @Test
    func `a literal and a parameter segment parse a path`() throws {
        let call = try HTTP.route(Items.self, Self.request(.get, "/items/42"))
        guard case .show(let input) = call else {
            Issue.record("expected show, got \(call)")
            return
        }
        #expect(input.limit == Limit(42))
    }

    @Test
    func `segments serialize back to the same target`() throws {
        let request = try HTTP.request(Items.self, for: .rename(.init(Word("new"))))
        #expect(request.method == .post)
        #expect(request.target == Self.request(.post, "/items/rename/new").target)
        let call = try HTTP.route(Items.self, request)
        guard case .rename(let input) = call else {
            Issue.record("expected rename, got \(call)")
            return
        }
        #expect(input.word == Word("new"))
    }

    @Test
    func `a later case matches after an earlier case consumed a shared prefix`() throws {
        let call = try HTTP.route(Items.self, Self.request(.post, "/items/rename/x"))
        guard case .rename = call else {
            Issue.record("expected rename, got \(call)")
            return
        }
    }

    @Test
    func `an unknown segment is a mismatch`() {
        #expect(throws: HTTP.Router.Error.mismatch) {
            try HTTP.route(Items.self, Self.request(.get, "/things/42"))
        }
    }

    @Test
    func `an unparseable parameter is a mismatch`() {
        #expect(throws: HTTP.Router.Error.mismatch) {
            try HTTP.route(Items.self, Self.request(.get, "/items/forty-two"))
        }
    }

    @Test
    func `leftover segments are malformed`() {
        #expect(throws: HTTP.Router.Error.malformed) {
            try HTTP.route(Items.self, Self.request(.get, "/items/42/extra"))
        }
    }
}

@Interface
struct Pages: Pages.Interface {
    protocol Interface {
        func list(_ limit: Limit) async -> Word
    }
}

extension Pages: HTTP.Routable {

    static var router: some HTTP.Router.`Protocol`<Call> {
        Coder::Case(Call.cases.list.prism, Call.cases.list.fold, absent: .mismatch) {
            .get
            HTTP.Segment("pages")
            HTTP.Query.Field<Limit>("size", default: Limit(10)).map(to: { Pages.List.Input($0) }, from: { $0.limit })
        }
    }
}

@Suite
struct `HTTP.Query.Field Tests` {

    @Test
    func `a query field parses its value`() throws {
        let call = try HTTP.route(Pages.self, `HTTP.Segment Tests`.request(.get, "/pages?size=25"))
        guard case .list(let input) = call else {
            Issue.record("expected list, got \(call)")
            return
        }
        #expect(input.limit == Limit(25))
    }

    @Test
    func `a missing query field takes its default`() throws {
        let call = try HTTP.route(Pages.self, `HTTP.Segment Tests`.request(.get, "/pages"))
        guard case .list(let input) = call else {
            Issue.record("expected list, got \(call)")
            return
        }
        #expect(input.limit == Limit(10))
    }

    @Test
    func `a query field serializes, and its default is omitted`() throws {
        let sized = try HTTP.request(Pages.self, for: .list(.init(Limit(25))))
        #expect(sized.target == `HTTP.Segment Tests`.request(.get, "/pages?size=25").target)
        let plain = try HTTP.request(Pages.self, for: .list(.init(Limit(10))))
        #expect(plain.target == `HTTP.Segment Tests`.request(.get, "/pages").target)
    }

    @Test
    func `an unparseable query value is a mismatch`() {
        #expect(throws: HTTP.Router.Error.mismatch) {
            try HTTP.route(Pages.self, `HTTP.Segment Tests`.request(.get, "/pages?size=big"))
        }
    }
}
