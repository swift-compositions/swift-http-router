public import Coder_Primitive
public import HTTP
public import Parser_Primitive
public import Serializer_Primitive

extension HTTP {
    public struct Representation<Content, Value: Coder.`Protocol`>
    where Value.Input == Content?, Value.Buffer == Content? {
        public let status: HTTP.Status
        public let value: Value

        public init(_ status: HTTP.Status, _ value: Value) {
            self.status = status
            self.value = value
        }
    }
}

extension HTTP.Representation: Coder.`Protocol` {
    public typealias Input = HTTP.Message.Response<Content>?
    public typealias Output = Value.Output
    public typealias Buffer = HTTP.Message.Response<Content>?
    public typealias Failure = HTTP.Message.Error
    public typealias Body = Never

    public borrowing func parse(
        _ input: inout HTTP.Message.Response<Content>?
    ) throws(HTTP.Message.Error) -> Value.Output {
        guard let response = input, response.status == status else {
            throw .mismatch
        }

        var content = response.content
        let output: Value.Output
        do throws(Value.Failure) {
            output = try value.parse(&content)
        } catch {
            throw .malformed
        }
        guard case nil = content else {
            throw .malformed
        }
        input = nil
        return output
    }

    public borrowing func serialize(
        _ output: Value.Output,
        into buffer: inout HTTP.Message.Response<Content>?
    ) throws(HTTP.Message.Error) {
        guard case nil = buffer else {
            throw .unprintable
        }
        var content: Content?
        do throws(Value.Failure) {
            try value.serialize(output, into: &content)
        } catch {
            throw .unprintable
        }

        buffer = .init(
            status: status,
            content: content
        )
    }
}
