public import Coder
public import HTTP
public import Parser
public import Serializer

extension HTTP.Reply {

    public struct Empty {

        public init() {}
    }
}

extension HTTP.Reply.Empty: Parser.`Protocol` {

    public typealias Input = HTTP.Router.Response

    public typealias Output = Void

    public typealias Failure = HTTP.Router.Error

    public borrowing func parse(_ input: inout HTTP.Router.Response) throws(HTTP.Router.Error) {
        guard input.content == nil else {
            throw .malformed
        }
    }
}

extension HTTP.Reply.Empty: Serializer.`Protocol` {

    public typealias Buffer = HTTP.Router.Response

    public borrowing func serialize(_ output: Void, into buffer: inout HTTP.Router.Response) throws(HTTP.Router.Error) {
        buffer.content = nil
    }
}

extension HTTP.Reply.Empty: Coder.`Protocol` {}
