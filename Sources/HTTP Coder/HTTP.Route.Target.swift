public import Coder
public import HTTP
import Parser
public import RFC_9110
import Serializer

extension HTTP.Route {

    public struct Target: Coding {

        public typealias Input = HTTP.Route.Request

        public typealias Output = Void

        public typealias Buffer = HTTP.Route.Request

        public typealias Failure = HTTP.Route.Error

        public let target: HTTP.Target

        public init(_ target: HTTP.Target) {
            self.target = target
        }

        public borrowing func parse(_ input: inout Input) throws(Failure) {
            guard input.target == target else {
                throw .mismatch
            }
        }

        public borrowing func serialize(_ output: Void, into buffer: inout Buffer) throws(Failure) {
            buffer.target = target
        }
    }
}
