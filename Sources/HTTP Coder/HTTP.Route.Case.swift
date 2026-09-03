public import Coder
public import HTTP
public import Operation
public import Optic
public import Optic_Coder
public import Parser
public import RFC_9110
public import Serializer

extension HTTP.Route {

    public struct Case<
        Call: ~Copyable,
        Focus: ~Copyable,
        Content: Coding,
        Operations: ~Copyable & ~Escapable
    >: HTTP.Route.`Protocol`
    where
        Content.Input: HTTP.Message.Requesting,
        Content.Output == Focus,
        Content.Buffer == Content.Input,
        Content.Failure == HTTP.Route.Error
    {
        public typealias Message = Content.Input

        public typealias Input = Content.Input

        public typealias Output = Call

        public typealias Buffer = Content.Input

        public typealias Failure = HTTP.Route.Error

        public let underlying: Coder.Case<Content.Input, Call, Focus, Content>

        public init(
            _ prism: Optic<Call, Call, Focus, Focus>.Prism,
            _ fold: Optic<Call, Call, Focus, Focus>.Fold,
            content: Content
        ) where Operations == Focus {
            self.underlying = .init(prism, fold, absent: .mismatch) { content }
        }

        public init(
            _ prism: Optic<Call, Call, Focus, Focus>.Prism,
            _ fold: Optic<Call, Call, Focus, Focus>.Fold,
            @Parser.Builder<HTTP.Route.Request> content: () -> Content
        ) where Operations == Focus, Content.Input == HTTP.Route.Request {
            self.init(prism, fold, content: content())
        }

        public init(
            _ prism: Optic<Call, Call, Focus, Focus>.Prism,
            @Parser.Builder<HTTP.Route.Request> content: () -> Content
        ) where Operations == Focus, Content.Input == HTTP.Route.Request, Call: Copyable {
            self.init(prism, .init(prism), content: content())
        }

        private init(
            operations _: Operations.Type,
            _ prism: Optic<Call, Call, Focus, Focus>.Prism,
            _ fold: Optic<Call, Call, Focus, Focus>.Fold,
            content: Content
        ) {
            self.underlying = .init(prism, fold, absent: .mismatch) { content }
        }

        public borrowing func parse(_ input: inout Input) throws(Failure) -> Call {
            try underlying.parse(&input)
        }

        public borrowing func serialize(_ output: borrowing Call, into buffer: inout Buffer) throws(Failure) {
            try underlying.serialize(output, into: &buffer)
        }
    }
}

extension HTTP.Route.Case
where
    Call: ~Copyable,
    Focus: ~Copyable,
    Operations: Operation.Symbol,
    Operations.Input: ~Copyable & Escapable,
    Focus == Operation.Application<Operations>
{

    public init<Inner: Coder.`Protocol`>(
        _ prism: Optic<Call, Call, Operation.Application<Operations>, Operation.Application<Operations>>.Prism,
        _ fold: Optic<Call, Call, Operation.Application<Operations>, Operation.Application<Operations>>.Fold,
        content: Inner
    )
    where
        Content == HTTP.Route.Application<Operations, Inner>,
        Inner.Output: ~Copyable & Escapable,
        Inner.Input: HTTP.Message.Requesting,
        Inner.Output == Operations.Input,
        Inner.Buffer == Inner.Input,
        Inner.Failure == HTTP.Route.Error
    {
        self.init(operations: Operations.self, prism, fold, content: .init(content))
    }

    public init<Inner: Coder.`Protocol`>(
        _ prism: Optic<Call, Call, Operation.Application<Operations>, Operation.Application<Operations>>.Prism,
        _ fold: Optic<Call, Call, Operation.Application<Operations>, Operation.Application<Operations>>.Fold,
        @Parser.Builder<HTTP.Route.Request> content: () -> Inner
    )
    where
        Content == HTTP.Route.Application<Operations, Inner>,
        Inner.Output: ~Copyable & Escapable,
        Inner.Input == HTTP.Route.Request,
        Inner.Output == Operations.Input,
        Inner.Buffer == HTTP.Route.Request,
        Inner.Failure == HTTP.Route.Error
    {
        self.init(prism, fold, content: content())
    }

    public init<Inner: Coder.`Protocol`>(
        _ prism: Optic<Call, Call, Operation.Application<Operations>, Operation.Application<Operations>>.Prism,
        @Parser.Builder<HTTP.Route.Request> content: () -> Inner
    )
    where
        Call: Copyable,
        Content == HTTP.Route.Application<Operations, Inner>,
        Inner.Output: ~Copyable & Escapable,
        Inner.Input == HTTP.Route.Request,
        Inner.Output == Operations.Input,
        Inner.Buffer == HTTP.Route.Request,
        Inner.Failure == HTTP.Route.Error
    {
        self.init(prism, .init(prism), content: content)
    }
}
