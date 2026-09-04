public import HTTP
public import Parser

extension HTTP {

    public static func target<Domain: HTTP.Routable>(
        _: Domain.Type,
        for route: borrowing Domain.Router.Output
    ) throws(HTTP.Router.Error) -> HTTP.Target
    where Domain.Router.Output: ~Copyable {
        try HTTP.request(Domain.self, for: route).target
    }
}
