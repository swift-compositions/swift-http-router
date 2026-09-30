import Byte
import Coder
import Either
import HTTP
import HTTP_Reply
import HTTP_Router
import Parser
import RFC_9110
import Serializer
import Tagged
import Testing

@Suite
struct `HTTP.Reply Tests` {

    @Test
    func `a reply pairs a success with a refusal and round trips both`() throws {
        let reply = HTTP.reply {
            HTTP.ok(Swift.String.Coder.Lossless<Word>())
            HTTP.badRequest(Refusal.Coder())
        }

        var success = HTTP.Router.Response.blank
        try reply.serialize(.right(Word("hello")), into: &success)
        #expect(success.status == .ok)
        #expect(success.content == bytes("hello"))
        var successInput = success
        guard case .right(let word) = try reply.parse(&successInput) else {
            Issue.record("expected the success arm")
            return
        }
        #expect(word == Word("hello"))
        #expect(successInput.content == nil)

        var refusal = HTTP.Router.Response.blank
        try reply.serialize(.left(.refused), into: &refusal)
        #expect(refusal.status == .badRequest)
        #expect(refusal.content == bytes("refused"))
        var refusalInput = refusal
        guard case .left(let reason) = try reply.parse(&refusalInput) else {
            Issue.record("expected the refusal arm")
            return
        }
        #expect(reason == .refused)
    }

    @Test
    func `a refusal may lead the reply`() throws {
        let reply = HTTP.reply {
            HTTP.badRequest(Refusal.Coder())
            HTTP.ok(Swift.String.Coder.Lossless<Word>())
        }

        var response = HTTP.Router.Response.blank
        try reply.serialize(.right(Word("led")), into: &response)
        #expect(response.status == .ok)
        var input = response
        guard case .right(let word) = try reply.parse(&input) else {
            Issue.record("expected the success arm")
            return
        }
        #expect(word == Word("led"))
    }

    @Test
    func `a status no arm owns is a mismatch and a malformed body commits`() throws {
        let reply = HTTP.reply {
            HTTP.ok(Swift.String.Coder.Lossless<Limit>())
            HTTP.badRequest(Refusal.Coder())
        }

        var unknown = HTTP.Router.Response(status: .internalServerError)
        unknown.content = bytes("7")
        #expect(throws: HTTP.Router.Error.mismatch) {
            try reply.parse(&unknown)
        }

        var malformed = HTTP.Router.Response(status: .ok)
        malformed.content = bytes("seven")
        #expect(throws: HTTP.Router.Error.malformed) {
            try reply.parse(&malformed)
        }

        var missing = HTTP.Router.Response(status: .ok)
        #expect(throws: HTTP.Router.Error.malformed) {
            try reply.parse(&missing)
        }
    }

    @Test
    func `an empty success carries no content and refuses any`() throws {
        let reply = HTTP.reply {
            HTTP.noContent()
        }

        var response = HTTP.Router.Response.blank
        try reply.serialize(.right(()), into: &response)
        #expect(response.status == .noContent)
        #expect(response.content == nil)

        var input = response
        _ = try reply.parse(&input)

        var noisy = response
        noisy.content = bytes("noise")
        #expect(throws: HTTP.Router.Error.malformed) {
            try reply.parse(&noisy)
        }
    }

    @Test
    func `success and refusal accept any status`() throws {
        let reply = HTTP.reply {
            HTTP.success(.created, Swift.String.Coder.Lossless<Limit>())
            HTTP.refusal(.conflict, Refusal.Coder())
        }

        var created = HTTP.Router.Response.blank
        try reply.serialize(.right(Limit(3)), into: &created)
        #expect(created.status == .created)
        #expect(created.content == bytes("3"))

        var conflict = HTTP.Router.Response.blank
        try reply.serialize(.left(.refused), into: &conflict)
        #expect(conflict.status == .conflict)
        #expect(conflict.content == bytes("refused"))

        var input = created
        guard case .right(let limit) = try reply.parse(&input) else {
            Issue.record("expected the success arm")
            return
        }
        #expect(limit == Limit(3))
    }

    @Test
    func `an unprintable value cannot be replied`() throws {
        let reply = HTTP.reply {
            HTTP.ok(Ineffable.Coder())
        }

        var response = HTTP.Router.Response.blank
        #expect(throws: HTTP.Router.Error.unprintable) {
            try reply.serialize(.right(.value), into: &response)
        }
    }

    @Test
    func `responses carry values and refusals and read them back`() throws {
        let word = try HTTP.Router.Response.ok(Word("hello"), using: Swift.String.Coder.Lossless<Word>())
        #expect(word.status == .ok)
        #expect(word.content == bytes("hello"))
        #expect(try word.decoded(using: Swift.String.Coder.Lossless<Word>()) == Word("hello"))

        let refusal = try HTTP.Router.Response.badRequest(Refusal.refused, using: Refusal.Coder())
        #expect(refusal.status == .badRequest)
        #expect(refusal.content == bytes("refused"))
        #expect(try refusal.decoded(using: Refusal.Coder()) == .refused)

        let created = try HTTP.Router.Response(201, Limit(3), using: Swift.String.Coder.Lossless<Limit>())
        #expect(created.status == 201)
        #expect(created.content == bytes("3"))

        let empty = HTTP.Router.Response.ok()
        #expect(empty.status == .ok)
        #expect(empty.content == nil)

        #expect(throws: HTTP.Router.Error.malformed) {
            try word.decoded(using: Swift.String.Coder.Lossless<Limit>())
        }
        #expect(throws: HTTP.Router.Error.malformed) {
            try empty.decoded(using: Swift.String.Coder.Lossless<Word>())
        }
        #expect(throws: HTTP.Router.Error.unprintable) {
            try HTTP.Router.Response.ok(Ineffable.value, using: Ineffable.Coder())
        }
    }

    @Test
    func `response conveniences accept independent directions and require full decoding`() throws {
        let response = try HTTP.Router.Response.ok("ab", using: TextWriter())
        #expect(response.content == bytes("ab"))
        #expect(throws: HTTP.Router.Error.malformed) {
            try response.decoded(using: LeadingByteParser())
        }
        #expect(response.content == bytes("ab"))

        let single = try HTTP.Router.Response.ok("a", using: TextWriter())
        #expect(try single.decoded(using: LeadingByteParser()) == bytes("a")[0])
    }
}

private struct TextWriter: Serializing {
    func serialize(_ output: borrowing String, into buffer: inout [Byte]) {
        buffer.append(contentsOf: bytes(output))
    }
}

private struct LeadingByteParser: Parsing {
    func parse(_ input: inout ArraySlice<Byte>) throws(HTTP.Router.Error) -> Byte {
        guard let value = input.popFirst() else { throw .malformed }
        return value
    }
}
