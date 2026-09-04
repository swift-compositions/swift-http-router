public import Coder
public import HTTP
public import Parser
public import RFC_9110
public import Serializer

extension HTTP.Target: @retroactive Parser.`Protocol`, @retroactive Serializer.`Protocol`, @retroactive Coder.`Protocol` {

    public typealias Input = HTTP.Router.Request

    public typealias Output = Void

    public typealias Buffer = HTTP.Router.Request

    public typealias Failure = HTTP.Router.Error

    public borrowing func parse(_ input: inout Input) throws(Failure) {
        guard input.target == self else {
            throw .mismatch
        }
    }

    public func serialize(_ output: Void, into buffer: inout Buffer) throws(Failure) {
        buffer.target = self
    }
}
