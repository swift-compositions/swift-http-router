public import Coder
public import HTTP
public import Operation
public import Parser
public import RFC_9110
public import Serializer

extension HTTP {

    public static func route<Domain: HTTP.Routable>(
        _: Domain.Type,
        _ request: HTTP.Router.Request
    ) throws(HTTP.Router.Error) -> Domain.Router.Output
    where Domain.Router.Output: ~Copyable {
        var input = request
        let route = try Domain.router.parse(&input)
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
