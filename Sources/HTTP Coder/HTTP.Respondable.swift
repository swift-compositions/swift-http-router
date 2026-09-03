public import Coder
public import HTTP
public import Operation
public import RFC_9110
public import Parser
public import Serializer

extension HTTP {

    public protocol Respondable: Operation.Symbol
    where
        Output: Copyable & Escapable,
        Failure: Swift.Error
    {

        associatedtype Response: Coding
        where
            Response.Input == HTTP.Route.Response,
            Response.Output == Swift.Result<Output, Failure>,
            Response.Buffer == HTTP.Route.Response,
            Response.Failure == HTTP.Route.Error

        @HTTP.Route.Builder<Swift.Result<Output, Failure>>
        static var response: Response { get }
    }
}
