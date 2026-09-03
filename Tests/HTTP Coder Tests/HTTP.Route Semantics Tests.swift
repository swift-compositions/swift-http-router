import Byte
import Byte_Standard_Library_Integration
import Cursor_Standard_Library_Integration
import Coder
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
import Testing

enum Leaf {
    enum Op: Operation.Symbol {
        typealias Input = String
        typealias Output = String
        typealias Failure = Never
    }

    enum Call {
        case op(Operation.Application<Op>)
    }
}

extension Leaf.Call: Operation.Coproduct {

    typealias Operations = Leaf.Op

    struct Prisms {
        var op: Optic<Leaf.Call, Leaf.Call, Operation.Application<Leaf.Op>, Operation.Application<Leaf.Op>>.Prism {
            .init(
                embed: Leaf.Call.op,
                extract: { call in if case .op(let focus) = call { focus } else { nil } }
            )
        }
    }

    static var prisms: Prisms { .init() }
}

extension Leaf.Call: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.op(let left), .op(let right)): left.input == right.input
        }
    }
}

extension Leaf: HTTP.Routable {

    static var route: some HTTP.Routing<Call> {
        HTTP.Route.Case(Call.prisms.op) {
            HTTP.Method.put
            HTTP.Target.resource(.init(unchecked: "/leaf"))
            HTTP.Content(HTTP.Message.Content.Text())
        }
    }
}

enum Middle {
    enum Call {
        case leaf(Leaf.Call)
    }
}

extension Middle.Call: Operation.Coproduct {

    typealias Operations = Leaf.Call

    struct Prisms {
        var leaf: Optic<Middle.Call, Middle.Call, Leaf.Call, Leaf.Call>.Prism {
            .init(
                embed: Middle.Call.leaf,
                extract: { call in if case .leaf(let focus) = call { focus } else { nil } }
            )
        }
    }

    static var prisms: Prisms { .init() }
}

extension Middle.Call: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.leaf(let left), .leaf(let right)): left == right
        }
    }
}

extension Middle: HTTP.Routable {

    static var route: some HTTP.Routing<Call> {
        HTTP.Route.Case(Call.prisms.leaf) {
            Leaf.route
        }
    }
}

enum Root {
    enum Ping: Operation.Symbol {
        typealias Input = Void
        typealias Output = Void
        typealias Failure = Never
    }

    enum Call {
        case middle(Middle.Call)
        case ping(Operation.Application<Ping>)
    }
}

extension Root.Call: Operation.Coproduct {

    typealias Operations = Either<Middle.Call, Root.Ping>

    struct Prisms {
        var middle: Optic<Root.Call, Root.Call, Middle.Call, Middle.Call>.Prism {
            .init(
                embed: Root.Call.middle,
                extract: { call in if case .middle(let focus) = call { focus } else { nil } }
            )
        }

        var ping: Optic<Root.Call, Root.Call, Operation.Application<Root.Ping>, Operation.Application<Root.Ping>>.Prism {
            .init(
                embed: Root.Call.ping,
                extract: { call in if case .ping(let focus) = call { focus } else { nil } }
            )
        }
    }

    static var prisms: Prisms { .init() }
}

extension Root.Call: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.middle(let left), .middle(let right)): left == right
        case (.ping, .ping): true
        default: false
        }
    }
}

extension Root: HTTP.Routable {

    static var route: some HTTP.Routing<Call> {
        HTTP.Route.Case(Call.prisms.middle) {
            Middle.route
        }
        HTTP.Route.Case(Call.prisms.ping) {
            HTTP.Method.get
            HTTP.Target.resource(.init(unchecked: "/ping"))
        }
    }
}

