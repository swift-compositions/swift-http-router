import Byte
import Coder
import Either
import HTTP
import HTTP_Reply
import HTTP_Router
import Parser
import RFC_9110
import Serializer
public import Tagged

func bytes(_ text: String) -> [Byte] {
    text.utf8.map(Byte.init(bitPattern:))
}

enum Text {}

typealias Word = Tagged<Text, String>

enum Size {}

typealias Limit = Tagged<Size, Int>

extension Tagged: @retroactive LosslessStringConvertible where Underlying: LosslessStringConvertible {
    public init?(_ description: String) {
        guard let underlying = Underlying(description) else { return nil }
        self.init(underlying)
    }
}

enum Refusal: Swift.Error, Equatable {

    case refused

    struct Coder: Coding {
        var body: some Coding<ArraySlice<Byte>, Refusal, [Byte], Swift.String.Coder.Error> {
            return Swift.String.Coder().map(
                to: { _ in Refusal.refused }, from: { _ in "refused" }
            )
        }
    }
}

enum Ineffable: Equatable {

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

}
