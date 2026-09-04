public import Coder
public import HTTP
public import Parser
public import RFC_9110
public import Serializer

extension HTTP {

    public protocol Routable {

        associatedtype Router: Coding
        where
            Router.Input == HTTP.Route.Request,
            Router.Output: ~Copyable,
            Router.Buffer == HTTP.Route.Request,
            Router.Failure == HTTP.Route.Error

        @HTTP.Route.Builder<Router.Output>
        static var router: Router { get }
    }
}
