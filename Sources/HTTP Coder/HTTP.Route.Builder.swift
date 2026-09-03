public import HTTP
public import RFC_9110

extension HTTP.Route {

    @resultBuilder
    public struct Builder<Output: ~Copyable> {}
}

extension HTTP.Route.Builder where Output: ~Copyable {

    public static func buildExpression<Route: HTTP.Route.`Protocol`>(
        _ route: Route
    ) -> Route
    where
        Route.Output == Output,
        Route.Output: ~Copyable,
        Route.Operations: ~Copyable & ~Escapable
    {
        route
    }

    public static func buildPartialBlock<Route: HTTP.Route.`Protocol`>(
        first route: Route
    ) -> Route
    where
        Route.Output == Output,
        Route.Output: ~Copyable,
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
        First.Output: ~Copyable,
        Second.Output: ~Copyable,
        First.Operations: ~Copyable & ~Escapable,
        Second.Operations: ~Copyable & ~Escapable
    {
        .init(first, second)
    }
}
