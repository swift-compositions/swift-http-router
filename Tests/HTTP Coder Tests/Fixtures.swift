import Byte
import Byte_Standard_Library_Integration
import Coder
import Cursor_Standard_Library_Integration
import Either
import HTTP
import HTTP_Coder
import Operation
import Optic
import Optic_Coder
import Parser
import Parser_Skip
import RFC_3986
import RFC_9110
import Serializer
import Signature_Derivation

func bytes(_ text: String) -> [Byte] {
    text.utf8.map(Byte.init(bitPattern:))
}

struct Digit: Coding {

    enum Error: Swift.Error, Equatable {
        case notADigit
    }

    typealias Input = ArraySlice<Byte>
    typealias Output = Int
    typealias Buffer = [Byte]
    typealias Failure = Error

    func parse(_ input: inout ArraySlice<Byte>) throws(Error) -> Int {
        guard let byte = input.next(), (0x30...0x39).contains(byte.bitPattern) else {
            throw .notADigit
        }
        return Int(byte.bitPattern - 0x30)
    }

    func serialize(_ output: Int, into buffer: inout [Byte]) throws(Error) {
        guard (0...9).contains(output) else {
            throw .notADigit
        }
        buffer.append(Byte(bitPattern: UInt8(0x30 + output)))
    }
}

enum Fixture {
    enum Refusal: Swift.Error, Equatable {
        case refused
    }

    @Signature
    protocol `Protocol` {
        func echo(_ text: String) async -> String
        func shout(_ text: String) async throws(Refusal) -> String
    }
}

extension Fixture: HTTP.Routable {

    static var route: some HTTP.Routing<Call> {
        HTTP.Route.Case(Echo.self) {
            .post
            HTTP.Target.resource(.init(unchecked: "/echo"))
            HTTP.Content(HTTP.Message.Content.Text())
        }
        HTTP.Route.Case(Shout.self) {
            .post
            HTTP.Target.resource(.init(unchecked: "/shout"))
            HTTP.Content(HTTP.Message.Content.Text())
        }
    }
}

enum Single {
    @Signature
    protocol `Protocol` {
        func respond(_ digit: Int) async throws(Fixture.Refusal) -> String
    }
}

extension Single: HTTP.Routable {

    static var route: some HTTP.Routing<Call> {
        HTTP.Route.Case(Respond.self) {
            .post
            HTTP.Target.resource(.init(unchecked: "/respond"))
            HTTP.Content(Digit())
        }
    }
}

extension Single.Respond: HTTP.Respondable {

    static var response: some HTTP.Replying<Swift.Result<String, Fixture.Refusal>> {
        Coder.Case(Swift.Result<String, Fixture.Refusal>.prisms.success, absent: .mismatch) {
            HTTP.Status.ok {
                HTTP.Content(HTTP.Message.Content.Text())
            }
        }
        Coder.Case(Swift.Result<String, Fixture.Refusal>.prisms.failure, absent: .mismatch) {
            .badRequest
            HTTP.Content(
                HTTP.Message.Content.Text().map(
                    to: { _ in Fixture.Refusal.refused },
                    from: { _ in "refused" }
                )
            )
        }
    }
}

enum Committed {
    @Signature
    protocol `Protocol` {
        func digit(_ value: Int) async -> Int
        func text(_ value: String) async -> String
    }
}

extension Committed: HTTP.Routable {

    static var route: some HTTP.Routing<Call> {
        HTTP.Route.Case(Digit.self) {
            .post
            HTTP.Target.resource(.init(unchecked: "/same"))
            HTTP.Content(HTTP_Coder_Tests.Digit())
        }
        HTTP.Route.Case(Text.self) {
            .post
            HTTP.Target.resource(.init(unchecked: "/same"))
            HTTP.Content(HTTP.Message.Content.Text())
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
            do throws(Digit.Error) {
                return .init(value: try Digit().parse(&input))
            } catch {
                throw .malformed
            }
        }

        func serialize(_ output: borrowing Owned.Token, into buffer: inout [Byte]) throws(HTTP.Route.Error) {
            do throws(Digit.Error) {
                try Digit().serialize(output.value, into: &buffer)
            } catch {
                throw .unprintable
            }
        }
    }

    static var coder: Coder { .init() }
}

extension Owned: HTTP.Routable {

    static var route: some HTTP.Routing<Call> {
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

    static var route: some HTTP.Routing<Call> {
        HTTP.Route.Case(\.owned) {
            Owned.route
        }
        HTTP.Route.Case(\.single) {
            Single.route
        }
    }
}

enum Leaf {
    @Signature
    protocol `Protocol` {
        func op(_ text: String) async -> String
    }
}

extension Leaf: HTTP.Routable {

