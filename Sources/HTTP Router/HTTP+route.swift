import Byte
public import Coder
public import HTTP
public import Operation
import Parser
import RFC_3986
public import RFC_9110
import Serializer

extension HTTP {

    public static func route<Domain: HTTP.Routable>(
        _: Domain.Type,
        _ request: HTTP.Router.Request
    ) throws(HTTP.Router.Error) -> Domain.Router.Output
    where Domain.Router.Output: ~Copyable {
        try route(Domain.router, request)
    }

    public static func route<Router: Coding>(
        _ router: Router,
        _ request: HTTP.Router.Request
    ) throws(HTTP.Router.Error) -> Router.Output
    where
        Router.Input == HTTP.Router.Request,
        Router.Output: ~Copyable & Escapable,
        Router.Failure == HTTP.Router.Error
    {
        var input = request
        let route = try router.parse(&input)
        guard input.content == nil, input.target.remaining?.path.isEmpty ?? true else {
            throw .malformed
        }
        return route
    }

    public static func route<Index: Operation.Symbol, Body: Coding>(
        @Coder::Builder<HTTP.Router.Request, HTTP.Router.Request> _ body: () -> Body
    ) -> Operation.Application<Index>.Coder<Body>
    where
        Index.Input: ~Copyable & Escapable,
        Body.Input == HTTP.Router.Request,
        Body.Output == Index.Input,
        Body.Output: ~Copyable & Escapable,
        Body.Buffer == HTTP.Router.Request,
        Body.Failure == HTTP.Router.Error
    {
        .init(body())
    }
}
