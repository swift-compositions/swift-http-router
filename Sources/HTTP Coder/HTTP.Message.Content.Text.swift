public import Byte
public import Byte_Parser
public import Coder
public import HTTP
import Parser
public import RFC_9110
import Serializer

extension HTTP.Message.Content {

    public struct Text: Coding {

        public typealias Input = Byte.Input

        public typealias Output = Swift.String

        public typealias Buffer = [Byte]

        public typealias Failure = HTTP.Message.Content.Error

        public init() {}

        public borrowing func parse(_ input: inout Byte.Input) throws(Failure) -> Swift.String {
            var raw: [UInt8] = []
            raw.reserveCapacity(input.count)
            while let byte = input.next() {
                raw.append(byte.bitPattern)
            }
            guard let text = Swift.String(validating: raw, as: Swift.UTF8.self) else {
                throw .invalid
            }
            return text
        }

        public borrowing func serialize(_ output: Swift.String, into buffer: inout [Byte]) throws(Failure) {
            buffer.append(contentsOf: output.utf8.lazy.map(Byte.init(bitPattern:)))
        }
    }
}
