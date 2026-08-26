public import Byte_Primitive
public import Coder_Primitive
public import HTTP
public import Parser_Primitive
public import Serializer_Primitive

extension HTTP.Coding {

    public struct Request<Content: Coder.`Protocol`>
    where Content.Input == [Byte]?, Content.Buffer == [Byte]? {

        public let method: HTTP.Method
        public let target: HTTP.Request.Target
        public let content: Content

        public init(
            method: HTTP.Method,
            target: HTTP.Request.Target,
            content: Content
        ) {
            self.method = method
            self.target = target
            self.content = content
        }
    }
}

extension HTTP.Coding.Request: Coder.`Protocol` {

    public typealias Input = HTTP.Request?
    public typealias Output = Content.Output
    public typealias Buffer = HTTP.Request?
    public typealias Failure = HTTP.Coding.Error
    public typealias Body = Never

    public borrowing func parse(
        _ input: inout HTTP.Request?
    ) throws(HTTP.Coding.Error) -> Content.Output {
        guard let request = input,
              request.method == method,
              request.target == target
        else {
            throw .request
        }

        var body = request.body
        let output: Content.Output
        do throws(Content.Failure) {
            output = try content.parse(&body)
        } catch {
            throw .request
        }
        guard case nil = body else {
            throw .request
        }
        input = nil
        return output
    }

    public borrowing func serialize(
        _ output: Content.Output,
        into buffer: inout HTTP.Request?
    ) throws(HTTP.Coding.Error) {
        var body: [Byte]?
        do throws(Content.Failure) {
            try content.serialize(output, into: &body)
        } catch {
            throw .request
        }
        buffer = .init(method: method, target: target, body: body)
    }
}
