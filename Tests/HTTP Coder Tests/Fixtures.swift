import Byte
import Byte_Coder
import Byte_Standard_Library_Integration
import Checkpoint
import Checkpoint_Coder
import Coder
import Either
import HTTP
import HTTP_Coder
import Operation
import Operation_Coder
import Optic
import Optic_Coder
import Parser
import Parser_Skip
import Prism_Derivation
import RFC_3986
import Serializer
import Signature_Derivation
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

enum Fixture {
    @Signature
    protocol `Protocol` {
        func echo(_ word: Word) async -> Word
        func shout(_ word: Word) async throws(Refusal) -> Word
    }
}

extension Fixture: HTTP.Routable {

    static var router: some HTTP.Router.`Protocol`<Call> {
        Call.Router(
            absent: .mismatch,
            echo: HTTP.route {
                .post
                HTTP.Target(unchecked: "/echo")
                HTTP.Content(Word.self)
            },
            shout: HTTP.route {
                .post
                HTTP.Target(unchecked: "/shout")
                HTTP.Content(Word.self)
            }
        )
    }
}

enum Single {
    @Signature
    protocol `Protocol` {
        func respond(_ limit: Limit) async throws(Refusal) -> Word
    }
}

extension Single: HTTP.Routable {

    static var router: some HTTP.Router.`Protocol`<Call> {
        Call.Router(
            absent: .mismatch,
            respond: HTTP.route {
                .post
                HTTP.Target(unchecked: "/respond")
                HTTP.Content(Limit.self)
            }
        )
    }
}

enum Committed {
    @Signature
    protocol `Protocol` {
        func count(_ limit: Limit) async -> Limit
        func name(_ word: Word) async -> Word
    }
}

extension Committed: HTTP.Routable {

    static var router: some HTTP.Router.`Protocol`<Call> {
        Call.Router(
            absent: .mismatch,
            count: HTTP.route {
                .post
                HTTP.Target(unchecked: "/same")
                HTTP.Content(Limit.self)
            },
            name: HTTP.route {
                .post
                HTTP.Target(unchecked: "/same")
                HTTP.Content(Word.self)
            }
        )
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

        typealias Failure = HTTP.Router.Error

        func parse(_ input: inout ArraySlice<Byte>) throws(HTTP.Router.Error) -> Owned.Token {
            do throws(Swift.String.Coder.Error) {
                return .init(value: try Swift.String.Coder.Lossless<Int>().parse(&input))
            } catch {
                throw .malformed
            }
        }

        func serialize(_ output: borrowing Owned.Token, into buffer: inout [Byte]) throws(HTTP.Router.Error) {
            do throws(Swift.String.Coder.Error) {
                try Swift.String.Coder.Lossless<Int>().serialize(output.value, into: &buffer)
            } catch {
                throw .unprintable
            }
        }
    }

    static var coder: Coder { .init() }
}

extension Owned: HTTP.Routable {

    static var router: some HTTP.Router.`Protocol`<Call> {
        Call.Router(
            absent: .mismatch,
            consume: HTTP.route {
                Parser.Skip(
                    Parser.Skip(
                        HTTP.Content<HTTP.Router.Request, Owned.Token.Coder>(Owned.Token.coder),
                        HTTP.Method.post,
                        { $0 },
                        { $0 }
                    ),
                    HTTP.Target(unchecked: "/consume"),
                    { $0 },
                    { $0 }
                )
            }
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

    static var router: some HTTP.Router.`Protocol`<Call> {
        Call.Router(
            absent: .mismatch,
            owned: Owned.router,
            single: Single.router
        )
    }
}

enum Leaf {
    @Signature
    protocol `Protocol` {
        func op(_ word: Word) async -> Word
    }
}

extension Leaf: HTTP.Routable {

    static var router: some HTTP.Router.`Protocol`<Call> {
        Call.Router(
            absent: .mismatch,
            op: HTTP.route {
                .put
                HTTP.Target(unchecked: "/leaf")
                HTTP.Content(Word.self)
            }
        )
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

    static var router: some HTTP.Router.`Protocol`<Call> {
        Call.Router(
            absent: .mismatch,
            leaf: Leaf.router
        )
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

    static var router: some HTTP.Router.`Protocol`<Call> {
        Call.Router(
            absent: .mismatch,
            ping: HTTP.route {
                .get
                HTTP.Target(unchecked: "/ping")
            },
            middle: Middle.router
        )
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

    static var router: some HTTP.Router.`Protocol`<Call> {
        Call.Router(
            absent: .mismatch,
            c1: HTTP.route { .post; HTTP.Target(unchecked: "/c1"); HTTP.Content(Word.self) },
            c2: HTTP.route { .post; HTTP.Target(unchecked: "/c2"); HTTP.Content(Word.self) },
            c3: HTTP.route { .post; HTTP.Target(unchecked: "/c3"); HTTP.Content(Word.self) },
            c4: HTTP.route { .post; HTTP.Target(unchecked: "/c4"); HTTP.Content(Word.self) },
            c5: HTTP.route { .post; HTTP.Target(unchecked: "/c5"); HTTP.Content(Word.self) },
            c6: HTTP.route { .post; HTTP.Target(unchecked: "/c6"); HTTP.Content(Word.self) },
            c7: HTTP.route { .post; HTTP.Target(unchecked: "/c7"); HTTP.Content(Word.self) },
            c8: HTTP.route { .post; HTTP.Target(unchecked: "/c8"); HTTP.Content(Word.self) },
            c9: HTTP.route { .post; HTTP.Target(unchecked: "/c9"); HTTP.Content(Word.self) },
            c10: HTTP.route { .post; HTTP.Target(unchecked: "/c10"); HTTP.Content(Word.self) },
            c11: HTTP.route { .post; HTTP.Target(unchecked: "/c11"); HTTP.Content(Word.self) },
            c12: HTTP.route { .post; HTTP.Target(unchecked: "/c12"); HTTP.Content(Word.self) },
            c13: HTTP.route { .post; HTTP.Target(unchecked: "/c13"); HTTP.Content(Word.self) },
            c14: HTTP.route { .post; HTTP.Target(unchecked: "/c14"); HTTP.Content(Word.self) },
            c15: HTTP.route { .post; HTTP.Target(unchecked: "/c15"); HTTP.Content(Word.self) },
            c16: HTTP.route { .post; HTTP.Target(unchecked: "/c16"); HTTP.Content(Word.self) }
        )
    }
}

@Prisms
enum Site {
    case home
    case api(Fixture.Call)
}

extension Site: HTTP.Routable {

    static var router: some HTTP.Router.`Protocol`<Self> {
        Coder.Case(prisms.home, absent: .mismatch) {
            .get
            HTTP.Target(unchecked: "/")
        }
        Coder.Case(prisms.api, absent: .mismatch) {
            Fixture.router
        }
    }
}
