public import Byte_Primitive
public import Coder_Primitive
public import Either_Primitives
public import HTTP
public import Parser_Primitive
public import Serializer_Primitive

extension HTTP.Coding.Response {

    public struct Choice<Refusal: Coder.`Protocol`, Success: Coder.`Protocol`>
    where
        Refusal.Input == [Byte]?,
        Refusal.Buffer == [Byte]?,
        Success.Input == [Byte]?,
        Success.Buffer == [Byte]?
    {
        public let refusalStatus: HTTP.Status
        public let refusal: Refusal
        public let successStatus: HTTP.Status
        public let success: Success

        public init(
            refusalStatus: HTTP.Status,
            refusal: Refusal,
            successStatus: HTTP.Status,
            success: Success
        ) {
            precondition(
                refusalStatus != successStatus,
                "response choice statuses must be distinct"
            )
            self.refusalStatus = refusalStatus
            self.refusal = refusal
            self.successStatus = successStatus
            self.success = success
        }
    }
}

extension HTTP.Coding.Response.Choice: Coder.`Protocol` {

    public typealias Input = HTTP.Response?
    public typealias Output = Either<Refusal.Output, Success.Output>
    public typealias Buffer = HTTP.Response?
    public typealias Failure = HTTP.Coding.Error
    public typealias Body = Never

    public borrowing func parse(
        _ input: inout HTTP.Response?
    ) throws(HTTP.Coding.Error) -> Output {
        guard let response = input else {
            throw .response
        }

        var body = response.body
        let output: Output
        switch response.status {
        case refusalStatus:
            do throws(Refusal.Failure) {
                output = .left(try refusal.parse(&body))
            } catch {
                throw .response
            }
        case successStatus:
            do throws(Success.Failure) {
                output = .right(try success.parse(&body))
            } catch {
                throw .response
            }
        default:
            throw .response
        }
        guard case nil = body else {
            throw .response
        }
        input = nil
        return output
    }

    public borrowing func serialize(
        _ output: Output,
        into buffer: inout HTTP.Response?
    ) throws(HTTP.Coding.Error) {
        switch output {
        case .left(let failure):
            var body: [Byte]?
            do throws(Refusal.Failure) {
                try refusal.serialize(failure, into: &body)
            } catch {
                throw .response
            }
            buffer = .init(status: refusalStatus, body: body)

        case .right(let value):
            var body: [Byte]?
            do throws(Success.Failure) {
                try success.serialize(value, into: &body)
            } catch {
                throw .response
            }
            buffer = .init(status: successStatus, body: body)
        }
    }
}
