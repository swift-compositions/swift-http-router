public import Byte_Primitive
public import Coder_Primitive
public import HTTP
public import Parser_Primitive
public import Serializer_Primitive

extension HTTP.Message.Content {
    public struct Text: Coder.`Protocol` {
        public typealias Input = [Byte]?
        public typealias Output = String
        public typealias Buffer = [Byte]?
        public typealias Failure = HTTP.Message.Content.Error
        public typealias Body = Never

        public init() {}

        public borrowing func parse(
            _ input: inout [Byte]?
        ) throws(HTTP.Message.Content.Error) -> String {
            guard let bytes = input else {
                throw .missing
            }
            guard let text = String(
                validating: bytes.lazy.map(\.underlying),
                as: UTF8.self
            ) else {
                throw .invalid
            }
            input = nil
            return text
        }

        public borrowing func serialize(
            _ output: String,
            into buffer: inout [Byte]?
        ) {
            buffer = output.utf8.map(Byte.init)
        }
    }
}
