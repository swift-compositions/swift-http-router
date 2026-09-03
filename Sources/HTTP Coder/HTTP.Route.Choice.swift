import Coder
public import Either
public import HTTP
public import RFC_9110
public import Parser
import Serializer

extension HTTP.Route {

    public struct Choice<First: HTTP.Route.`Protocol`, Second: HTTP.Route.`Protocol`>: HTTP.Route.`Protocol`
    where
        First.Message == Second.Message,
        First.Output == Second.Output
    {
        public typealias Message = First.Message

        public typealias Input = First.Message

        public typealias Output = First.Output

        public typealias Buffer = First.Message

        public typealias Failure = HTTP.Route.Error

        public typealias Operations = Either<First.Operations, Second.Operations>

        public let first: First

        public let second: Second

        public init(_ first: First, _ second: Second) {
            self.first = first
            self.second = second
        }

        public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
            let mark = input
            do {
                return try first.parse(&input)
            } catch .mismatch {
                input = mark
                return try second.parse(&input)
            }
        }

        public borrowing func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure) {
            let mark = buffer
            do {
                try first.serialize(output, into: &buffer)
            } catch .mismatch {
                buffer = mark
                try second.serialize(output, into: &buffer)
            }
        }
    }
}
