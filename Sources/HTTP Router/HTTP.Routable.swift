public import Coder
public import HTTP
public import Parser
public import Serializer

extension HTTP {

    public protocol Routable {

        associatedtype Router: Coding
        where
            Router.Input == HTTP.Router.Request,
            Router.Output: ~Copyable,
            Router.Buffer == HTTP.Router.Request,
            Router.Failure == HTTP.Router.Error

        @HTTP.Router.Builder<Router.Output>
        static var router: Router { get }
    }
}
