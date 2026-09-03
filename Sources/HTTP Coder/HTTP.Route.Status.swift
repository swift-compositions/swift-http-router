public import Coder
public import HTTP
public import Parser
public import RFC_9110
public import Serializer

extension HTTP.Route {

    public struct Status<Message: HTTP.Message.Responding>: Coding {

        public typealias Input = Message

        public typealias Output = Void

        public typealias Buffer = Message

        public typealias Failure = HTTP.Route.Error

        public let status: HTTP.Status

        public init(_ status: HTTP.Status) {
            self.status = status
        }

        public borrowing func parse(_ input: inout Message) throws(Failure) {
            guard input.status == status else {
                throw .mismatch
            }
        }

        public borrowing func serialize(_ output: Void, into buffer: inout Message) throws(Failure) {
            buffer.status = status
        }
    }
}
