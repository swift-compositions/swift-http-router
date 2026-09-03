public import HTTP
public import Operation
public import RFC_9110

extension HTTP {

    public protocol Routable {

        associatedtype Call: Operation.Coproduct & ~Copyable

        associatedtype Route: HTTP.Route.`Protocol`
        where
            Route.Message == HTTP.Route.Request,
            Route.Output == Call,
            Route.Output: ~Copyable,
            Route.Operations == Call.Operations,
            Route.Operations: ~Copyable & ~Escapable,
            Call.Operations: ~Copyable & ~Escapable

        @HTTP.Route.Builder<Call>
        static var route: Route { get }
    }
}
