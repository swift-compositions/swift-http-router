public import HTTP
public import Parser
import Serializer

extension HTTP {

    public static func request<Domain: HTTP.Routable>(
        _: Domain.Type,
        for route: borrowing Domain.Router.Output
    ) throws(HTTP.Router.Error) -> HTTP.Router.Request
    where Domain.Router.Output: ~Copyable {
        var buffer = HTTP.Router.Request.blank
        try Domain.router.serialize(route, into: &buffer)
        return buffer
    }
}
