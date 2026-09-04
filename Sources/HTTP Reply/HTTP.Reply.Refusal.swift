public import Coder
public import Either
public import HTTP
public import HTTP_Router
public import Parser
public import Serializer

extension HTTP.Reply {

    public struct Refusal<Body: Coding>
    where
        Body.Input == HTTP.Router.Response,
        Body.Output: Swift.Error,
        Body.Buffer == HTTP.Router.Response,
        Body.Failure == HTTP.Router.Error
    {
        public let body: Body

        public init(_ body: Body) {
            self.body = body
        }
    }
}

extension HTTP.Reply.Refusal: Parser.`Protocol` {

    public typealias Input = HTTP.Router.Response

    public typealias Output = Either<Body.Output, Never>

    public typealias Failure = HTTP.Router.Error

    public borrowing func parse(
        _ input: inout HTTP.Router.Response
    ) throws(HTTP.Router.Error) -> Either<Body.Output, Never> {
        .left(try body.parse(&input))
    }
}

extension HTTP.Reply.Refusal: Serializer.`Protocol` {

    public typealias Buffer = HTTP.Router.Response

    public borrowing func serialize(
        _ output: borrowing Either<Body.Output, Never>,
        into buffer: inout HTTP.Router.Response
    ) throws(HTTP.Router.Error) {
        let reply = copy output
        switch reply {
        case .left(let refusal):
            try body.serialize(refusal, into: &buffer)
        case .right(let never):
            switch never {}
        }
    }
}

extension HTTP.Reply.Refusal: Coder.`Protocol` {}
