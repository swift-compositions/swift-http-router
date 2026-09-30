import Parser
import Byte
import Coder
import Checkpoint
import Either
import HTTP
import HTTP_Router
import Operation
import Optic
import Prism_Macro
import RFC_3986
import RFC_9110
import Serializer
import Interface_Macro
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

@Interface
struct Fixture: Fixture.Interface {
    protocol Interface {
        func echo(_ word: Word) async -> Word
        func shout(_ word: Word) async throws(Refusal) -> Word
    }
}

extension Fixture: HTTP.Routable {

    static var router: some HTTP.Router.`Protocol`<Call> {
        Coder::Case(Call.cases.echo.prism, Call.cases.echo.fold, absent: .mismatch) {
                .post
                HTTP.Target(unchecked: "/echo")
                HTTP.Content(Swift.String.Coder.Lossless<Word>().map(to: { Fixture.Echo.Input($0) }, from: { $0.word }))
        }
        Coder::Case(Call.cases.shout.prism, Call.cases.shout.fold, absent: .mismatch) {
                .post
                HTTP.Target(unchecked: "/shout")
                HTTP.Content(Swift.String.Coder.Lossless<Word>().map(to: { Fixture.Shout.Input($0) }, from: { $0.word }))
        }
    }
}

@Interface
struct Single: Single.Interface {
    protocol Interface {
        func respond(_ limit: Limit) async throws(Refusal) -> Word
    }
}

extension Single: HTTP.Routable {

    static var router: some HTTP.Router.`Protocol`<Call> {
        Coder::Case(Call.cases.respond.prism, Call.cases.respond.fold, absent: .mismatch) {
                .post
                HTTP.Target(unchecked: "/respond")
                HTTP.Content(Swift.String.Coder.Lossless<Limit>().map(to: { Single.Respond.Input($0) }, from: { $0.limit }))
        }
    }
}

@Interface
struct Committed: Committed.Interface {
    protocol Interface {
        func count(_ limit: Limit) async -> Limit
        func name(_ word: Word) async -> Word
    }
}

extension Committed: HTTP.Routable {

    static var router: some HTTP.Router.`Protocol`<Call> {
        Coder::Case(Call.cases.count.prism, Call.cases.count.fold, absent: .mismatch) {
                .post
                HTTP.Target(unchecked: "/same")
                HTTP.Content(Swift.String.Coder.Lossless<Limit>().map(to: { Committed.Count.Input($0) }, from: { $0.limit }))
        }
        Coder::Case(Call.cases.name.prism, Call.cases.name.fold, absent: .mismatch) {
                .post
                HTTP.Target(unchecked: "/same")
                HTTP.Content(Swift.String.Coder.Lossless<Word>().map(to: { Committed.Name.Input($0) }, from: { $0.word }))
        }
    }
}

@Interface
struct Owned: Owned.Interface {
    struct Token: ~Copyable {
        let value: Int
    }

    protocol Interface {
        func consume(_ token: consuming Token) async -> Int
    }
}

extension Owned.Token {

    struct Coder: Coding {

        typealias Input = ArraySlice<Byte>

        typealias Output = Owned.Consume.Input

        typealias Buffer = [Byte]

        typealias Failure = HTTP.Router.Error

        func parse(_ input: inout ArraySlice<Byte>) throws(HTTP.Router.Error) -> Owned.Consume.Input {
            do throws(Swift.String.Coder.Error) {
                return .init(Owned.Token(value: try Swift.String.Coder.Lossless<Int>().parse(&input)))
            } catch {
                throw .malformed
            }
        }

        func serialize(_ output: borrowing Owned.Consume.Input, into buffer: inout [Byte]) throws(HTTP.Router.Error) {
            do throws(Swift.String.Coder.Error) {
                try Swift.String.Coder.Lossless<Int>().serialize(output.token.value, into: &buffer)
            } catch {
                throw .unprintable
            }
        }
    }

}

extension Owned: HTTP.Routable {

