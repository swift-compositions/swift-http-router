public import Byte_Primitive
public import Coder_Primitive
public import HTTP

extension HTTP.Coding.Body {

    public struct Text<Value> {
        private let decode: (String) throws(HTTP.Coding.Body.Error) -> Value
        private let encode: (Value) -> String

        public init(
            decode: @escaping (String) throws(HTTP.Coding.Body.Error) -> Value,
            encode: @escaping (Value) -> String
        ) {
            self.decode = decode
            self.encode = encode
        }
    }
}

extension HTTP.Coding.Body.Text: Coder.`Protocol` {

    public typealias Input = [Byte]?
    public typealias Output = Value
    public typealias Buffer = [Byte]?
    public typealias Failure = HTTP.Coding.Body.Error
    public typealias Body = Never

    public borrowing func parse(
        _ input: inout [Byte]?
    ) throws(HTTP.Coding.Body.Error) -> Value {
        guard let bytes = input else {
            throw .missing
        }
        guard let text = String(
            validating: bytes.lazy.map(\.underlying),
            as: UTF8.self
        ) else {
            throw .invalid
        }
        let output = try decode(text)
        input = nil
        return output
    }

    public borrowing func serialize(
        _ output: Value,
        into buffer: inout [Byte]?
    ) {
        buffer = encode(output).utf8.map(Byte.init)
    }
}