enum Wide {
    enum C1: Operation.Symbol {
        typealias Input = String
        typealias Output = String
        typealias Failure = Never
    }
    enum C2: Operation.Symbol {
        typealias Input = String
        typealias Output = String
        typealias Failure = Never
    }
    enum C3: Operation.Symbol {
        typealias Input = String
        typealias Output = String
        typealias Failure = Never
    }
    enum C4: Operation.Symbol {
        typealias Input = String
        typealias Output = String
        typealias Failure = Never
    }
    enum C5: Operation.Symbol {
        typealias Input = String
        typealias Output = String
        typealias Failure = Never
    }
    enum C6: Operation.Symbol {
        typealias Input = String
        typealias Output = String
        typealias Failure = Never
    }
    enum C7: Operation.Symbol {
        typealias Input = String
        typealias Output = String
        typealias Failure = Never
    }
    enum C8: Operation.Symbol {
        typealias Input = String
        typealias Output = String
        typealias Failure = Never
    }
    enum C9: Operation.Symbol {
        typealias Input = String
        typealias Output = String
        typealias Failure = Never
    }
    enum C10: Operation.Symbol {
        typealias Input = String
        typealias Output = String
        typealias Failure = Never
    }
    enum C11: Operation.Symbol {
        typealias Input = String
        typealias Output = String
        typealias Failure = Never
    }
    enum C12: Operation.Symbol {
        typealias Input = String
        typealias Output = String
        typealias Failure = Never
    }
    enum C13: Operation.Symbol {
        typealias Input = String
        typealias Output = String
        typealias Failure = Never
    }
    enum C14: Operation.Symbol {
        typealias Input = String
        typealias Output = String
        typealias Failure = Never
    }
    enum C15: Operation.Symbol {
        typealias Input = String
        typealias Output = String
        typealias Failure = Never
    }
    enum C16: Operation.Symbol {
        typealias Input = String
        typealias Output = String
        typealias Failure = Never
    }

    enum Call {
        case c1(Operation.Application<C1>)
        case c2(Operation.Application<C2>)
        case c3(Operation.Application<C3>)
        case c4(Operation.Application<C4>)
        case c5(Operation.Application<C5>)
        case c6(Operation.Application<C6>)
        case c7(Operation.Application<C7>)
        case c8(Operation.Application<C8>)
        case c9(Operation.Application<C9>)
        case c10(Operation.Application<C10>)
        case c11(Operation.Application<C11>)
        case c12(Operation.Application<C12>)
        case c13(Operation.Application<C13>)
        case c14(Operation.Application<C14>)
        case c15(Operation.Application<C15>)
        case c16(Operation.Application<C16>)
    }
}

extension Wide.Call: Operation.Coproduct {

    typealias Operations = Either<Either<Either<Either<Either<Either<Either<Either<Either<Either<Either<Either<Either<Either<Either<Wide.C1, Wide.C2>, Wide.C3>, Wide.C4>, Wide.C5>, Wide.C6>, Wide.C7>, Wide.C8>, Wide.C9>, Wide.C10>, Wide.C11>, Wide.C12>, Wide.C13>, Wide.C14>, Wide.C15>, Wide.C16>

    struct Prisms {
        var c1: Optic<Wide.Call, Wide.Call, Operation.Application<Wide.C1>, Operation.Application<Wide.C1>>.Prism {
            .init(
                embed: Wide.Call.c1,
                extract: { call in if case .c1(let focus) = call { focus } else { nil } }
            )
        }

        var c2: Optic<Wide.Call, Wide.Call, Operation.Application<Wide.C2>, Operation.Application<Wide.C2>>.Prism {
            .init(
                embed: Wide.Call.c2,
                extract: { call in if case .c2(let focus) = call { focus } else { nil } }
            )
        }

        var c3: Optic<Wide.Call, Wide.Call, Operation.Application<Wide.C3>, Operation.Application<Wide.C3>>.Prism {
            .init(
                embed: Wide.Call.c3,
                extract: { call in if case .c3(let focus) = call { focus } else { nil } }
            )
        }

        var c4: Optic<Wide.Call, Wide.Call, Operation.Application<Wide.C4>, Operation.Application<Wide.C4>>.Prism {
            .init(
                embed: Wide.Call.c4,
                extract: { call in if case .c4(let focus) = call { focus } else { nil } }
            )
        }

