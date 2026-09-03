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
        Call,
        Focus,
        Content: Coding,
        Operations: ~Copyable & ~Escapable
    >: HTTP.Route.`Protocol`
    where
        Content.Input == HTTP.Route.Request,
        Content.Output == Focus,
        Content.Buffer == HTTP.Route.Request,
        Content.Failure == HTTP.Route.Error
    {
        public typealias Message = HTTP.Route.Request

        public typealias Input = HTTP.Route.Request

        public typealias Output = Call

        public typealias Buffer = HTTP.Route.Request

        public typealias Failure = HTTP.Route.Error

        public let underlying: Coder.Case<HTTP.Route.Request, Call, Focus, Content>

        public init(
            _ prism: Optic<Call, Call, Focus, Focus>.Prism,
            @Parser.Builder<HTTP.Route.Request> content: () -> Content
        ) where Operations == Focus {
            self.underlying = .init(prism, absent: .mismatch, content: content)
        }

        private init(
            operations _: Operations.Type,
            _ prism: Optic<Call, Call, Focus, Focus>.Prism,
            content: Content
        ) {
            self.underlying = .init(prism, absent: .mismatch) { content }
        }

        public borrowing func parse(_ input: inout Input) throws(Failure) -> Call {
            try underlying.parse(&input)
        }

        public borrowing func serialize(_ output: Call, into buffer: inout Buffer) throws(Failure) {
            try underlying.serialize(output, into: &buffer)
        }
    }
}

extension HTTP.Route.Case
where Operations: ~Copyable & ~Escapable {

    public init<Inner: Coding>(
        _ prism: Optic<Call, Call, Operation.Application<Operations>, Operation.Application<Operations>>.Prism,
        @Parser.Builder<HTTP.Route.Request> content: () -> Inner
    )
    where
        Operations: Operation.Symbol,
        Focus == Operation.Application<Operations>,
        Content == Coder.Map<Inner, Operation.Application<Operations>>,
        Operations.Input: Copyable & Escapable,
        Inner.Input == HTTP.Route.Request,
        Inner.Output == Operations.Input,
        Inner.Buffer == HTTP.Route.Request,
        Inner.Failure == HTTP.Route.Error
    {
        self.init(
            operations: Operations.self,
            prism,
            content: content().map(
                to: { input in Operation.Application<Operations>(input) },
                from: { application in application.input }
            )
        )
    }
}
