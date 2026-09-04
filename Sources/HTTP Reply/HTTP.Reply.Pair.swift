import Checkpoint
public import Coder
public import Either
public import HTTP
public import HTTP_Router
public import Parser
public import Serializer

extension HTTP.Reply {

    public struct Pair<Success: Coding, Refusal: Coding, Value, Reason>
    where
        Success.Input == HTTP.Router.Response,
        Success.Output == Either<Never, Value>,
        Success.Buffer == HTTP.Router.Response,
        Success.Failure == HTTP.Router.Error,
        Refusal.Input == HTTP.Router.Response,
        Refusal.Output == Either<Reason, Never>,
        Refusal.Buffer == HTTP.Router.Response,
        Refusal.Failure == HTTP.Router.Error
    {
        public let success: Success

        public let refusal: Refusal

        public init(_ success: Success, _ refusal: Refusal) {
            self.success = success
            self.refusal = refusal
        }
    }
}

extension HTTP.Reply.Pair: Parser.`Protocol` {

    public typealias Input = HTTP.Router.Response

    public typealias Output = Either<Reason, Value>

    public typealias Failure = HTTP.Router.Error

    public borrowing func parse(
        _ input: inout HTTP.Router.Response
    ) throws(HTTP.Router.Error) -> Either<Reason, Value> {
        let checkpoint = input.checkpoint
        do throws(HTTP.Router.Error) {
            return .right(value(of: try success.parse(&input)))
        } catch {
            guard error == .mismatch else {
                throw error
            }
            input.seek(to: checkpoint)
            return .left(value(of: try refusal.parse(&input)))
        }
    }
}

extension HTTP.Reply.Pair: Serializer.`Protocol` {

    public typealias Buffer = HTTP.Router.Response

    public borrowing func serialize(
        _ output: borrowing Either<Reason, Value>,
        into buffer: inout HTTP.Router.Response
    ) throws(HTTP.Router.Error) {
        let reply = copy output
        switch reply {
        case .left(let reason):
            try refusal.serialize(.left(reason), into: &buffer)
        case .right(let value):
            try success.serialize(.right(value), into: &buffer)
        }
    }
}

extension HTTP.Reply.Pair: Coder.`Protocol` {}