        var c5: Optic<Wide.Call, Wide.Call, Operation.Application<Wide.C5>, Operation.Application<Wide.C5>>.Prism {
            .init(
                embed: Wide.Call.c5,
                extract: { call in if case .c5(let focus) = call { focus } else { nil } }
            )
        }

        var c6: Optic<Wide.Call, Wide.Call, Operation.Application<Wide.C6>, Operation.Application<Wide.C6>>.Prism {
            .init(
                embed: Wide.Call.c6,
                extract: { call in if case .c6(let focus) = call { focus } else { nil } }
            )
        }

        var c7: Optic<Wide.Call, Wide.Call, Operation.Application<Wide.C7>, Operation.Application<Wide.C7>>.Prism {
            .init(
                embed: Wide.Call.c7,
                extract: { call in if case .c7(let focus) = call { focus } else { nil } }
            )
        }

        var c8: Optic<Wide.Call, Wide.Call, Operation.Application<Wide.C8>, Operation.Application<Wide.C8>>.Prism {
            .init(
                embed: Wide.Call.c8,
                extract: { call in if case .c8(let focus) = call { focus } else { nil } }
            )
        }

        var c9: Optic<Wide.Call, Wide.Call, Operation.Application<Wide.C9>, Operation.Application<Wide.C9>>.Prism {
            .init(
                embed: Wide.Call.c9,
                extract: { call in if case .c9(let focus) = call { focus } else { nil } }
            )
        }

        var c10: Optic<Wide.Call, Wide.Call, Operation.Application<Wide.C10>, Operation.Application<Wide.C10>>.Prism {
            .init(
                embed: Wide.Call.c10,
                extract: { call in if case .c10(let focus) = call { focus } else { nil } }
            )
        }

        var c11: Optic<Wide.Call, Wide.Call, Operation.Application<Wide.C11>, Operation.Application<Wide.C11>>.Prism {
            .init(
                embed: Wide.Call.c11,
                extract: { call in if case .c11(let focus) = call { focus } else { nil } }
            )
        }

        var c12: Optic<Wide.Call, Wide.Call, Operation.Application<Wide.C12>, Operation.Application<Wide.C12>>.Prism {
            .init(
                embed: Wide.Call.c12,
                extract: { call in if case .c12(let focus) = call { focus } else { nil } }
            )
        }

        var c13: Optic<Wide.Call, Wide.Call, Operation.Application<Wide.C13>, Operation.Application<Wide.C13>>.Prism {
            .init(
                embed: Wide.Call.c13,
                extract: { call in if case .c13(let focus) = call { focus } else { nil } }
            )
        }

        var c14: Optic<Wide.Call, Wide.Call, Operation.Application<Wide.C14>, Operation.Application<Wide.C14>>.Prism {
            .init(
                embed: Wide.Call.c14,
                extract: { call in if case .c14(let focus) = call { focus } else { nil } }
            )
        }

        var c15: Optic<Wide.Call, Wide.Call, Operation.Application<Wide.C15>, Operation.Application<Wide.C15>>.Prism {
            .init(
                embed: Wide.Call.c15,
                extract: { call in if case .c15(let focus) = call { focus } else { nil } }
            )
        }

        var c16: Optic<Wide.Call, Wide.Call, Operation.Application<Wide.C16>, Operation.Application<Wide.C16>>.Prism {
            .init(
                embed: Wide.Call.c16,
                extract: { call in if case .c16(let focus) = call { focus } else { nil } }
            )
        }
    }

    static var prisms: Prisms { .init() }
}

