import Byte_Primitive
import Coder_Primitive
import HTTP
import HTTP_Coder
import Parser_Primitive
import Serializer_Primitive
import Testing

private func text() -> HTTP.Coding.Body.Text<String> {
    .init(decode: { $0 }, encode: { $0 })
}

private func decimal() -> HTTP.Coding.Body.Text<Int> {
    .init(
        decode: { text throws(HTTP.Coding.Body.Error) in
            guard let value = Int(text) else {
                throw .invalid
            }
            return value
        },
        encode: { String($0) }
    )
}

@Test
func responseBranchRoundTripsItsStatusAndPayloadCanonically() throws {
    let coder = HTTP.Response.Coder.Branch(status: .ok, content: text())

    var response: HTTP.Response?
    try coder.serialize("hello", into: &response)
    let canonical = response
    #expect(response?.status == .ok)

    let value = try coder.parse(&response)
    #expect(value == "hello")
    #expect(response == nil)

    var serialized: HTTP.Response?
    try coder.serialize(value, into: &serialized)
    #expect(serialized == canonical)
}

@Test
func responseBranchRefusesAnotherStatusWithoutHaltingTheAlternation() throws {
    let refusal = HTTP.Response.Coder.Branch(status: .badRequest, content: text())
    let success = HTTP.Response.Coder.Branch(status: .ok, content: decimal())

    var response = Optional(HTTP.Response(status: .ok, body: "7".utf8.map(Byte.init)))

    // The sibling branch refuses by status alone and leaves the response intact,
    // so the matching branch still gets its turn.
    #expect(throws: HTTP.Response.Coder.Error.noMatch) {
        _ = try refusal.parse(&response)
    }
    #expect(response != nil)

    #expect(try success.parse(&response) == 7)
    #expect(response == nil)
}

@Test
func responseBranchTreatsAMatchingStatusWithABadPayloadAsMalformed() {
    let coder = HTTP.Response.Coder.Branch(status: .ok, content: decimal())

    var inadmissible = Optional(
        HTTP.Response(status: .ok, body: "seven".utf8.map(Byte.init))
    )
    #expect(throws: HTTP.Response.Coder.Error.malformed) {
        _ = try coder.parse(&inadmissible)
    }

    var invalidText = Optional(HTTP.Response(status: .ok, body: [Byte(UInt8(0xFF))]))
    #expect(throws: HTTP.Response.Coder.Error.malformed) {
        _ = try coder.parse(&invalidText)
    }
}

@Test
func responseBranchRejectsAResidualPayloadWithoutConsumingItsInput() {
    let coder = HTTP.Response.Coder.Branch(status: .ok, content: UnconsumingBody())

    var response = Optional(HTTP.Response(status: .ok, body: [Byte(UInt8(1))]))
    let original = response

    #expect(throws: HTTP.Response.Coder.Error.malformed) {
        _ = try coder.parse(&response)
    }
    #expect(response == original)
}
