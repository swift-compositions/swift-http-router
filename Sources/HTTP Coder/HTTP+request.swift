public import HTTP
public import RFC_9110
import Serializer

extension HTTP {

    public static func request<Domain: HTTP.Routable>(
        _: Domain.Type,
        for call: borrowing Domain.Call
    ) throws(HTTP.Route.Error) -> HTTP.Route.Request
    where
        Domain.Call: ~Copyable,
        Domain.Call.Operations: ~Copyable & ~Escapable
    {
        var buffer = HTTP.Route.Request.blank
        try Domain.route.serialize(call, into: &buffer)
        return buffer
    }
}
