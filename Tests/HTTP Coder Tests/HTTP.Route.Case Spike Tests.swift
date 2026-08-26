// Spike gate (i): partial prism unapply through `Converted`.
//
// `HTTP.Route.Case` must embed a route branch into a `Call` case through a
// derived prism. The backward direction of a prism is partial — `extract`
// is `Optional` — so printing a call through an alternation must let a
// branch refuse a foreign case and hand the buffer to its sibling. This
// reproduction proves the mechanism with the pinned primitives alone:
// `Parser.Conversion.Case` (the prism shape), `Parser.Converted`
// (unapply-then-print), and `Parser.OneOf.Two` (checkpoint and fall through).
import Coder_Parser_Primitives
import Either_Primitives
import Input_Buffer_Primitives
import Parser_Conversion_Primitives
import Parser_OneOf_Primitives
import Parser_Skip_Primitives
import Testing

private enum Call: Equatable {
    case a(UInt8)
    case b(UInt8)
}

private typealias Bytes = Input.Buffer<ContiguousArray<UInt8>>

private typealias Branch = Parser.Converted<
    Parser.Skip.First<
        Coder.Element.Exact<Bytes, [UInt8]>,
        Coder.Element.First<Bytes, [UInt8]>
    >,
    Parser.Conversion.Case<Call, UInt8>
>

private func branch(
    _ marker: UInt8,
    embed: @escaping (UInt8) -> Call,
    extract: @escaping (Call) -> UInt8?
) -> Branch {
    Parser.Skip.First(
        Coder.Element.Exact<Bytes, [UInt8]>(marker),
        Coder.Element.First<Bytes, [UInt8]>()
    ).map(Parser.Conversion.Case(embed: embed, extract: extract))
}

private func first(_ call: Call) -> UInt8? {
    guard case .a(let value) = call else { return nil }
    return value
}

private func second(_ call: Call) -> UInt8? {
    guard case .b(let value) = call else { return nil }
    return value
}

@Test
func `a case conversion refuses to unapply a foreign case`() {
    let a = branch(0x41, embed: Call.a, extract: first)

    var sink: [UInt8] = []
    do {
        try a.serialize(.b(9), into: &sink)
        Issue.record("the case conversion admitted a foreign case")
    } catch {
        guard case .right(.absentCase) = error else {
            Issue.record("expected the conversion refusal, found \(error)")
            return
        }
    }
    #expect(sink.isEmpty)
}

@Test
func `alternation printing selects the branch whose case admits the value`() throws {
    let alternation = Parser.OneOf.Two(
        branch(0x41, embed: Call.a, extract: first),
        branch(0x42, embed: Call.b, extract: second)
    )

    var one: [UInt8] = []
    try alternation.serialize(.a(7), into: &one)
    #expect(one == [0x41, 7])

    var two: [UInt8] = []
    try alternation.serialize(.b(9), into: &two)
    #expect(two == [0x42, 9])
}

@Test
func `alternation parsing continues past a branch that does not match`() throws {
    let alternation = Parser.OneOf.Two(
        branch(0x41, embed: Call.a, extract: first),
        branch(0x42, embed: Call.b, extract: second)
    )

    var input = Bytes([0x42, 9])
    #expect(try alternation.parse(&input) == .b(9))
    #expect(input.isEmpty)
}
