public import HTTP
public import Parser
public import RFC_9110
import Serializer

extension HTTP {

    public static func request<Domain: HTTP.Routable>(
        _: Domain.Type,
        for route: borrowing Domain.Router.Output
    ) throws(HTTP.Route.Error) -> HTTP.Route.Request
    where Domain.Router.Output: ~Copyable {
        var buffer = HTTP.Route.Request.blank
        try Domain.router.serialize(route, into: &buffer)
        return buffer
    }
}
