public import Coder
public import HTTP
public import Parser
public import RFC_9110
public import Serializer

extension HTTP.Method: @retroactive Parsing, @retroactive Serializing, @retroactive Coding {
    public var body: Never {
        borrowing get {
            return fatalError("\(Self.self) is a leaf: implement its conformance requirements directly")
        }
    }

    public typealias Input = HTTP.Router.Request

    public typealias Output = Void

    public typealias Buffer = HTTP.Router.Request

    public typealias Failure = HTTP.Router.Error

    public borrowing func parse(_ input: inout Input) throws(Failure) {
        guard input.method == self else {
            throw .mismatch
        }
    }

    public func serialize(_ output: Void, into buffer: inout Buffer) throws(Failure) {
        buffer.method = self
    }
}
