public import Coder
public import Either
public import HTTP

extension HTTP {

    public static func reply<Failure: Swift.Error, Output, Body: Coding>(
        @HTTP.Reply.Builder<Failure, Output> _ body: () -> Body
    ) -> Body
    where
        Body.Input == HTTP.Router.Response,
        Body.Output == Either<Failure, Output>,
        Body.Buffer == HTTP.Router.Response,
        Body.Failure == HTTP.Router.Error
    {
        body()
    }
}
