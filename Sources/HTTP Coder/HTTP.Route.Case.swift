public import Coder
public import HTTP
public import Operation
public import Optic
public import Optic_Coder
public import Parser
public import RFC_9110
public import Serializer

extension HTTP.Route {

    public struct Case<Call, Focus, Content: Coding, Operations>: HTTP.Route.`Protocol`
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
        ) where Focus: Operation.Coproduct, Operations == Focus.Operations {
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

extension HTTP.Route.Case {

    public init<Index: Operation.Symbol, Inner: Coding>(
        _ prism: Optic<Call, Call, Operation.Application<Index>, Operation.Application<Index>>.Prism,
        @Parser.Builder<HTTP.Route.Request> content: () -> Inner
    )
    where
        Focus == Operation.Application<Index>,
        Content == Coder.Map<Inner, Operation.Application<Index>>,
        Operations == Index,
        Index.Input: Copyable & Escapable,
        Inner.Input == HTTP.Route.Request,
        Inner.Output == Index.Input,
        Inner.Buffer == HTTP.Route.Request,
        Inner.Failure == HTTP.Route.Error
    {
        self.init(
            operations: Index.self,
            prism,
            content: content().map(
                to: { input in Operation.Application<Index>(input) },
                from: { application in application.input }
            )
        )
    }
}