    static var router: some HTTP.Router.`Protocol`<Call> {
        Coder::Case(Call.cases.consume.prism, Call.cases.consume.fold, absent: .mismatch) {
                .post
                HTTP.Target(unchecked: "/consume")
                HTTP.Content<HTTP.Router.Request, Owned.Token.Coder>(Owned.Token.Coder())
        }
    }
}

@Interface
struct Linear: Linear.Interface {
    protocol Interface {

        var owned: Owned { get }
        var single: Single { get }
    }
}

extension Linear: HTTP.Routable {

    static var router: some HTTP.Router.`Protocol`<Call> {
        Coder::Case(Call.cases.owned, absent: .mismatch) {
            Owned.router
        }
        Coder::Case(Call.cases.single, absent: .mismatch) {
            Single.router
        }
    }
}

@Interface
struct Leaf: Leaf.Interface {
    protocol Interface {
        func op(_ word: Word) async -> Word
    }
}

extension Leaf: HTTP.Routable {

    static var router: some HTTP.Router.`Protocol`<Call> {
        Coder::Case(Call.cases.op.prism, Call.cases.op.fold, absent: .mismatch) {
                .put
                HTTP.Target(unchecked: "/leaf")
                HTTP.Content(Swift.String.Coder.Lossless<Word>().map(to: { Leaf.Op.Input($0) }, from: { $0.word }))
        }
    }
}

@Interface
struct Middle: Middle.Interface {
    protocol Interface {

        var leaf: Leaf { get }
    }
}

extension Middle: HTTP.Routable {

    static var router: some HTTP.Router.`Protocol`<Call> {
        Coder::Case(Call.cases.leaf, absent: .mismatch) {
            Leaf.router
        }
    }
}

@Interface
struct Root: Root.Interface {
    protocol Interface {

        var middle: Middle { get }

        func ping() async
    }
}

extension Root: HTTP.Routable {

    static var router: some HTTP.Router.`Protocol`<Call> {
        Coder::Case(Call.cases.ping.prism, Call.cases.ping.fold, absent: .mismatch) {
                .get
                HTTP.Target(unchecked: "/ping").map(to: { _ in Root.Ping.Input() }, from: { _ in () })
        }
        Coder::Case(Call.cases.middle, absent: .mismatch) {
            Middle.router
        }
    }
}

