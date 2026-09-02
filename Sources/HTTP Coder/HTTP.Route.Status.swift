public import Coder
public import HTTP
import Parser
public import RFC_9110
import Serializer

extension HTTP.Route {

    public struct Status: Coding {

        public typealias Input = HTTP.Route.Response

        public typealias Output = Void

        public typealias Buffer = HTTP.Route.Response

        public typealias Failure = HTTP.Route.Error

        public let status: HTTP.Status

        public init(_ status: HTTP.Status) {
            self.status = status
        }

        public borrowing func parse(_ input: inout Input) throws(Failure) {
            guard input.status == status else {
                throw .mismatch
            }
        }

        public borrowing func serialize(_ output: Void, into buffer: inout Buffer) throws(Failure) {
            buffer.status = status
        }
    }
}
