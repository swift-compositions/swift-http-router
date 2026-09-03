public import Coder
public import HTTP
public import Parser
public import RFC_9110
public import Serializer

extension HTTP.Route {

    public struct Method<Message: HTTP.Message.Requesting>: Coding {

        public typealias Input = Message

        public typealias Output = Void

        public typealias Buffer = Message

        public typealias Failure = HTTP.Route.Error

        public let method: HTTP.Method

        public init(_ method: HTTP.Method) {
            self.method = method
        }

        public borrowing func parse(_ input: inout Message) throws(Failure) {
            guard input.method == method else {
                throw .mismatch
            }
        }

        public borrowing func serialize(_ output: Void, into buffer: inout Message) throws(Failure) {
            buffer.method = method
        }
    }
}
