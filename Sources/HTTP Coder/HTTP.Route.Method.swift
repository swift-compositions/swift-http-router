public import Coder
public import HTTP
import Parser
public import RFC_9110
import Serializer

extension HTTP.Route {

    public struct Method: Coding {

        public typealias Input = HTTP.Route.Request

        public typealias Output = Void

        public typealias Buffer = HTTP.Route.Request

        public typealias Failure = HTTP.Route.Error

        public let method: HTTP.Method

        public init(_ method: HTTP.Method) {
            self.method = method
        }

        public borrowing func parse(_ input: inout Input) throws(Failure) {
            guard input.method == method else {
                throw .mismatch
            }
        }

        public borrowing func serialize(_ output: Void, into buffer: inout Buffer) throws(Failure) {
            buffer.method = method
        }
    }
}
