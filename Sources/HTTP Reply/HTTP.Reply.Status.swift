public import Coder
public import HTTP
public import HTTP_Router
public import Parser
public import RFC_9110
public import Serializer

extension HTTP.Reply {

    public struct Status<Body: Coding>
    where
        Body.Input == HTTP.Router.Response,
        Body.Buffer == HTTP.Router.Response,
        Body.Failure == HTTP.Router.Error
    {
        public let status: HTTP.Status

        public let body: Body

        public init(_ status: HTTP.Status, _ body: Body) {
            self.status = status
            self.body = body
        }
    }
}

extension HTTP.Reply.Status: Parser.`Protocol` {

    public typealias Input = HTTP.Router.Response

    public typealias Output = Body.Output

    public typealias Failure = HTTP.Router.Error

    public borrowing func parse(_ input: inout HTTP.Router.Response) throws(HTTP.Router.Error) -> Body.Output {
        guard input.status == status else {
            throw .mismatch
        }
        return try body.parse(&input)
    }
}

extension HTTP.Reply.Status: Serializer.`Protocol` {

    public typealias Buffer = HTTP.Router.Response

    public borrowing func serialize(
        _ output: borrowing Body.Output,
        into buffer: inout HTTP.Router.Response
    ) throws(HTTP.Router.Error) {
        buffer.status = status
        try body.serialize(output, into: &buffer)
    }
}

extension HTTP.Reply.Status: Coder.`Protocol` {}
