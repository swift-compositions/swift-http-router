public import Coder
public import HTTP
import Parser
import Serializer

extension HTTP.Router {

    public typealias `Protocol`<Route> = Coding<
        HTTP.Router.Request,
        Route,
        HTTP.Router.Request,
        HTTP.Router.Error
    > where Route: ~Copyable
}
