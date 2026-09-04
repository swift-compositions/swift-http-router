public import Checkpoint_Coder
public import Coder
public import Either
public import HTTP

extension HTTP.Reply {

    @resultBuilder
    public struct Builder<Failure: Swift.Error, Output> {}
}

extension HTTP.Reply.Builder {

    public static func buildExpression<Body: Coding>(
        _ entry: HTTP.Reply.Success<Failure, Body>
    ) -> HTTP.Reply.Success<Failure, Body>
    where Body.Output == Output {
        entry
    }

    public static func buildExpression<Body: Coding>(
        _ entry: HTTP.Reply.Refusal<Output, Body>
    ) -> HTTP.Reply.Refusal<Output, Body>
    where Body.Output == Failure {
        entry
    }

    public static func buildPartialBlock<Entry: Coding>(
        first entry: Entry
    ) -> Entry
    where
        Entry.Input == HTTP.Router.Response,
        Entry.Output == Either<Failure, Output>,
        Entry.Buffer == HTTP.Router.Response,
        Entry.Failure == HTTP.Router.Error
    {
        entry
    }

    public static func buildPartialBlock<First: Coding, Second: Coding>(
        accumulated first: First,
        next second: Second
    ) -> Coder.OneOf.Two<First, Second>
    where
        First.Input == HTTP.Router.Response,
        First.Output == Either<Failure, Output>,
        First.Buffer == HTTP.Router.Response,
        First.Failure == HTTP.Router.Error,
        Second.Input == HTTP.Router.Response,
        Second.Output == Either<Failure, Output>,
        Second.Buffer == HTTP.Router.Response,
        Second.Failure == HTTP.Router.Error
    {
        .init(first, second, absent: .mismatch)
    }
}
