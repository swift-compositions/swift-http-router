public import Coder
public import HTTP
import Parser
import RFC_3986
public import RFC_9110
import Serializer

extension HTTP.Target: @retroactive Parsing, @retroactive Serializing, @retroactive Coding {

    public typealias Input = HTTP.Router.Request

    public typealias Output = Void

    public typealias Buffer = HTTP.Router.Request

    public typealias Failure = HTTP.Router.Error

    public borrowing func parse(_ input: inout Input) throws(Failure) {
        guard input.target == self else {
            throw .mismatch
        }
        input.target = .resource(RFC_3986.URI(unchecked: ""))
    }

    public func serialize(_ output: Void, into buffer: inout Buffer) throws(Failure) {
        buffer.target = self
    }
}
