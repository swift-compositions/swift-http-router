public import Checkpoint_Coder
public import Coder
public import HTTP

extension HTTP.Router {

    @resultBuilder
    public struct Builder<Output: ~Copyable> {}
}

extension HTTP.Router.Builder where Output: ~Copyable {

    public static func buildExpression<Route: Coding>(
        _ route: Route
    ) -> Route
    where
        Route.Input == HTTP.Router.Request,
        Route.Output == Output,
        Route.Output: ~Copyable,
        Route.Buffer == HTTP.Router.Request,
        Route.Failure == HTTP.Router.Error
    {
        route
    }

    public static func buildPartialBlock<Route: Coding>(
        first route: Route
    ) -> Route
    where
        Route.Input == HTTP.Router.Request,
        Route.Output == Output,
        Route.Output: ~Copyable,
        Route.Buffer == HTTP.Router.Request,
        Route.Failure == HTTP.Router.Error
    {
        route
    }

    public static func buildPartialBlock<First: Coding, Second: Coding>(
        accumulated first: First,
        next second: Second
    ) -> Coder.OneOf.Two<First, Second>
    where
        First.Input == HTTP.Router.Request,
        First.Output == Output,
        First.Output: ~Copyable,
        First.Buffer == HTTP.Router.Request,
        First.Failure == HTTP.Router.Error,
        Second.Input == HTTP.Router.Request,
        Second.Output == Output,
        Second.Output: ~Copyable,
        Second.Buffer == HTTP.Router.Request,
        Second.Failure == HTTP.Router.Error
    {
        .init(first, second, absent: .mismatch)
    }
}
