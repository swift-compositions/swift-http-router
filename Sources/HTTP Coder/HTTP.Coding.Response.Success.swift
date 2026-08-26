public import Byte_Primitive
public import Coder_Primitive
public import Either_Primitives
public import HTTP
public import Parser_Primitive
public import Serializer_Primitive

extension HTTP.Coding.Response {

    public struct Success<Content: Coder.`Protocol`>
    where Content.Input == [Byte]?, Content.Buffer == [Byte]? {

        public let status: HTTP.Status
        public let content: Content

        public init(status: HTTP.Status, content: Content) {
            self.status = status
            self.content = content
        }
    }
}

extension HTTP.Coding.Response.Success: Coder.`Protocol` {

    public typealias Input = HTTP.Response?
    public typealias Output = Either<Swift.Never, Content.Output>
    public typealias Buffer = HTTP.Response?
    public typealias Failure = HTTP.Coding.Error
    public typealias Body = Never

    public borrowing func parse(
        _ input: inout HTTP.Response?
    ) throws(HTTP.Coding.Error) -> Output {
        guard let response = input, response.status == status else {
            throw .response
        }

        var body = response.body
        let output: Content.Output
        do throws(Content.Failure) {
            output = try content.parse(&body)
        } catch {
            throw .response
        }
        guard case nil = body else {
            throw .response
        }
        input = nil
        return .right(output)
    }

    public borrowing func serialize(
        _ output: Output,
        into buffer: inout HTTP.Response?
    ) throws(HTTP.Coding.Error) {
        var body: [Byte]?
        do throws(Content.Failure) {
            try content.serialize(output.value, into: &body)
        } catch {
            throw .response
        }
        buffer = .init(status: status, body: body)
    }
}
