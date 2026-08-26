public import Coder_Primitive
public import HTTP
public import Parser_Primitive
public import Serializer_Primitive

extension HTTP.Route {

    /// Matches, and consumes, the request method.
    public struct Method: Sendable {

        public let method: HTTP.Method

        public init(_ method: HTTP.Method) {
            self.method = method
        }
    }
}

extension HTTP.Route.Method: Coder.`Protocol` {

    public typealias Input = HTTP.Route.Input
    public typealias Output = Void
    public typealias Buffer = HTTP.Route.Input
    public typealias Failure = HTTP.Route.Error
    public typealias Body = Never

    public borrowing func parse(
        _ input: inout HTTP.Route.Input
    ) throws(HTTP.Route.Error) {
        guard input.method == method else {
            throw .noMatch
        }
        input.method = nil
    }

    public borrowing func serialize(
        _ output: Void,
        into buffer: inout HTTP.Route.Input
    ) {
        buffer.method = method
    }
}
