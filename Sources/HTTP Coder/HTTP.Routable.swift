public import Call_Algebra
public import HTTP
public import RFC_9110

extension HTTP {

    public protocol Routable {

        associatedtype Call: Call_Algebra.Call.`Protocol`

        associatedtype Route: HTTP.Route.`Protocol`
        where
            Route.Message == HTTP.Route.Request,
            Route.Output == Call,
            Route.Coverage == Call.Coverage

        @HTTP.Route.Builder<Call>
        static var route: Route { get }
    }
}