extension Wide.Call: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.c1(let left), .c1(let right)): left.input == right.input
        case (.c2(let left), .c2(let right)): left.input == right.input
        case (.c3(let left), .c3(let right)): left.input == right.input
        case (.c4(let left), .c4(let right)): left.input == right.input
        case (.c5(let left), .c5(let right)): left.input == right.input
        case (.c6(let left), .c6(let right)): left.input == right.input
        case (.c7(let left), .c7(let right)): left.input == right.input
        case (.c8(let left), .c8(let right)): left.input == right.input
        case (.c9(let left), .c9(let right)): left.input == right.input
        case (.c10(let left), .c10(let right)): left.input == right.input
        case (.c11(let left), .c11(let right)): left.input == right.input
        case (.c12(let left), .c12(let right)): left.input == right.input
        case (.c13(let left), .c13(let right)): left.input == right.input
        case (.c14(let left), .c14(let right)): left.input == right.input
        case (.c15(let left), .c15(let right)): left.input == right.input
        case (.c16(let left), .c16(let right)): left.input == right.input
        default: false
        }
    }
}

extension Wide: HTTP.Routable {

    static var route: some HTTP.Routing<Call> {
        HTTP.Route.Case(Call.prisms.c1) {
            HTTP.Method.post
            HTTP.Target.resource(.init(unchecked: "/c1"))
            HTTP.Content(HTTP.Message.Content.Text())
        }
        HTTP.Route.Case(Call.prisms.c2) {
            HTTP.Method.post
            HTTP.Target.resource(.init(unchecked: "/c2"))
            HTTP.Content(HTTP.Message.Content.Text())
        }
        HTTP.Route.Case(Call.prisms.c3) {
            HTTP.Method.post
            HTTP.Target.resource(.init(unchecked: "/c3"))
            HTTP.Content(HTTP.Message.Content.Text())
        }
        HTTP.Route.Case(Call.prisms.c4) {
            HTTP.Method.post
            HTTP.Target.resource(.init(unchecked: "/c4"))
            HTTP.Content(HTTP.Message.Content.Text())
        }
        HTTP.Route.Case(Call.prisms.c5) {
            HTTP.Method.post
            HTTP.Target.resource(.init(unchecked: "/c5"))
            HTTP.Content(HTTP.Message.Content.Text())
        }
        HTTP.Route.Case(Call.prisms.c6) {
            HTTP.Method.post
            HTTP.Target.resource(.init(unchecked: "/c6"))
            HTTP.Content(HTTP.Message.Content.Text())
        }
        HTTP.Route.Case(Call.prisms.c7) {
            HTTP.Method.post
            HTTP.Target.resource(.init(unchecked: "/c7"))
            HTTP.Content(HTTP.Message.Content.Text())
        }
        HTTP.Route.Case(Call.prisms.c8) {
            HTTP.Method.post
            HTTP.Target.resource(.init(unchecked: "/c8"))
            HTTP.Content(HTTP.Message.Content.Text())
        }
        HTTP.Route.Case(Call.prisms.c9) {
            HTTP.Method.post
            HTTP.Target.resource(.init(unchecked: "/c9"))
            HTTP.Content(HTTP.Message.Content.Text())
        }
        HTTP.Route.Case(Call.prisms.c10) {
            HTTP.Method.post
            HTTP.Target.resource(.init(unchecked: "/c10"))
            HTTP.Content(HTTP.Message.Content.Text())
        }
        HTTP.Route.Case(Call.prisms.c11) {
            HTTP.Method.post
            HTTP.Target.resource(.init(unchecked: "/c11"))
            HTTP.Content(HTTP.Message.Content.Text())
        }
        HTTP.Route.Case(Call.prisms.c12) {
            HTTP.Method.post
            HTTP.Target.resource(.init(unchecked: "/c12"))
            HTTP.Content(HTTP.Message.Content.Text())
        }
        HTTP.Route.Case(Call.prisms.c13) {
            HTTP.Method.post
            HTTP.Target.resource(.init(unchecked: "/c13"))
            HTTP.Content(HTTP.Message.Content.Text())
        }
        HTTP.Route.Case(Call.prisms.c14) {
            HTTP.Method.post
            HTTP.Target.resource(.init(unchecked: "/c14"))
            HTTP.Content(HTTP.Message.Content.Text())
        }
        HTTP.Route.Case(Call.prisms.c15) {
            HTTP.Method.post
            HTTP.Target.resource(.init(unchecked: "/c15"))
            HTTP.Content(HTTP.Message.Content.Text())
        }
        HTTP.Route.Case(Call.prisms.c16) {
            HTTP.Method.post
            HTTP.Target.resource(.init(unchecked: "/c16"))
            HTTP.Content(HTTP.Message.Content.Text())
        }
    }
}

