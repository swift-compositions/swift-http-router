public import Coder
public import HTTP
public import Operation
public import Optic
public import Optic_Coder
public import Parser
public import RFC_9110
public import Serializer

extension HTTP.Route {

    public struct Case<Call: ~Copyable, Focus: ~Copyable, Content: Coding>: Coding
    where
        Content.Input == HTTP.Route.Request,
        Content.Output == Focus,
        Content.Buffer == HTTP.Route.Request,
        Content.Failure == HTTP.Route.Error
    {
        public typealias Input = HTTP.Route.Request

        public typealias Output = Call

        public typealias Buffer = HTTP.Route.Request

        public typealias Failure = HTTP.Route.Error

        public let underlying: Coder.Case<HTTP.Route.Request, Call, Focus, Content>

        public init(
            _ prism: Optic<Call, Call, Focus, Focus>.Prism,
            _ fold: Optic<Call, Call, Focus, Focus>.Fold,
            content: Content
        ) {
            self.underlying = .init(prism, fold, absent: .mismatch) { content }
        }

        public init(
            _ prism: Optic<Call, Call, Focus, Focus>.Prism,
            _ fold: Optic<Call, Call, Focus, Focus>.Fold,
            @Parser.Builder<HTTP.Route.Request> content: () -> Content
        ) {
            self.init(prism, fold, content: content())
        }

        public borrowing func parse(_ input: inout Input) throws(Failure) -> Call {
            try underlying.parse(&input)
        }

        public borrowing func serialize(_ output: borrowing Call, into buffer: inout Buffer) throws(Failure) {
            try underlying.serialize(output, into: &buffer)
        }
    }
}

extension HTTP.Route.Case where Call: Copyable, Focus: ~Copyable {

    public init(
        _ prism: Optic<Call, Call, Focus, Focus>.Prism,
        @Parser.Builder<HTTP.Route.Request> content: () -> Content
    ) {
        self.init(prism, .init(prism), content: content())
    }
}

extension HTTP.Route.Case where Call: Operation.Coproduct & ~Copyable, Focus: ~Copyable {

    public init(
        _ case: Optic<Call, Call, Focus, Focus>.Case,
        @Parser.Builder<HTTP.Route.Request> content: () -> Content
    ) {
        self.init(`case`.prism, `case`.fold, content: content())
    }

    public init(
        _ keyPath: KeyPath<Call.Cases, Optic<Call, Call, Focus, Focus>.Case>,
        @Parser.Builder<HTTP.Route.Request> content: () -> Content
    ) {
        self.init(Call.cases[keyPath: keyPath], content: content)
    }
}

extension HTTP.Route.Case where Call: ~Copyable, Focus: ~Copyable {

    public init<Index: Operation.Symbol, Inner: Coding>(
        _ prism: Optic<Call, Call, Focus, Focus>.Prism,
        _ fold: Optic<Call, Call, Focus, Focus>.Fold,
        content: Inner
    )
    where
        Focus == Operation.Application<Index>,
        Index.Input: ~Copyable & Escapable,
        Content == Operation.Application<Index>.Coder<Inner>,
        Inner.Input == HTTP.Route.Request,
        Inner.Output == Index.Input,
        Inner.Output: ~Copyable & Escapable,
        Inner.Buffer == HTTP.Route.Request,
        Inner.Failure == HTTP.Route.Error
    {
        self.init(prism, fold, content: .init(content))
    }

    public init<Index: Operation.Symbol, Inner: Coding>(
        _ prism: Optic<Call, Call, Focus, Focus>.Prism,
        _ fold: Optic<Call, Call, Focus, Focus>.Fold,
        @Parser.Builder<HTTP.Route.Request> content: () -> Inner
    )
    where
        Focus == Operation.Application<Index>,
        Index.Input: ~Copyable & Escapable,
        Content == Operation.Application<Index>.Coder<Inner>,
        Inner.Input == HTTP.Route.Request,
        Inner.Output == Index.Input,
        Inner.Output: ~Copyable & Escapable,
        Inner.Buffer == HTTP.Route.Request,
        Inner.Failure == HTTP.Route.Error
    {
        self.init(prism, fold, content: content())
    }
}

extension HTTP.Route.Case where Call: Operation.Coproduct & ~Copyable, Focus: ~Copyable {

    public init<Index: Operation.Symbol, Inner: Coding>(
        _ keyPath: KeyPath<Call.Cases, Optic<Call, Call, Focus, Focus>.Case>,
        content: Inner
    )
    where
        Focus == Operation.Application<Index>,
        Index.Input: ~Copyable & Escapable,
        Content == Operation.Application<Index>.Coder<Inner>,
        Inner.Input == HTTP.Route.Request,
        Inner.Output == Index.Input,
        Inner.Output: ~Copyable & Escapable,
        Inner.Buffer == HTTP.Route.Request,
        Inner.Failure == HTTP.Route.Error
    {
        let `case` = Call.cases[keyPath: keyPath]
        self.init(`case`.prism, `case`.fold, content: content)
    }

    public init<Index: Operation.Symbol, Inner: Coding>(
        _ keyPath: KeyPath<Call.Cases, Optic<Call, Call, Focus, Focus>.Case>,
        @Parser.Builder<HTTP.Route.Request> content: () -> Inner
    )
    where
        Focus == Operation.Application<Index>,
        Index.Input: ~Copyable & Escapable,
        Content == Operation.Application<Index>.Coder<Inner>,
        Inner.Input == HTTP.Route.Request,
        Inner.Output == Index.Input,
        Inner.Output: ~Copyable & Escapable,
        Inner.Buffer == HTTP.Route.Request,
        Inner.Failure == HTTP.Route.Error
    {
        self.init(keyPath, content: content())
    }

    public init<Index: Operation.Member, Inner: Coding>(
        _: Index.Type,
        content: Inner
    )
    where
        Index.Coproduct == Call,
        Index.Case == Optic<Call, Call, Focus, Focus>.Case,
        Focus == Operation.Application<Index>,
        Index.Input: ~Copyable & Escapable,
        Content == Operation.Application<Index>.Coder<Inner>,
        Inner.Input == HTTP.Route.Request,
        Inner.Output == Index.Input,
        Inner.Output: ~Copyable & Escapable,
        Inner.Buffer == HTTP.Route.Request,
        Inner.Failure == HTTP.Route.Error
    {
        self.init(Index.keyPath, content: content)
    }

    public init<Index: Operation.Member, Inner: Coding>(
        _: Index.Type,
        @Parser.Builder<HTTP.Route.Request> content: () -> Inner
    )
    where
        Index.Coproduct == Call,
        Index.Case == Optic<Call, Call, Focus, Focus>.Case,
        Focus == Operation.Application<Index>,
        Index.Input: ~Copyable & Escapable,
        Content == Operation.Application<Index>.Coder<Inner>,
        Inner.Input == HTTP.Route.Request,
        Inner.Output == Index.Input,
        Inner.Output: ~Copyable & Escapable,
        Inner.Buffer == HTTP.Route.Request,
        Inner.Failure == HTTP.Route.Error
    {
        self.init(Index.keyPath, content: content())
    }
}
