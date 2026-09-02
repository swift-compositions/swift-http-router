public import Call_Algebra
public import Coder
public import HTTP
public import RFC_9110
public import Parser
public import Serializer

extension HTTP {

    public protocol Respondable {

        associatedtype Call: Call_Algebra.Call.Singleton

        associatedtype Response: Coding
        where
            Response.Input == HTTP.Route.Response,
            Response.Output == Swift.Result<Call.Operation.Output, Call.Operation.Failure>,
            Response.Buffer == HTTP.Route.Response,
            Response.Failure == HTTP.Route.Error

        @HTTP.Route.Builder<Swift.Result<Call.Operation.Output, Call.Operation.Failure>>
        static var response: Response { get }
    }
}
