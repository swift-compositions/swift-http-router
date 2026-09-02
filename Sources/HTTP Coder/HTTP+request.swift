public import HTTP
public import RFC_9110
import Serializer

extension HTTP {

    public static func request<Domain: HTTP.Routable>(
        _: Domain.Type,
        for call: Domain.Call
    ) throws(HTTP.Route.Error) -> HTTP.Route.Request {
        var buffer = HTTP.Route.Request.blank
        try Domain.route.serialize(call, into: &buffer)
        return buffer
    }
}
