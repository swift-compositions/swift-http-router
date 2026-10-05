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
enum Tokens: Equatable, Sendable {
    case access(String)
    case refreshAll(String)
    case refresh(String)
}

#if Foundation
    extension Tokens: HTTP.Routable {

        static var router: some HTTP.Router.`Protocol`<Tokens> {
            Coder::Case(Tokens.cases.access.prism, Tokens.cases.access.fold, absent: .mismatch) {
                HTTP.Method.post
                HTTP.Segment("access")
                HTTP.Segment.End()
                HTTP.Cookie.Field("access_token", HTTP.Body.JSON<String>())
            }
            Coder::Case(Tokens.cases.refreshAll.prism, Tokens.cases.refreshAll.fold, absent: .mismatch) {
                HTTP.Method.post
                HTTP.Segment("refresh")
                HTTP.Body.Coded(HTTP.Body.JSON<String>())
                HTTP.Segment("all")
                HTTP.Segment.End()
            }
            Coder::Case(Tokens.cases.refresh.prism, Tokens.cases.refresh.fold, absent: .mismatch) {
                HTTP.Method.post
                HTTP.Segment("refresh")
                HTTP.Segment.End()
                Coder::OneOf.Two(
                    HTTP.Body.Coded(HTTP.Body.JSON<String>()),
                    HTTP.Cookie.Field("refresh_token", HTTP.Body.JSON<String>()),
                    absent: HTTP.Router.Error.mismatch
                )
            }
        }
    }

    @Suite
    struct `HTTP.Cookie JSON Tests` {

        static let jwt = "eyJhbGciOiJub25lIn0.eyJzdWIiOiJwYXJpdHkifQ.AQID"

        static func request(_ path: String, body: String? = nil, cookie: String? = nil) throws -> HTTP.Router.Request {
            var request = HTTP.Router.Request(method: .post, target: .resource(RFC_3986.URI(unchecked: path)))
            if let cookie {
                request.headers.append(try RFC_9110.Field(name: "Cookie", value: cookie))
            }
            if let body {
                request.headers.append(RFC_9110.Field(name: .contentType, value: .init(unchecked: "application/json")))
                request.content = bytes(body)
            }
            return request
        }

        @Test
        func `the JSON-quoted JWT cookie matches the recorded wire form`() throws {
            let request = try HTTP.request(Tokens.self, for: .access(Self.jwt))
            #expect(request.headers.map(\.value.rawValue) == ["access_token=\"\(Self.jwt)\""])
            #expect(request.content == nil)
            let recorded = try Self.request("/access", cookie: "access_token=\"\(Self.jwt)\"")
            #expect(try HTTP.route(Tokens.self, recorded) == .access(Self.jwt))
        }

        @Test
        func `a present body takes precedence over the cookie`() throws {
            let request = try Self.request("/refresh", body: "\"from-body\"", cookie: "refresh_token=\"from-cookie\"")
            #expect(try HTTP.route(Tokens.self, request) == .refresh("from-body"))
        }

        @Test
        func `the cookie is used when no body is present`() throws {
            let request = try Self.request("/refresh", cookie: "refresh_token=\"from-cookie\"")
            #expect(try HTTP.route(Tokens.self, request) == .refresh("from-cookie"))
        }

        @Test
        func `a malformed present body is rejected, never replaced by the cookie`() throws {
            let request = try Self.request("/refresh", body: "{not json", cookie: "refresh_token=\"from-cookie\"")
            #expect(throws: HTTP.Router.Error.malformed) {
                try HTTP.route(Tokens.self, request)
            }
        }

        @Test
        func `a malformed present cookie is rejected`() throws {
            let request = try Self.request("/refresh", cookie: "refresh_token=unquoted")
            #expect(throws: HTTP.Router.Error.malformed) {
                try HTTP.route(Tokens.self, request)
            }
        }

        @Test
        func `a branch that consumed the body restores it for the next branch`() throws {
            let request = try Self.request("/refresh", body: "\"from-body\"")
            #expect(try HTTP.route(Tokens.self, request) == .refresh("from-body"))
            let all = try Self.request("/refresh/all", body: "\"everything\"")
            #expect(try HTTP.route(Tokens.self, all) == .refreshAll("everything"))
        }
    }
#endif
