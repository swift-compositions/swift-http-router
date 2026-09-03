public import Coder
public import Either
public import HTTP
public import Operation
public import RFC_9110
public import Parser
public import Serializer

extension HTTP.Route {

    public protocol `Protocol`<Message, Output, Operations>: Coding
    where
        Input == Message,
        Buffer == Message,
        Failure == HTTP.Route.Error
    {
        associatedtype Message: HTTP.Message.`Protocol`

        associatedtype Output

        associatedtype Operations
    }
}

extension HTTP {

    public typealias Routing<Call: Operation.Coproduct> = HTTP.Route.`Protocol`<
        HTTP.Route.Request,
        Call,
        Call.Operations
    >

    public typealias Replying<Output> = Coding<
        HTTP.Route.Response,
        Output,
        HTTP.Route.Response,
        HTTP.Route.Error
    >
}
