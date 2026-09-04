import Byte
import Byte_Coder
import Byte_Standard_Library_Integration
import Coder
import Either
import HTTP
import HTTP_Reply
import HTTP_Router
import Parser
import RFC_9110
import Serializer
import String_Coder
import Tagged
import Tagged_Coder
import Tagged_Standard_Library_Integration

func bytes(_ text: String) -> [Byte] {
    text.utf8.map(Byte.init(bitPattern:))
}

enum Text {}

typealias Word = Tagged<Text, String>

enum Size {}

typealias Limit = Tagged<Size, Int>

enum Refusal: Swift.Error, Equatable, Coder.Codable {

    case refused

    static var coder: Coder.Map<Swift.String.Coder, Refusal> {
        Swift.String.coder.map(to: { _ in Refusal.refused }, from: { _ in "refused" })
    }
}

enum Ineffable: Equatable, Coder.Codable {

    case value

    struct Coder: Byte.Coding<Ineffable, Swift.String.Coder.Error> {

        func parse(_ input: inout ArraySlice<Byte>) throws(Swift.String.Coder.Error) -> Ineffable {
            input = input[input.endIndex...]
            return .value
        }

        func serialize(_ output: Ineffable, into buffer: inout [Byte]) throws(Swift.String.Coder.Error) {
            throw .invalid
        }
    }

    static var coder: Coder { .init() }
}
