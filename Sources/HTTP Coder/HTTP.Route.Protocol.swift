public import Call_Algebra
public import Coder
public import HTTP
public import RFC_9110
public import Parser
public import Serializer

extension HTTP.Route {

    public protocol `Protocol`<Message, Output, Coverage>: Coding
    where
        Input == Message,
        Buffer == Message,
        Failure == HTTP.Route.Error
    {
        associatedtype Message: HTTP.Message.`Protocol`

        associatedtype Output

        associatedtype Coverage
    }
}

extension HTTP {

    public typealias Routing<Call: Call_Algebra.Call.`Protocol`> = HTTP.Route.`Protocol`<
        HTTP.Route.Request,
        Call,
        Call.Coverage
    >

    public typealias Replying<Output> = Coding<
        HTTP.Route.Response,
        Output,
        HTTP.Route.Response,
        HTTP.Route.Error
    >
}
