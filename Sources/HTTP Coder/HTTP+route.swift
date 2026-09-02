public import HTTP
import Parser
public import RFC_9110

extension HTTP {

    public static func route<Domain: HTTP.Routable>(
        _: Domain.Type,
        _ request: HTTP.Route.Request
    ) throws(HTTP.Route.Error) -> Domain.Call {
        var input = request
        let call = try Domain.route.parse(&input)
        guard input.content == nil else {
            throw .malformed
        }
        return call
    }
}
