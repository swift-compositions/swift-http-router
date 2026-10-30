public import Coder
public import HTTP
import Parser
import Serializer

extension HTTP.Router {

    public typealias `Protocol`<Route> = Coding
        & Parsing<HTTP.Router.Request, Route, HTTP.Router.Error>
        & Serializing<Route, HTTP.Router.Request, HTTP.Router.Error>
    where Route: ~Copyable
}
