public import Byte_Primitive
public import Coder_Primitive
public import HTTP
public import Parser_Primitive
public import Serializer_Primitive

extension HTTP.Response.Coder {

    /// One status of the response family: a status match against a content
    /// focus on the payload.
    ///
    /// A status that does not match is `noMatch`, so an alternation over
    /// branches still reaches its siblings; a matching status whose payload the
    /// content coder refuses — or leaves unconsumed — is `malformed`.
    public struct Branch<Content: Coder_Primitive.Coder.`Protocol`>
    where Content.Input == [Byte]?, Content.Buffer == [Byte]? {

        public let status: HTTP.Status

        public let content: Content

        public init(status: HTTP.Status, content: Content) {
            self.status = status
            self.content = content
        }
    }
}

extension HTTP.Response.Coder.Branch: Coder_Primitive.Coder.`Protocol` {

    public typealias Input = HTTP.Response?
    public typealias Output = Content.Output
    public typealias Buffer = HTTP.Response?
    public typealias Failure = HTTP.Response.Coder.Error
    public typealias Body = Never

    public borrowing func parse(
        _ input: inout HTTP.Response?
    ) throws(HTTP.Response.Coder.Error) -> Content.Output {
        guard let response = input, response.status == status else {
            throw .noMatch
        }

        var body = response.body
        let output: Content.Output
        do throws(Content.Failure) {
            output = try content.parse(&body)
        } catch {
            throw .malformed
        }
        guard case nil = body else {
            throw .malformed
        }
        input = nil
        return output
    }

    public borrowing func serialize(
        _ output: Content.Output,
        into buffer: inout HTTP.Response?
    ) throws(HTTP.Response.Coder.Error) {
        var body: [Byte]?
        do throws(Content.Failure) {
            try content.serialize(output, into: &body)
        } catch {
            throw .unprintable
        }
        buffer = .init(status: status, body: body)
    }
}