@Interface
struct Wide: Wide.Interface {
    protocol Interface {
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
        Coder::Case(Call.cases.c1.prism, Call.cases.c1.fold, absent: .mismatch) {
            .post
            HTTP.Target(unchecked: "/c1")
            HTTP.Content(Swift.String.Coder.Lossless<Word>().map(to: { Wide.C1.Input($0) }, from: { $0.word }))
        }
        Coder::Case(Call.cases.c2.prism, Call.cases.c2.fold, absent: .mismatch) {
            .post
            HTTP.Target(unchecked: "/c2")
            HTTP.Content(Swift.String.Coder.Lossless<Word>().map(to: { Wide.C2.Input($0) }, from: { $0.word }))
        }
        Coder::Case(Call.cases.c3.prism, Call.cases.c3.fold, absent: .mismatch) {
            .post
            HTTP.Target(unchecked: "/c3")
            HTTP.Content(Swift.String.Coder.Lossless<Word>().map(to: { Wide.C3.Input($0) }, from: { $0.word }))
        }
        Coder::Case(Call.cases.c4.prism, Call.cases.c4.fold, absent: .mismatch) {
            .post
            HTTP.Target(unchecked: "/c4")
            HTTP.Content(Swift.String.Coder.Lossless<Word>().map(to: { Wide.C4.Input($0) }, from: { $0.word }))
        }
        Coder::Case(Call.cases.c5.prism, Call.cases.c5.fold, absent: .mismatch) {
            .post
            HTTP.Target(unchecked: "/c5")
            HTTP.Content(Swift.String.Coder.Lossless<Word>().map(to: { Wide.C5.Input($0) }, from: { $0.word }))
        }
        Coder::Case(Call.cases.c6.prism, Call.cases.c6.fold, absent: .mismatch) {
            .post
            HTTP.Target(unchecked: "/c6")
            HTTP.Content(Swift.String.Coder.Lossless<Word>().map(to: { Wide.C6.Input($0) }, from: { $0.word }))
        }
        Coder::Case(Call.cases.c7.prism, Call.cases.c7.fold, absent: .mismatch) {
            .post
            HTTP.Target(unchecked: "/c7")
            HTTP.Content(Swift.String.Coder.Lossless<Word>().map(to: { Wide.C7.Input($0) }, from: { $0.word }))
        }
        Coder::Case(Call.cases.c8.prism, Call.cases.c8.fold, absent: .mismatch) {
            .post
            HTTP.Target(unchecked: "/c8")
            HTTP.Content(Swift.String.Coder.Lossless<Word>().map(to: { Wide.C8.Input($0) }, from: { $0.word }))
        }
        Coder::Case(Call.cases.c9.prism, Call.cases.c9.fold, absent: .mismatch) {
            .post
            HTTP.Target(unchecked: "/c9")
            HTTP.Content(Swift.String.Coder.Lossless<Word>().map(to: { Wide.C9.Input($0) }, from: { $0.word }))
        }
        Coder::Case(Call.cases.c10.prism, Call.cases.c10.fold, absent: .mismatch) {
            .post
            HTTP.Target(unchecked: "/c10")
            HTTP.Content(Swift.String.Coder.Lossless<Word>().map(to: { Wide.C10.Input($0) }, from: { $0.word }))
        }
        Coder::Case(Call.cases.c11.prism, Call.cases.c11.fold, absent: .mismatch) {
            .post
            HTTP.Target(unchecked: "/c11")
            HTTP.Content(Swift.String.Coder.Lossless<Word>().map(to: { Wide.C11.Input($0) }, from: { $0.word }))
        }
        Coder::Case(Call.cases.c12.prism, Call.cases.c12.fold, absent: .mismatch) {
            .post
            HTTP.Target(unchecked: "/c12")
            HTTP.Content(Swift.String.Coder.Lossless<Word>().map(to: { Wide.C12.Input($0) }, from: { $0.word }))
        }
        Coder::Case(Call.cases.c13.prism, Call.cases.c13.fold, absent: .mismatch) {
            .post
            HTTP.Target(unchecked: "/c13")
            HTTP.Content(Swift.String.Coder.Lossless<Word>().map(to: { Wide.C13.Input($0) }, from: { $0.word }))
        }
        Coder::Case(Call.cases.c14.prism, Call.cases.c14.fold, absent: .mismatch) {
            .post
            HTTP.Target(unchecked: "/c14")
            HTTP.Content(Swift.String.Coder.Lossless<Word>().map(to: { Wide.C14.Input($0) }, from: { $0.word }))
        }
        Coder::Case(Call.cases.c15.prism, Call.cases.c15.fold, absent: .mismatch) {
            .post
            HTTP.Target(unchecked: "/c15")
            HTTP.Content(Swift.String.Coder.Lossless<Word>().map(to: { Wide.C15.Input($0) }, from: { $0.word }))
        }
        Coder::Case(Call.cases.c16.prism, Call.cases.c16.fold, absent: .mismatch) {
            .post
            HTTP.Target(unchecked: "/c16")
            HTTP.Content(Swift.String.Coder.Lossless<Word>().map(to: { Wide.C16.Input($0) }, from: { $0.word }))
        }
    }
}

@Prisms
enum Site {
    case home
    case api(Fixture.Call)
}

extension Site: HTTP.Routable {

    static var router: some HTTP.Router.`Protocol`<Self> {
        Coder::Case(prisms.home, absent: .mismatch) {
            .get
            HTTP.Target(unchecked: "/")
        }
        Coder::Case(prisms.api, absent: .mismatch) {
            Fixture.router
        }
    }
}
