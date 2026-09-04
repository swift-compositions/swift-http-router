public import Coder
public import HTTP
public import Parser
public import RFC_9110
public import Serializer

extension HTTP.Route {

    public struct Choice<First: Coding, Second: Coding>: Coding
    where
        First.Input == HTTP.Route.Request,
        First.Output: ~Copyable,
        First.Buffer == HTTP.Route.Request,
        First.Failure == HTTP.Route.Error,
        Second.Input == HTTP.Route.Request,
        Second.Output == First.Output,
        Second.Output: ~Copyable,
        Second.Buffer == HTTP.Route.Request,
        Second.Failure == HTTP.Route.Error
    {
        public typealias Input = HTTP.Route.Request

        public typealias Output = First.Output

        public typealias Buffer = HTTP.Route.Request

        public typealias Failure = HTTP.Route.Error

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

        public borrowing func serialize(_ output: borrowing Output, into buffer: inout Buffer) throws(Failure) {
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
