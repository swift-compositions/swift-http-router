public import Coder
public import HTTP
public import RFC_9110

extension HTTP.Route {

    @resultBuilder
    public struct Builder<Output: ~Copyable> {}
}

extension HTTP.Route.Builder where Output: ~Copyable {

    public static func buildExpression<Route: Coding>(
        _ route: Route
    ) -> Route
    where
        Route.Input == HTTP.Route.Request,
        Route.Output == Output,
        Route.Output: ~Copyable,
        Route.Buffer == HTTP.Route.Request,
        Route.Failure == HTTP.Route.Error
    {
        route
    }

    public static func buildPartialBlock<Route: Coding>(
        first route: Route
    ) -> Route
    where
        Route.Input == HTTP.Route.Request,
        Route.Output == Output,
        Route.Output: ~Copyable,
        Route.Buffer == HTTP.Route.Request,
        Route.Failure == HTTP.Route.Error
    {
        route
    }

    public static func buildPartialBlock<First: Coding, Second: Coding>(
        accumulated first: First,
        next second: Second
    ) -> HTTP.Route.Choice<First, Second>
    where
        First.Input == HTTP.Route.Request,
        First.Output == Output,
        First.Output: ~Copyable,
        First.Buffer == HTTP.Route.Request,
        First.Failure == HTTP.Route.Error,
        Second.Input == HTTP.Route.Request,
        Second.Output == Output,
        Second.Output: ~Copyable,
        Second.Buffer == HTTP.Route.Request,
        Second.Failure == HTTP.Route.Error
    {
        .init(first, second)
    }
}
