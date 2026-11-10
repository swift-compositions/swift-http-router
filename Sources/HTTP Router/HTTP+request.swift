public import Coder
public import HTTP
public import Parser
import Serializer

extension HTTP {

    public static func request<Domain: HTTP.Routable>(
        _: Domain.Type,
        for route: borrowing Domain.Router.Output
    ) throws(HTTP.Router.Error) -> HTTP.Router.Request
    where Domain.Router.Output: ~Copyable {
        try request(Domain.router, for: route)
    }

    public static func request<Router: Coding>(
        _ router: Router,
        for route: borrowing Router.Output
    ) throws(HTTP.Router.Error) -> HTTP.Router.Request
    where
        Router.Buffer == HTTP.Router.Request,
        Router.Output: ~Copyable & Escapable,
        Router.Failure == HTTP.Router.Error
    {
        var buffer = HTTP.Router.Request.blank
        try router.serialize(route, into: &buffer)
        return buffer
    }
}
