public import Coder
public import HTTP
public import Parser
public import RFC_9110
public import Serializer

extension HTTP {

    public struct Content<Message: HTTP.Message.`Protocol`, Value: Coding>: Coding
    where
        Message.Content: RangeReplaceableCollection,
        Value.Input == Message.Content.SubSequence,
        Value.Buffer == Message.Content
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
            guard let content = input.content else {
                throw .malformed
            }
            var cursor = content[...]
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
            var content = Message.Content()
            do throws(Value.Failure) {
                try value.serialize(output, into: &content)
            } catch {
                throw .unprintable
            }
            buffer.content = content
        }
    }
}
