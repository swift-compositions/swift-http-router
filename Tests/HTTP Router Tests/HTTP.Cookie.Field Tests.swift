import Byte
import Case_Macro
import Coder
import HTTP
import HTTP_Router
import RFC_3986
import RFC_9110
import Testing

@Prisms
@Folds
@Cases
enum Session: Equatable, Sendable {
    case refresh(String)
}

extension Session: HTTP.Routable {

    static var router: some HTTP.Router.`Protocol`<Session> {
        Coder::Case(Session.cases.refresh.prism, Session.cases.refresh.fold, absent: .mismatch) {
            .post
            HTTP.Segment("refresh")
            HTTP.Segment.End()
            Coder::OneOf.Two(
                HTTP.Body.Coded(UTF8Text()),
                HTTP.Cookie.Field("refresh_token", UTF8Text()),
                absent: HTTP.Router.Error.mismatch
            )
        }
    }
}

@Suite
struct `HTTP.Cookie.Field Tests` {

    static func request(cookie: String?) throws -> HTTP.Router.Request {
        var request = HTTP.Router.Request(method: .post, target: .resource(RFC_3986.URI(unchecked: "/refresh")))
        if let cookie {
            request.headers.append(try RFC_9110.Field(name: "Cookie", value: cookie))
        }
        return request
    }

    @Test
    func `a cookie field matches when the body is absent`() throws {
        #expect(try HTTP.route(Session.self, try Self.request(cookie: "theme=dark; refresh_token=abc")) == .refresh("abc"))
    }

    @Test
    func `the body alternative wins when present`() throws {
        var request = try Self.request(cookie: "refresh_token=abc")
        request.body(set: "xyz", using: UTF8Text())
        #expect(try HTTP.route(Session.self, request) == .refresh("xyz"))
    }

    @Test
    func `a missing cookie is a mismatch`() {
        #expect(throws: HTTP.Router.Error.mismatch) {
            try HTTP.route(Session.self, try Self.request(cookie: "theme=dark"))
        }
    }

    @Test
    func `a cookie field serializes and parses back`() throws {
        var request = HTTP.Router.Request(method: .post, target: .asterisk)
        try HTTP.Cookie.Field("refresh_token", UTF8Text()).serialize("abc", into: &request)
        try HTTP.Cookie.Field("other", UTF8Text()).serialize("x", into: &request)
        #expect(request.headers.map(\.value.rawValue) == ["refresh_token=abc; other=x"])
        #expect(try HTTP.Cookie.Field("other", UTF8Text()).parse(&request) == "x")
    }
}
