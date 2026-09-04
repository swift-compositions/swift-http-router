public import Coder
public import Either
public import HTTP
public import Parser
public import Serializer

extension HTTP.Reply {

    public struct Success<Refusal: Swift.Error, Body: Coding>
    where
        Body.Input == HTTP.Router.Response,
        Body.Buffer == HTTP.Router.Response,
        Body.Failure == HTTP.Router.Error
    {
        public let body: Body

        public init(_ body: Body) {
            self.body = body
        }
    }
}

extension HTTP.Reply.Success: Parser.`Protocol` {

    public typealias Input = HTTP.Router.Response

    public typealias Output = Either<Refusal, Body.Output>

    public typealias Failure = HTTP.Router.Error

    public borrowing func parse(
        _ input: inout HTTP.Router.Response
    ) throws(HTTP.Router.Error) -> Either<Refusal, Body.Output> {
        .right(try body.parse(&input))
    }
}

extension HTTP.Reply.Success: Serializer.`Protocol` {

    public typealias Buffer = HTTP.Router.Response

    public borrowing func serialize(
        _ output: borrowing Either<Refusal, Body.Output>,
        into buffer: inout HTTP.Router.Response
    ) throws(HTTP.Router.Error) {
        let reply = copy output
        switch reply {
        case .left:
            throw .mismatch
        case .right(let value):
            try body.serialize(value, into: &buffer)
        }
    }
}

extension HTTP.Reply.Success: Coder.`Protocol` {}
