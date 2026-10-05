public import Coder
public import HTTP
public import Parser
public import Serializer

extension HTTP {

    public struct Content<Message: HTTP.Message.`Protocol`, Value: Coding>
    where
        Value.Output: ~Copyable,
        Message.Content: RangeReplaceableCollection,
        Value.Input == Message.Content.SubSequence,
        Value.Buffer == Message.Content
    {
        public let value: Value

        public init(_ value: Value) {
            self.value = value
        }
    }
}

extension HTTP.Content: Parsing
where Value.Output: ~Copyable {
    public var body: Never {
        borrowing get {
            return fatalError("\(Self.self) is a leaf: implement its conformance requirements directly")
        }
    }

    public typealias Input = Message

    public typealias Output = Value.Output

    public typealias Failure = HTTP.Router.Error

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
}

extension HTTP.Content: Serializing
where Value.Output: ~Copyable {

    public typealias Buffer = Message

    public borrowing func serialize(_ output: borrowing Output, into buffer: inout Message) throws(Failure) {
        var content = Message.Content()
        do throws(Value.Failure) {
            try value.serialize(output, into: &content)
        } catch {
            throw .unprintable
        }
        buffer.content = content
    }
}

extension HTTP.Content: Coding
where Value.Output: ~Copyable {}
