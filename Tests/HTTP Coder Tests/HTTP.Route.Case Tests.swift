import Coder_Primitive
import HTTP
import HTTP_Coder
import Optic_Primitives
import Parser_Conversion_Primitives
import Parser_Primitive
import Parser_Skip_Primitives
import Serializer_Primitive
import Testing

private enum Call: Equatable {
    case bump(Int)
    case poke
}

private struct DecimalConversion: Parser.Conversion.`Protocol` {

    typealias Input = String
    typealias Output = Int
    typealias Failure = Parser.Conversion.Error

    func apply(_ input: String) throws(Parser.Conversion.Error) -> Int {
        guard let value = Int(input) else {
            throw .mismatch
        }
        return value
    }

    func unapply(_ output: Int) -> String {
        String(output)
    }
}

private func bump() -> some Coder.`Protocol`<
    HTTP.Route.Input, Call, HTTP.Route.Input, HTTP.Route.Error
> {
    HTTP.Route.Case(
        Optic.Prism(
            embed: Call.bump,
            extract: { call in
                guard case .bump(let value) = call else { return nil }
                return value
            }
        ),
        body: Parser.Skip.First(
            HTTP.Route.Method(.get),
            Parser.Skip.First(
                HTTP.Route.Path.Literal("bump"),
                HTTP.Route.Path.Capture(DecimalConversion())
            )
        )
    )
}

private func poke() -> some Coder.`Protocol`<
    HTTP.Route.Input, Call, HTTP.Route.Input, HTTP.Route.Error
> {
    HTTP.Route.Case(
        Optic.Prism(
            embed: { _ in Call.poke },
            extract: { call in
                guard case .poke = call else { return nil }
                return ()
            }
        ),
        body: Parser.Skip.First(
            HTTP.Route.Method(.post),
            HTTP.Route.Path.Literal("poke")
        )
    )
}

@Test
func `a route case parses its branch and embeds through the prism`() throws {
    var input = HTTP.Route.Input(method: .get, path: ["bump", "41"])
    #expect(try bump().parse(&input) == .bump(41))
    #expect(input.isConsumed)

    var foreign = HTTP.Route.Input(method: .post, path: ["poke"])
    #expect(throws: HTTP.Route.Error.noMatch) {
        try bump().parse(&foreign)
    }
    #expect(try poke().parse(&foreign) == .poke)
    #expect(foreign.isConsumed)
}

@Test
func `a route case prints its own case and refuses a sibling`() throws {
    var own = HTTP.Route.Input()
    try bump().serialize(.bump(7), into: &own)
    #expect(own == HTTP.Route.Input(method: .get, path: ["bump", "7"]))

    var foreign = HTTP.Route.Input()
    #expect(throws: HTTP.Route.Error.noMatch) {
        try bump().serialize(.poke, into: &foreign)
    }
    #expect(foreign == HTTP.Route.Input())
}
