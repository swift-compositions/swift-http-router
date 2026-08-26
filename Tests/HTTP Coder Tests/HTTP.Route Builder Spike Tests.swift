// Spike gate (ii): result-builder inference over Coder-constrained bodies.
//
// A declarative router branch is a `Take` sequence of leaves inside a
// `OneOf` of branches. The leaves are coders, and the composed value must
// still satisfy `Coder.Protocol` — both directions, one failure type — so
// every builder-selected combinator needs its bidirectional conformance.
// These probes drive `Parser.Take.Builder` and `Parser.OneOf.Builder`
// over the pinned conformances and force the composed types through a
// `Coder.Protocol`-generic law.
import Coder_Parser_Primitives
import Either_Primitives
import Input_Buffer_Primitives
import Parser_Conversion_Primitives
import Parser_OneOf_Primitives
import Parser_Skip_Primitives
import Parser_Take_Primitives
import Testing

private enum Call: Equatable {
    case a(UInt8)
    case b(UInt8)
}

private typealias Bytes = Input.Buffer<ContiguousArray<UInt8>>

private func roundTrips<C: Coder.`Protocol`>(
    _ coder: C,
    prints value: C.Output,
    as bytes: [UInt8]
) throws
where C.Input == Bytes, C.Buffer == [UInt8], C.Output: Equatable {
    var sink: [UInt8] = []
    try coder.serialize(value, into: &sink)
    #expect(sink == bytes)

    var input = Bytes(bytes)
    #expect(try coder.parse(&input) == value)
    #expect(input.isEmpty)
}

@Test
func `the take builder skips a leading unit leaf and keeps the value`() throws {
    let branch = Parser.Take.Sequence {
        Coder.Element.Exact<Bytes, [UInt8]>(0x41)
        Coder.Element.First<Bytes, [UInt8]>()
    }
    try roundTrips(branch, prints: 7, as: [0x41, 7])
}

// Two shapes the builder refuses today, kept out of the register until the
// upstream resolutions land:
//
// - Two unit leaves in sequence (`Exact; Exact; First` — the method-then-
//   path-literal head of every route) is "Ambiguous use of
//   'buildPartialBlock(accumulated:next:)'": the Skip.First and Skip.Second
//   overloads tie when both outputs are Void.
// - Two value leaves (`First; First`) select the favored pack-flattening
//   overload, and `Parser.Take.Two.Map` has no Serializer conformance, so
//   the composed sequence is parse-only and cannot satisfy `Coder.Protocol`.

@Test
func `the alternation builder composes case branches that print`() throws {
    let alternation = Parser.OneOf.Sequence {
        Parser.Take.Sequence {
            Coder.Element.Exact<Bytes, [UInt8]>(0x41)
            Coder.Element.First<Bytes, [UInt8]>()
        }.map(
            Parser.Conversion.Case(
                embed: Call.a,
                extract: { call in
                    guard case .a(let value) = call else { return nil }
                    return value
                }
            )
        )
        Parser.Take.Sequence {
            Coder.Element.Exact<Bytes, [UInt8]>(0x42)
            Coder.Element.First<Bytes, [UInt8]>()
        }.map(
            Parser.Conversion.Case(
                embed: Call.b,
                extract: { call in
                    guard case .b(let value) = call else { return nil }
                    return value
                }
            )
        )
    }
    try roundTrips(alternation, prints: Call.a(7), as: [0x41, 7])
    try roundTrips(alternation, prints: Call.b(9), as: [0x42, 9])
}
