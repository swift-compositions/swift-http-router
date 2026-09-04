public import HTTP
public import Parser
public import RFC_9110

extension HTTP {

    public static func route<Domain: HTTP.Routable>(
        _: Domain.Type,
        _ request: HTTP.Route.Request
    ) throws(HTTP.Route.Error) -> Domain.Router.Output
    where Domain.Router.Output: ~Copyable {
        var input = request
        let route = try Domain.router.parse(&input)
        guard input.content == nil else {
            throw .malformed
        }
        return route
    }
}
