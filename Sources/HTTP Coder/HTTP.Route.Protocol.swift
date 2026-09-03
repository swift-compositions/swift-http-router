public import Coder
public import HTTP
public import RFC_9110
public import Parser
public import Serializer

extension HTTP.Route {

    public protocol `Protocol`<Message, Output>: Coding
    where
        Input == Message,
        Buffer == Message,
        Failure == HTTP.Route.Error
    {
        associatedtype Message: HTTP.Message.`Protocol`

        associatedtype Output
    }
}

extension HTTP {

    public typealias Routing<Call> = HTTP.Route.`Protocol`<
        HTTP.Route.Request,
        Call
    >

    public typealias Replying<Output> = Coding<
        HTTP.Route.Response,
        Output,
        HTTP.Route.Response,
        HTTP.Route.Error
    >
}
