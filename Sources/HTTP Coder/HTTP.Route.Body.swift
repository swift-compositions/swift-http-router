public import Byte_Primitive
public import Coder_Primitive
public import HTTP
public import Parser_Primitive
public import Serializer_Primitive

extension HTTP.Route {

    /// Lifts a value coder over the request payload into a route leaf, so a
    /// body is part of its branch rather than attached afterward.
    public struct Body<Content: Coder.`Protocol`>
    where Content.Input == [Byte]?, Content.Buffer == [Byte]? {

        public let content: Content

        public init(_ content: Content) {
            self.content = content
        }
    }
}

extension HTTP.Route.Body: Coder.`Protocol` {

    public typealias Input = HTTP.Route.Input
    public typealias Output = Content.Output
    public typealias Buffer = HTTP.Route.Input
    public typealias Failure = HTTP.Route.Error
    public typealias Body = Never

    public borrowing func parse(
        _ input: inout HTTP.Route.Input
    ) throws(HTTP.Route.Error) -> Content.Output {
        var body = input.body
        let output: Content.Output
        do throws(Content.Failure) {
            output = try content.parse(&body)
        } catch {
            throw .malformed
        }
        guard case nil = body else {
            throw .malformed
        }
        input.body = nil
        return output
    }

    public borrowing func serialize(
        _ output: Content.Output,
        into buffer: inout HTTP.Route.Input
    ) throws(HTTP.Route.Error) {
        var body: [Byte]?
        do throws(Content.Failure) {
            try content.serialize(output, into: &body)
        } catch {
            throw .unprintable
        }
        buffer.body = body
    }
}
