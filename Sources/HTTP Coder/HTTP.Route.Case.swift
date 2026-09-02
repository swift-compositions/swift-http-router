public import Call_Algebra
public import Coder
public import HTTP
public import RFC_9110
import Optic
public import Optic_Coder
public import Parser
public import Serializer

extension HTTP.Route {

    public struct Case<Call: Call_Algebra.Call.`Protocol`, Identifier, Content: Coding>: HTTP.Route.`Protocol`
    where
        Content.Input == HTTP.Route.Request,
        Content.Buffer == HTTP.Route.Request,
        Content.Failure == HTTP.Route.Error
    {
        public typealias Message = HTTP.Route.Request

        public typealias Input = HTTP.Route.Request

        public typealias Output = Call

        public typealias Buffer = HTTP.Route.Request

        public typealias Failure = HTTP.Route.Error

        public typealias Coverage = Identifier

        public let underlying: Coder.Case<HTTP.Route.Request, Call, Content.Output, Content>

        public init(
            _ branch: KeyPath<Call.Branches, Call_Algebra.Call.Branch<Call, Content.Output, Identifier>>,
            @Parser.Builder<HTTP.Route.Request> content: () -> Content
        ) {
            self.underlying = .init(
                Call.branches[keyPath: branch].prism,
                absent: .mismatch,
                content: content
            )
        }

        public borrowing func parse(_ input: inout Input) throws(Failure) -> Call {
            try underlying.parse(&input)
        }

        public borrowing func serialize(_ output: Call, into buffer: inout Buffer) throws(Failure) {
            try underlying.serialize(output, into: &buffer)
        }
    }
}
