import Case_Macro
import Coder
import HTTP
import HTTP_Router
import RFC_3986
import RFC_6750
import RFC_9110
import Testing

@Prisms
@Folds
@Cases
enum Keys: Equatable, Sendable {
    case rotate(RFC_6750.Bearer)
    case revoke(RFC_6750.Bearer)
    case anonymous
}

extension Keys: HTTP.Routable {

    static var router: some HTTP.Router.`Protocol`<Keys> {
        Coder::Case(Keys.cases.rotate.prism, Keys.cases.rotate.fold, absent: .mismatch) {
            .post
            HTTP.Segment("keys")
            HTTP.Bearer()
            HTTP.Segment("rotate")
            HTTP.Segment.End()
        }
        Coder::Case(Keys.cases.revoke.prism, Keys.cases.revoke.fold, absent: .mismatch) {
            .post
            HTTP.Segment("keys")
            HTTP.Bearer()
            HTTP.Segment("revoke")
            HTTP.Segment.End()
        }
        Coder::Case(Keys.cases.anonymous.prism, Keys.cases.anonymous.fold, absent: .mismatch) {
            .post
            HTTP.Segment("keys")
            HTTP.Segment("revoke")
            HTTP.Segment.End()
        }
    }
}

@Suite
struct `HTTP.Bearer Tests` {

    static func request(_ target: String, authorization: String?) -> HTTP.Router.Request {
        var request = HTTP.Router.Request(method: .post, target: .resource(RFC_3986.URI(unchecked: target)))
        if let authorization {
            request.headers.append(RFC_9110.Field(name: .authorization, value: .init(unchecked: authorization)))
        }
        return request
    }

    @Test
    func `a bearer header matches and round-trips`() throws {
        let bearer = try RFC_6750.Bearer(token: "abc.def")
        let request = try HTTP.request(Keys.self, for: .rotate(bearer))
        #expect(request.headers[.authorization].map(\.rawValue) == ["Bearer abc.def"])
        #expect(try HTTP.route(Keys.self, request) == .rotate(bearer))
    }

    @Test
    func `a failed branch restores the authorization header for the next branch`() throws {
        let call = try HTTP.route(Keys.self, Self.request("/keys/revoke", authorization: "Bearer abc"))
        #expect(call == .revoke(try RFC_6750.Bearer(token: "abc")))
    }

    @Test
    func `a missing or non-bearer header is a mismatch`() throws {
        #expect(try HTTP.route(Keys.self, Self.request("/keys/revoke", authorization: nil)) == .anonymous)
        #expect(try HTTP.route(Keys.self, Self.request("/keys/revoke", authorization: "Basic abc")) == .anonymous)
        #expect(throws: HTTP.Router.Error.self) {
            try HTTP.route(Keys.self, Self.request("/keys/rotate", authorization: "Basic abc"))
        }
    }
}