    static var route: some HTTP.Routing<Call> {
        HTTP.Route.Case(Op.self) {
            HTTP.Method.put
            HTTP.Target.resource(.init(unchecked: "/leaf"))
            HTTP.Content(HTTP.Message.Content.Text())
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

    static var route: some HTTP.Routing<Call> {
        HTTP.Route.Case(\.leaf) {
            Leaf.route
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

    static var route: some HTTP.Routing<Call> {
        HTTP.Route.Case(Ping.self) {
            HTTP.Method.get
            HTTP.Target.resource(.init(unchecked: "/ping"))
        }
        HTTP.Route.Case(\.middle) {
            Middle.route
        }
    }
}

enum Wide {
    @Signature
    protocol `Protocol` {
        func c1(_ text: String) async -> String
        func c2(_ text: String) async -> String
        func c3(_ text: String) async -> String
        func c4(_ text: String) async -> String
        func c5(_ text: String) async -> String
        func c6(_ text: String) async -> String
        func c7(_ text: String) async -> String
        func c8(_ text: String) async -> String
        func c9(_ text: String) async -> String
        func c10(_ text: String) async -> String
        func c11(_ text: String) async -> String
        func c12(_ text: String) async -> String
        func c13(_ text: String) async -> String
        func c14(_ text: String) async -> String
        func c15(_ text: String) async -> String
        func c16(_ text: String) async -> String
    }
}

extension Wide: HTTP.Routable {

    static var route: some HTTP.Routing<Call> {
        HTTP.Route.Case(C1.self) { .post; HTTP.Target.resource(.init(unchecked: "/c1")); HTTP.Content(HTTP.Message.Content.Text()) }
        HTTP.Route.Case(C2.self) { .post; HTTP.Target.resource(.init(unchecked: "/c2")); HTTP.Content(HTTP.Message.Content.Text()) }
        HTTP.Route.Case(C3.self) { .post; HTTP.Target.resource(.init(unchecked: "/c3")); HTTP.Content(HTTP.Message.Content.Text()) }
        HTTP.Route.Case(C4.self) { .post; HTTP.Target.resource(.init(unchecked: "/c4")); HTTP.Content(HTTP.Message.Content.Text()) }
        HTTP.Route.Case(C5.self) { .post; HTTP.Target.resource(.init(unchecked: "/c5")); HTTP.Content(HTTP.Message.Content.Text()) }
        HTTP.Route.Case(C6.self) { .post; HTTP.Target.resource(.init(unchecked: "/c6")); HTTP.Content(HTTP.Message.Content.Text()) }
        HTTP.Route.Case(C7.self) { .post; HTTP.Target.resource(.init(unchecked: "/c7")); HTTP.Content(HTTP.Message.Content.Text()) }
        HTTP.Route.Case(C8.self) { .post; HTTP.Target.resource(.init(unchecked: "/c8")); HTTP.Content(HTTP.Message.Content.Text()) }
        HTTP.Route.Case(C9.self) { .post; HTTP.Target.resource(.init(unchecked: "/c9")); HTTP.Content(HTTP.Message.Content.Text()) }
        HTTP.Route.Case(C10.self) { .post; HTTP.Target.resource(.init(unchecked: "/c10")); HTTP.Content(HTTP.Message.Content.Text()) }
        HTTP.Route.Case(C11.self) { .post; HTTP.Target.resource(.init(unchecked: "/c11")); HTTP.Content(HTTP.Message.Content.Text()) }
        HTTP.Route.Case(C12.self) { .post; HTTP.Target.resource(.init(unchecked: "/c12")); HTTP.Content(HTTP.Message.Content.Text()) }
        HTTP.Route.Case(C13.self) { .post; HTTP.Target.resource(.init(unchecked: "/c13")); HTTP.Content(HTTP.Message.Content.Text()) }
        HTTP.Route.Case(C14.self) { .post; HTTP.Target.resource(.init(unchecked: "/c14")); HTTP.Content(HTTP.Message.Content.Text()) }
        HTTP.Route.Case(C15.self) { .post; HTTP.Target.resource(.init(unchecked: "/c15")); HTTP.Content(HTTP.Message.Content.Text()) }
        HTTP.Route.Case(C16.self) { .post; HTTP.Target.resource(.init(unchecked: "/c16")); HTTP.Content(HTTP.Message.Content.Text()) }
    }
}

enum Sixteen: Equatable {
    case c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16
}

extension Sixteen {

    static func row(_ value: Self) -> Optic<Self, Self, Void, Void>.Prism {
        .fixed(value)
    }

    @HTTP.Route.Builder<Sixteen>
    static var rows: some HTTP.Replying<Sixteen> {
        Coder.Case(row(.c1), absent: .mismatch) { HTTP.Status(201) }
        Coder.Case(row(.c2), absent: .mismatch) { HTTP.Status(202) }
        Coder.Case(row(.c3), absent: .mismatch) { HTTP.Status(203) }
        Coder.Case(row(.c4), absent: .mismatch) { HTTP.Status(204) }
        Coder.Case(row(.c5), absent: .mismatch) { HTTP.Status(205) }
        Coder.Case(row(.c6), absent: .mismatch) { HTTP.Status(206) }
        Coder.Case(row(.c7), absent: .mismatch) { HTTP.Status(207) }
        Coder.Case(row(.c8), absent: .mismatch) { HTTP.Status(208) }
        Coder.Case(row(.c9), absent: .mismatch) { HTTP.Status(209) }
        Coder.Case(row(.c10), absent: .mismatch) { HTTP.Status(210) }
        Coder.Case(row(.c11), absent: .mismatch) { HTTP.Status(211) }
        Coder.Case(row(.c12), absent: .mismatch) { HTTP.Status(212) }
        Coder.Case(row(.c13), absent: .mismatch) { HTTP.Status(213) }
        Coder.Case(row(.c14), absent: .mismatch) { HTTP.Status(214) }
        Coder.Case(row(.c15), absent: .mismatch) { HTTP.Status(215) }
        Coder.Case(row(.c16), absent: .mismatch) { HTTP.Status(216) }
    }
}