private struct Unprintable: Coding {

    enum Error: Swift.Error {
        case refused
    }

    typealias Input = ArraySlice<Byte>
    typealias Output = String
    typealias Buffer = [Byte]
    typealias Failure = Error

    func parse(_ input: inout ArraySlice<Byte>) throws(Error) -> String {
        throw .refused
    }

    func serialize(_ output: String, into buffer: inout [Byte]) throws(Error) {
        throw .refused
    }
}

private func utf8(_ text: String) -> [Byte] {
    text.utf8.map(Byte.init(bitPattern:))
}

@Suite
struct `HTTP.Route Semantics Tests` {

    @Test
    func `every field coder mismatches and never malforms`() throws {
        var request = HTTP.Route.Request(method: .get, target: .asterisk)
        #expect(throws: HTTP.Route.Error.mismatch) { try HTTP.Method.post.parse(&request) }
        #expect(throws: HTTP.Route.Error.mismatch) {
            try HTTP.Target.resource(.init(unchecked: "/x")).parse(&request)
        }
        try HTTP.Method.get.parse(&request)
        try HTTP.Target.asterisk.parse(&request)

        var response = HTTP.Route.Response(status: .notFound)
        #expect(throws: HTTP.Route.Error.mismatch) { try HTTP.Status.ok.parse(&response) }
        try HTTP.Status.notFound.parse(&response)
    }

    @Test
    func `the content bridge malforms on bytes and is unprintable on values`() throws {
        var request = HTTP.Route.Request(method: .post, target: .asterisk)
        request.content = utf8("anything")
        #expect(throws: HTTP.Route.Error.malformed) {
            try HTTP.Content(Unprintable()).parse(&request)
        }
        var buffer = HTTP.Route.Request.blank
        #expect(throws: HTTP.Route.Error.unprintable) {
            try HTTP.Content(Unprintable()).serialize("anything", into: &buffer)
        }
        #expect(buffer.content == nil)
    }

    @Test
    func `serializing a call no arm owns is a mismatch`() throws {
        var buffer = HTTP.Route.Request.blank
        #expect(throws: HTTP.Route.Error.mismatch) {
            try HTTP.Route.Case(Root.Call.prisms.ping) { HTTP.Method.get }
                .serialize(.middle(.leaf(.op(.init("x")))), into: &buffer)
        }
        #expect(buffer == HTTP.Route.Request.blank)
    }

    @Test
    func `a three-level domain routes through nested cases`() throws {
        let deep = Root.Call.middle(.leaf(.op(.init("deep"))))
        let request = try HTTP.request(Root.self, for: deep)
        #expect(request.method == .put)
        #expect(request.target == .resource(.init(unchecked: "/leaf")))
        #expect(request.content == utf8("deep"))
        #expect(try HTTP.route(Root.self, request) == deep)

        let ping = try HTTP.request(Root.self, for: .ping(.init(())))
        #expect(ping.method == .get)
        #expect(ping.content == nil)
        #expect(try HTTP.route(Root.self, ping) == .ping(.init(())))

        var extra = ping
        extra.content = utf8("noise")
        #expect(throws: HTTP.Route.Error.malformed) {
            try HTTP.route(Root.self, extra)
        }
    }

    @Test
    func `sixteen request routes type-check as one committed choice`() throws {
        for call in [Wide.Call.c1(.init("a")), .c9(.init("i")), .c16(.init("p"))] {
            let request = try HTTP.request(Wide.self, for: call)
            #expect(try HTTP.route(Wide.self, request) == call)
        }
        let unknown = HTTP.Route.Request(method: .post, target: .resource(.init(unchecked: "/c17")))
        #expect(throws: HTTP.Route.Error.mismatch) {
            try HTTP.route(Wide.self, unknown)
        }
    }
}
