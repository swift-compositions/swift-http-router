public import HTTP
public import RFC_9110

extension HTTP.Route {

    @resultBuilder
    public struct Builder<Output> {}
}

extension HTTP.Route.Builder {

    public static func buildExpression<Route: HTTP.Route.`Protocol`>(
        _ route: Route
    ) -> Route
    where
        Route.Output == Output,
        Route.Operations: ~Copyable & ~Escapable
    {
        route
    }

    public static func buildPartialBlock<Route: HTTP.Route.`Protocol`>(
        first route: Route
    ) -> Route
    where
        Route.Output == Output,
        Route.Operations: ~Copyable & ~Escapable
    {
        route
    }

    public static func buildPartialBlock<First: HTTP.Route.`Protocol`, Second: HTTP.Route.`Protocol`>(
        accumulated first: First,
        next second: Second
    ) -> HTTP.Route.Choice<First, Second>
    where
        First.Message == Second.Message,
        First.Output == Output,
        Second.Output == Output,
        First.Operations: ~Copyable & ~Escapable,
        Second.Operations: ~Copyable & ~Escapable
    {
        .init(first, second)
    }
}
