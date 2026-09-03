public import HTTP
public import RFC_9110

extension HTTP {

    public protocol Routable {

        associatedtype Call

        associatedtype Route: HTTP.Route.`Protocol`
        where
            Route.Message == HTTP.Route.Request,
            Route.Output == Call

        @HTTP.Route.Builder<Call>
        static var route: Route { get }
    }
}
