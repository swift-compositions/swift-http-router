public import Coder
public import HTTP
public import Parser
public import RFC_9110
public import Serializer

extension HTTP.Target: @retroactive Parser.`Protocol`, @retroactive Serializer.`Protocol`, @retroactive Coder.`Protocol` {

    public typealias Input = HTTP.Route.Request

    public typealias Output = Void

    public typealias Buffer = HTTP.Route.Request

    public typealias Failure = HTTP.Route.Error

    public borrowing func parse(_ input: inout Input) throws(Failure) {
        guard input.target == self else {
            throw .mismatch
        }
    }

    public func serialize(_ output: Void, into buffer: inout Buffer) throws(Failure) {
        buffer.target = self
    }
}
