public import Checkpoint_Coder
public import Coder
public import Either
public import HTTP

extension HTTP.Reply {

    @resultBuilder
    public struct Builder {}
}

extension HTTP.Reply.Builder {

    public static func buildExpression<Entry: Coding>(
        _ entry: Entry
    ) -> Entry
    where
        Entry.Input == HTTP.Router.Response,
        Entry.Buffer == HTTP.Router.Response,
        Entry.Failure == HTTP.Router.Error
    {
        entry
    }

    public static func buildPartialBlock<Entry: Coding>(
        first entry: Entry
    ) -> Entry
    where
        Entry.Input == HTTP.Router.Response,
        Entry.Buffer == HTTP.Router.Response,
        Entry.Failure == HTTP.Router.Error
    {
        entry
    }

    public static func buildPartialBlock<Success: Coding, Refusal: Coding, Value, Reason>(
        accumulated success: Success,
        next refusal: Refusal
    ) -> HTTP.Reply.Pair<Success, Refusal, Value, Reason>
    where
        Success.Input == HTTP.Router.Response,
        Success.Output == Either<Never, Value>,
        Success.Buffer == HTTP.Router.Response,
        Success.Failure == HTTP.Router.Error,
        Refusal.Input == HTTP.Router.Response,
        Refusal.Output == Either<Reason, Never>,
        Refusal.Buffer == HTTP.Router.Response,
        Refusal.Failure == HTTP.Router.Error
    {
        .init(success, refusal)
    }

    public static func buildPartialBlock<Refusal: Coding, Success: Coding, Reason, Value>(
        accumulated refusal: Refusal,
        next success: Success
    ) -> HTTP.Reply.Pair<Success, Refusal, Value, Reason>
    where
        Refusal.Input == HTTP.Router.Response,
        Refusal.Output == Either<Reason, Never>,
        Refusal.Buffer == HTTP.Router.Response,
        Refusal.Failure == HTTP.Router.Error,
        Success.Input == HTTP.Router.Response,
        Success.Output == Either<Never, Value>,
        Success.Buffer == HTTP.Router.Response,
        Success.Failure == HTTP.Router.Error
    {
        .init(success, refusal)
    }

    public static func buildPartialBlock<First: Coding, Second: Coding>(
        accumulated first: First,
        next second: Second
    ) -> Coder.OneOf.Two<First, Second>
    where
        First.Input == HTTP.Router.Response,
        First.Buffer == HTTP.Router.Response,
        First.Failure == HTTP.Router.Error,
        Second.Input == HTTP.Router.Response,
        Second.Output == First.Output,
        Second.Buffer == HTTP.Router.Response,
        Second.Failure == HTTP.Router.Error
    {
        .init(first, second, absent: .mismatch)
    }
}
