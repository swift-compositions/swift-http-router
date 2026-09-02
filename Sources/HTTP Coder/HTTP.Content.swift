public import Byte
public import Byte_Parser
public import Coder
public import HTTP
public import Parser
public import RFC_9110
public import Serializer

extension HTTP {

    public struct Content<Message: HTTP.Message.`Protocol`, Value: Coding>: Coding
    where
        Message.Content == [Byte],
        Value.Input == Byte.Input,
        Value.Buffer == [Byte]
    {
        public typealias Input = Message

        public typealias Output = Value.Output

        public typealias Buffer = Message

        public typealias Failure = HTTP.Route.Error

        public let value: Value

        public init(_ value: Value) {
            self.value = value
        }

        public borrowing func parse(_ input: inout Message) throws(Failure) -> Output {
            guard let bytes = input.content else {
                throw .malformed
            }
            var cursor = Byte.Input(bytes)
            let output: Output
            do throws(Value.Failure) {
                output = try value.parse(&cursor)
            } catch {
                throw .malformed
            }
            guard cursor.isEmpty else {
                throw .malformed
            }
            input.content = nil
            return output
        }

        public borrowing func serialize(_ output: Output, into buffer: inout Message) throws(Failure) {
            var bytes: [Byte] = []
            do throws(Value.Failure) {
                try value.serialize(output, into: &bytes)
            } catch {
                throw .unprintable
            }
            buffer.content = bytes
        }
    }
}
