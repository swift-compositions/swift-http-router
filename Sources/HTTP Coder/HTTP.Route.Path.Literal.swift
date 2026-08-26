public import Coder_Primitive
public import HTTP
public import Parser_Primitive
public import Serializer_Primitive

extension HTTP.Route.Path {

    /// Matches, and consumes, one literal path segment.
    public struct Literal: Sendable, ExpressibleByStringLiteral {

        public let segment: String

        public init(_ segment: String) {
            self.segment = segment
        }

        public init(stringLiteral value: String) {
            self.init(value)
        }
    }
}

extension HTTP.Route.Path.Literal: Coder.`Protocol` {

    public typealias Input = HTTP.Route.Input
    public typealias Output = Void
    public typealias Buffer = HTTP.Route.Input
    public typealias Failure = HTTP.Route.Error
    public typealias Body = Never

    public borrowing func parse(
        _ input: inout HTTP.Route.Input
    ) throws(HTTP.Route.Error) {
        guard input.path.first == segment else {
            throw .noMatch
        }
        input.path.removeFirst()
    }

    public borrowing func serialize(
        _ output: Void,
        into buffer: inout HTTP.Route.Input
    ) {
        buffer.path.append(segment)
    }
}
