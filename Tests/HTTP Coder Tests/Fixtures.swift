import Byte
import Byte_Standard_Library_Integration
import Coder
import Cursor_Standard_Library_Integration
import Either
import HTTP
import HTTP_Coder
import Operation
import Optic
import Parser
import Parser_Skip
import Prism_Derivation
import RFC_3986
import RFC_9110
import Serializer
import Signature_Derivation

func bytes(_ text: String) -> [Byte] {
    text.utf8.map(Byte.init(bitPattern:))
}

struct Word: Equatable, Coder.Codable {

    let text: String

    init(_ text: String) {
        self.text = text
    }

    static var coder: some Coding<ArraySlice<Byte>, Self, [Byte], HTTP.Message.Content.Error> {
        HTTP.Message.Content.Text().map(to: { Self($0) }, from: { $0.text })
    }
}

struct Numeral: Equatable, Coder.Codable {

    let value: Int

    init(_ value: Int) {
        self.value = value
    }

    enum Error: Swift.Error, Equatable {
        case notADigit
    }

    struct Coder: Coding {

        typealias Input = ArraySlice<Byte>
        typealias Output = Numeral
        typealias Buffer = [Byte]
        typealias Failure = Numeral.Error

        func parse(_ input: inout ArraySlice<Byte>) throws(Numeral.Error) -> Numeral {
            guard let byte = input.next(), (0x30...0x39).contains(byte.bitPattern) else {
                throw .notADigit
            }
            return Numeral(Int(byte.bitPattern - 0x30))
        }

        func serialize(_ output: Numeral, into buffer: inout [Byte]) throws(Numeral.Error) {
            guard (0...9).contains(output.value) else {
                throw .notADigit
            }
            buffer.append(Byte(bitPattern: UInt8(0x30 + output.value)))
        }
    }

    static var coder: Coder { .init() }
}

enum Refusal: Swift.Error, Equatable, Coder.Codable {

    case refused

    static var coder: some Coding<ArraySlice<Byte>, Self, [Byte], HTTP.Message.Content.Error> {
        HTTP.Message.Content.Text().map(to: { _ in Refusal.refused }, from: { _ in "refused" })
    }
}

enum Fixture {
    @Signature
    protocol `Protocol` {
        func echo(_ word: Word) async -> Word
        func shout(_ word: Word) async throws(Refusal) -> Word
    }
}

extension Fixture: HTTP.Routable {

    static var router: some HTTP.Routing<Call> {
        HTTP.Route.Case(\.echo) {
            .post
            HTTP.Target.resource(.init(unchecked: "/echo"))
            HTTP.Content(Word.coder)
        }
        HTTP.Route.Case(\.shout) {
            .post
            HTTP.Target.resource(.init(unchecked: "/shout"))
            HTTP.Content(Word.coder)
        }
    }
}

enum Single {
    @Signature
    protocol `Protocol` {
        func respond(_ digit: Numeral) async throws(Refusal) -> Word
    }
}

extension Single: HTTP.Routable {

    static var router: some HTTP.Routing<Call> {
        HTTP.Route.Case(Respond.self) {
            .post
            HTTP.Target.resource(.init(unchecked: "/respond"))
            HTTP.Content(Numeral.coder)
        }
    }
}

enum Committed {
    @Signature
    protocol `Protocol` {
        func digit(_ value: Numeral) async -> Numeral
        func text(_ value: Word) async -> Word
    }
}

extension Committed: HTTP.Routable {

    static var router: some HTTP.Routing<Call> {
        HTTP.Route.Case(\.digit) {
            .post
            HTTP.Target.resource(.init(unchecked: "/same"))
            HTTP.Content(Numeral.coder)
        }
        HTTP.Route.Case(\.text) {
            .post
            HTTP.Target.resource(.init(unchecked: "/same"))
            HTTP.Content(Word.coder)
        }
    }
}

enum Owned {
    struct Token: ~Copyable {
        let value: Int
    }

    @Signature
    protocol `Protocol` {
        func consume(_ token: consuming Token) async -> Int
    }
}

extension Owned.Token {

    struct Coder: Coding {
        typealias Input = ArraySlice<Byte>
        typealias Output = Owned.Token
        typealias Buffer = [Byte]
        typealias Failure = HTTP.Route.Error

        func parse(_ input: inout ArraySlice<Byte>) throws(HTTP.Route.Error) -> Owned.Token {
            do throws(Numeral.Error) {
                return .init(value: try Numeral.coder.parse(&input).value)
            } catch {
                throw .malformed
            }
        }

        func serialize(_ output: borrowing Owned.Token, into buffer: inout [Byte]) throws(HTTP.Route.Error) {
            do throws(Numeral.Error) {
                try Numeral.coder.serialize(Numeral(output.value), into: &buffer)
            } catch {
                throw .unprintable
            }
        }
    }

    static var coder: Coder { .init() }
}

extension Owned: HTTP.Routable {

    static var router: some HTTP.Routing<Call> {
        HTTP.Route.Case(
            Consume.self,
            content: Parser.Skip(
                Parser.Skip(
                    HTTP.Content<HTTP.Route.Request, Owned.Token.Coder>(Owned.Token.coder),
                    HTTP.Method.post,
                    { $0 },
                    { $0 }
                ),
                HTTP.Target.resource(.init(unchecked: "/consume")),
                { $0 },
                { $0 }
            )
        )
    }
}

enum Linear {
    @Signature
    protocol `Protocol` {
        associatedtype Owned: HTTP_Coder_Tests::Owned.`Protocol`
        associatedtype Single: HTTP_Coder_Tests::Single.`Protocol`

