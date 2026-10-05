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
enum Deep: Equatable, Sendable {
    case member(Member)
}

extension Deep: HTTP.Routable {

    static var router: some HTTP.Router.`Protocol`<Deep> {
        Coder::Case(Deep.cases.member.prism, Deep.cases.member.fold, absent: .mismatch) {
            HTTP.Segment("api")
            HTTP.Segment("member")
            Member.router
        }
    }
}

@Suite
struct `HTTP.Segment.Double Tests` {

    @Test
    func `two prefix segments before a child router round-trip`() throws {
        let request = try HTTP.request(Deep.self, for: .member(.show(Limit(3))))
        #expect(request.target == HTTP.Router.Request(method: .get, target: .resource(RFC_3986.URI(unchecked: "/api/member/3"))).target)
        #expect(try HTTP.route(Deep.self, request) == .member(.show(Limit(3))))
    }
}
