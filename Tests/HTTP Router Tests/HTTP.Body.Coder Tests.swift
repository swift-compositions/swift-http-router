import Byte
import Coder
import HTTP
import HTTP_Router
import RFC_9110
import Testing

struct UTF8Text: HTTP.Body.Coder.`Protocol` {
    typealias Input = [Byte]
    typealias Buffer = [Byte]
    typealias Output = String
    typealias Failure = Never
    typealias Body = Never

    static var contentType: HTTP.MediaType { HTTP.MediaType("text", "plain", parameters: ["charset": "utf-8"]) }

    func parse(_ input: inout [Byte]) -> String {
        let text = String(decoding: input.map(\.bitPattern), as: UTF8.self)
        input = []
        return text
    }

    func serialize(_ output: String, into buffer: inout [Byte]) {
        buffer.append(contentsOf: output.utf8.map(Byte.init(bitPattern:)))
    }
}

struct Refusing: HTTP.Body.Coder.`Protocol` {
    struct Refused: Swift.Error, Equatable {
        let value: String
    }

    typealias Input = [Byte]
    typealias Buffer = [Byte]
    typealias Output = String
    typealias Failure = Refused
    typealias Body = Never

    static var contentType: HTTP.MediaType { HTTP.MediaType("application", "x-refusing") }

    func parse(_ input: inout [Byte]) throws(Refused) -> String {
        throw Refused(value: "parse")
    }

    func serialize(_ output: String, into buffer: inout [Byte]) throws(Refused) {
        buffer.append(contentsOf: output.utf8.map(Byte.init(bitPattern:)))
        if output == "refuse" { throw Refused(value: output) }
    }
}

@Suite
struct `HTTP.Body.Coder Tests` {

    @Test
    func `body set writes the encoded bytes and the coder's content type`() {
        var request = HTTP.Router.Request(method: .post, target: .asterisk)
        request.body(set: "héllo", using: UTF8Text())
        #expect(request.content == "héllo".utf8.map(Byte.init(bitPattern:)))
        #expect(request.headers[.contentType].map(\.rawValue) == [UTF8Text.contentType.value])
        #expect(UTF8Text.contentType.value.contains("charset=utf-8"))
    }

    @Test
    func `body set replaces an existing content type`() {
        var request = HTTP.Router.Request(method: .post, target: .asterisk)
        request.headers.append(RFC_9110.Field(name: .contentType, value: .init(unchecked: "application/octet-stream")))
        request.body(set: "x", using: UTF8Text())
        #expect(request.headers[.contentType].map(\.rawValue) == [UTF8Text.contentType.value])
    }

    @Test
    func `default decode and encode delegate to parse and serialize`() {
        var buffer: [Byte] = []
        let mediaType = UTF8Text().encode("round trip", into: &buffer)
        #expect(mediaType == UTF8Text.contentType)
        var input = buffer
        #expect(UTF8Text().decode(&input, as: mediaType) == "round trip")
        #expect(input.isEmpty)
    }

    @Test
    func `body set propagates the coder's typed failure`() {
        var request = HTTP.Router.Request(method: .post, target: .asterisk)
        #expect(throws: Refusing.Refused(value: "refuse")) {
            try request.body(set: "refuse", using: Refusing())
        }
    }

    @Test
    func `body set leaves the request unchanged when encoding fails`() throws {
        var request = HTTP.Router.Request(method: .post, target: .asterisk)
        request.body(set: "kept", using: UTF8Text())
        let before = request
        #expect(throws: Refusing.Refused.self) {
            try request.body(set: "refuse", using: Refusing())
        }
        #expect(request.content == before.content)
        #expect(request.headers[.contentType].map(\.rawValue) == before.headers[.contentType].map(\.rawValue))
    }
}