        var owned: Owned { get }
        var single: Single { get }
    }
}

extension Linear: HTTP.Routable {

    static var router: some HTTP.Routing<Call> {
        HTTP.Route.Case(\.owned) {
            Owned.router
        }
        HTTP.Route.Case(\.single) {
            Single.router
        }
    }
}

enum Leaf {
    @Signature
    protocol `Protocol` {
        func op(_ word: Word) async -> Word
    }
}

extension Leaf: HTTP.Routable {

    static var router: some HTTP.Routing<Call> {
        HTTP.Route.Case(\.op) {
            HTTP.Method.put
            HTTP.Target.resource(.init(unchecked: "/leaf"))
            HTTP.Content(Word.coder)
        }
    }
}

enum Middle {
    @Signature
    protocol `Protocol` {
        associatedtype Leaf: HTTP_Coder_Tests::Leaf.`Protocol`

        var leaf: Leaf { get }
    }
}

extension Middle: HTTP.Routable {

    static var router: some HTTP.Routing<Call> {
        HTTP.Route.Case(\.leaf) {
            Leaf.router
        }
    }
}

enum Root {
    @Signature
    protocol `Protocol` {
        associatedtype Middle: HTTP_Coder_Tests::Middle.`Protocol`

        var middle: Middle { get }

        func ping() async
    }
}

extension Root: HTTP.Routable {

    static var router: some HTTP.Routing<Call> {
        HTTP.Route.Case(\.ping) {
            HTTP.Method.get
            HTTP.Target.resource(.init(unchecked: "/ping"))
        }
        HTTP.Route.Case(\.middle) {
            Middle.router
        }
    }
}

enum Wide {
    @Signature
    protocol `Protocol` {
        func c1(_ word: Word) async -> Word
        func c2(_ word: Word) async -> Word
        func c3(_ word: Word) async -> Word
        func c4(_ word: Word) async -> Word
        func c5(_ word: Word) async -> Word
        func c6(_ word: Word) async -> Word
        func c7(_ word: Word) async -> Word
        func c8(_ word: Word) async -> Word
        func c9(_ word: Word) async -> Word
        func c10(_ word: Word) async -> Word
        func c11(_ word: Word) async -> Word
        func c12(_ word: Word) async -> Word
        func c13(_ word: Word) async -> Word
        func c14(_ word: Word) async -> Word
        func c15(_ word: Word) async -> Word
        func c16(_ word: Word) async -> Word
    }
}

extension Wide: HTTP.Routable {

    static var router: some HTTP.Routing<Call> {
        HTTP.Route.Case(\.c1) { .post; HTTP.Target.resource(.init(unchecked: "/c1")); HTTP.Content(Word.coder) }
        HTTP.Route.Case(\.c2) { .post; HTTP.Target.resource(.init(unchecked: "/c2")); HTTP.Content(Word.coder) }
        HTTP.Route.Case(\.c3) { .post; HTTP.Target.resource(.init(unchecked: "/c3")); HTTP.Content(Word.coder) }
        HTTP.Route.Case(\.c4) { .post; HTTP.Target.resource(.init(unchecked: "/c4")); HTTP.Content(Word.coder) }
        HTTP.Route.Case(\.c5) { .post; HTTP.Target.resource(.init(unchecked: "/c5")); HTTP.Content(Word.coder) }
        HTTP.Route.Case(\.c6) { .post; HTTP.Target.resource(.init(unchecked: "/c6")); HTTP.Content(Word.coder) }
        HTTP.Route.Case(\.c7) { .post; HTTP.Target.resource(.init(unchecked: "/c7")); HTTP.Content(Word.coder) }
        HTTP.Route.Case(\.c8) { .post; HTTP.Target.resource(.init(unchecked: "/c8")); HTTP.Content(Word.coder) }
        HTTP.Route.Case(\.c9) { .post; HTTP.Target.resource(.init(unchecked: "/c9")); HTTP.Content(Word.coder) }
        HTTP.Route.Case(\.c10) { .post; HTTP.Target.resource(.init(unchecked: "/c10")); HTTP.Content(Word.coder) }
        HTTP.Route.Case(\.c11) { .post; HTTP.Target.resource(.init(unchecked: "/c11")); HTTP.Content(Word.coder) }
        HTTP.Route.Case(\.c12) { .post; HTTP.Target.resource(.init(unchecked: "/c12")); HTTP.Content(Word.coder) }
        HTTP.Route.Case(\.c13) { .post; HTTP.Target.resource(.init(unchecked: "/c13")); HTTP.Content(Word.coder) }
        HTTP.Route.Case(\.c14) { .post; HTTP.Target.resource(.init(unchecked: "/c14")); HTTP.Content(Word.coder) }
        HTTP.Route.Case(\.c15) { .post; HTTP.Target.resource(.init(unchecked: "/c15")); HTTP.Content(Word.coder) }
        HTTP.Route.Case(\.c16) { .post; HTTP.Target.resource(.init(unchecked: "/c16")); HTTP.Content(Word.coder) }
    }
}

@Prisms
enum Site {
    case home
    case api(Fixture.Call)
}

extension Site: HTTP.Routable {

    static var router: some HTTP.Routing<Self> {
        HTTP.Route.Case(prisms.home) {
            .get
            HTTP.Target.resource(.init(unchecked: "/"))
        }
        HTTP.Route.Case(prisms.api) {
            Fixture.router
        }
    }
}
