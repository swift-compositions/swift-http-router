import Byte_Primitive
import Coder_Primitive
import HTTP
import HTTP_Coder

struct UnconsumingBody: Coder.`Protocol` {
    typealias Input = [Byte]?
    typealias Output = Void
    typealias Buffer = [Byte]?
    typealias Failure = HTTP.Coding.Body.Error
    typealias Body = Never

    borrowing func parse(_: inout [Byte]?) {}

    borrowing func serialize(_: Void, into buffer: inout [Byte]?) {
        buffer = []
    }
}
