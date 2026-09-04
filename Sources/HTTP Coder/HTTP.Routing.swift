public import Coder
public import HTTP
public import Parser
public import RFC_9110
public import Serializer

extension HTTP {

    public typealias Routing<Route> = Coding<
        HTTP.Route.Request,
        Route,
        HTTP.Route.Request,
        HTTP.Route.Error
    > where Route: ~Copyable
}
