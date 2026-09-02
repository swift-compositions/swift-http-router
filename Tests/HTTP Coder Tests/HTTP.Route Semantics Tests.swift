import Byte
import Byte_Parser
import Call_Algebra
import Coder
import HTTP
import HTTP_Coder
import Optic
import Optic_Coder
import Parser
import Parser_Skip
import RFC_3986
import RFC_9110
import Serializer
import Testing

enum Leaf {}

extension Leaf {

    enum Call: Equatable {
        case op(String)
    }
}

extension Leaf.Call {

    enum Branch {
        enum Op {}
    }

    struct Branches {

        var op: Call_Algebra.Call.Branch<Leaf.Call, String, Branch.Op> {
            .init(.init(embed: Leaf.Call.op, extract: { call in if case .op(let text) = call { text } else { nil } }))
        }
    }
}

extension Leaf.Call.Branch.Op: Call_Algebra.Call.Operation {
    typealias Input = String
    typealias Output = String
    typealias Failure = Never
}

extension Leaf.Call: Call_Algebra.Call.`Protocol` {
    typealias Coverage = Branch.Op

    static var branches: Branches { .init() }
}

extension Leaf: HTTP.Routable {

    static var route: some HTTP.Routing<Call> {
        HTTP.Route.Case(\.op) {
            HTTP.Method.put
            HTTP.Target.resource(.init(unchecked: "/leaf"))
            HTTP.Content(HTTP.Message.Content.Text())
        }
    }
}

enum Middle {}

extension Middle {

    enum Call: Equatable {
        case leaf(Leaf.Call)
    }
}

extension Middle.Call {

    enum Branch {
        enum Leaf {}
    }

    struct Branches {

        var leaf: Call_Algebra.Call.Branch<Middle.Call, Leaf.Call, Branch.Leaf> {
            .init(.init(embed: Middle.Call.leaf, extract: { call in if case .leaf(let leaf) = call { leaf } else { nil } }))
        }
    }
}

extension Middle.Call: Call_Algebra.Call.`Protocol` {
    typealias Coverage = Branch.Leaf

    static var branches: Branches { .init() }
}

extension Middle: HTTP.Routable {

    static var route: some HTTP.Routing<Call> {
        HTTP.Route.Case(\.leaf) {
            Leaf.route
        }
    }
}

enum Root {}

extension Root {

    enum Call: Equatable {
        case middle(Middle.Call)
        case ping
    }
}

extension Root.Call {

    enum Branch {
        enum Middle {}
        enum Ping {}
    }

    struct Branches {

        var middle: Call_Algebra.Call.Branch<Root.Call, Middle.Call, Branch.Middle> {
            .init(.init(embed: Root.Call.middle, extract: { call in if case .middle(let middle) = call { middle } else { nil } }))
        }

        var ping: Call_Algebra.Call.Branch<Root.Call, Void, Branch.Ping> {
            .init(.init(embed: { _ in Root.Call.ping }, extract: { call in if case .ping = call { () } else { nil } }))
        }
    }
}

extension Root.Call.Branch.Ping: Call_Algebra.Call.Operation {
    typealias Input = Void
    typealias Output = Void
    typealias Failure = Never
}

extension Root.Call: Call_Algebra.Call.`Protocol` {
    typealias Coverage = Call_Algebra.Call.Coverage<Branch.Middle, Branch.Ping>

    static var branches: Branches { .init() }
}

extension Root: HTTP.Routable {

    static var route: some HTTP.Routing<Call> {
        HTTP.Route.Case(\.middle) {
            Middle.route
        }
        HTTP.Route.Case(\.ping) {
            HTTP.Method.get
            HTTP.Target.resource(.init(unchecked: "/ping"))
        }
    }
}

enum Wide {}

extension Wide {

    enum Call: Equatable {
        case c1(String)
        case c2(String)
        case c3(String)
        case c4(String)
        case c5(String)
        case c6(String)
        case c7(String)
        case c8(String)
        case c9(String)
        case c10(String)
        case c11(String)
        case c12(String)
        case c13(String)
        case c14(String)
        case c15(String)
        case c16(String)
    }
}

extension Wide.Call {

    enum Branch {
        enum C1 {}
        enum C2 {}
        enum C3 {}
        enum C4 {}
        enum C5 {}
        enum C6 {}
        enum C7 {}
        enum C8 {}
        enum C9 {}
        enum C10 {}
        enum C11 {}
        enum C12 {}
        enum C13 {}
        enum C14 {}
        enum C15 {}
        enum C16 {}
    }

    struct Branches {

        var c1: Call_Algebra.Call.Branch<Wide.Call, String, Branch.C1> {
            .init(
                .init(
                    embed: Wide.Call.c1,
                    extract: { call in
                        if case .c1(let text) = call { text } else { nil }
                    }
                )
            )
        }

        var c2: Call_Algebra.Call.Branch<Wide.Call, String, Branch.C2> {
            .init(
                .init(
                    embed: Wide.Call.c2,
                    extract: { call in
                        if case .c2(let text) = call { text } else { nil }
                    }
                )
            )
        }

        var c3: Call_Algebra.Call.Branch<Wide.Call, String, Branch.C3> {
            .init(
                .init(
                    embed: Wide.Call.c3,
                    extract: { call in
                        if case .c3(let text) = call { text } else { nil }
                    }
                )
            )
        }

        var c4: Call_Algebra.Call.Branch<Wide.Call, String, Branch.C4> {
            .init(
                .init(
                    embed: Wide.Call.c4,
                    extract: { call in
                        if case .c4(let text) = call { text } else { nil }
                    }
                )
            )
        }

        var c5: Call_Algebra.Call.Branch<Wide.Call, String, Branch.C5> {
            .init(
                .init(
                    embed: Wide.Call.c5,
                    extract: { call in
                        if case .c5(let text) = call { text } else { nil }
                    }
                )
            )
        }

        var c6: Call_Algebra.Call.Branch<Wide.Call, String, Branch.C6> {
            .init(
                .init(
                    embed: Wide.Call.c6,
                    extract: { call in
                        if case .c6(let text) = call { text } else { nil }
                    }
                )
            )
        }

        var c7: Call_Algebra.Call.Branch<Wide.Call, String, Branch.C7> {
            .init(
                .init(
                    embed: Wide.Call.c7,
                    extract: { call in
                        if case .c7(let text) = call { text } else { nil }
                    }
                )
            )
        }

        var c8: Call_Algebra.Call.Branch<Wide.Call, String, Branch.C8> {
            .init(
                .init(
                    embed: Wide.Call.c8,
                    extract: { call in
                        if case .c8(let text) = call { text } else { nil }
                    }
                )
            )
        }

        var c9: Call_Algebra.Call.Branch<Wide.Call, String, Branch.C9> {
            .init(
                .init(
                    embed: Wide.Call.c9,
                    extract: { call in
                        if case .c9(let text) = call { text } else { nil }
                    }
                )
            )
        }

        var c10: Call_Algebra.Call.Branch<Wide.Call, String, Branch.C10> {
            .init(
                .init(
                    embed: Wide.Call.c10,
                    extract: { call in
                        if case .c10(let text) = call { text } else { nil }
                    }
                )
            )
        }

        var c11: Call_Algebra.Call.Branch<Wide.Call, String, Branch.C11> {
            .init(
                .init(
                    embed: Wide.Call.c11,
                    extract: { call in
                        if case .c11(let text) = call { text } else { nil }
                    }
                )
            )
        }

        var c12: Call_Algebra.Call.Branch<Wide.Call, String, Branch.C12> {
            .init(
                .init(
                    embed: Wide.Call.c12,
                    extract: { call in
                        if case .c12(let text) = call { text } else { nil }
                    }
                )
            )
        }

        var c13: Call_Algebra.Call.Branch<Wide.Call, String, Branch.C13> {
            .init(
                .init(
                    embed: Wide.Call.c13,
                    extract: { call in
                        if case .c13(let text) = call { text } else { nil }
                    }
                )
            )
        }

        var c14: Call_Algebra.Call.Branch<Wide.Call, String, Branch.C14> {
            .init(
                .init(
                    embed: Wide.Call.c14,
                    extract: { call in
                        if case .c14(let text) = call { text } else { nil }
                    }
                )
            )
        }

        var c15: Call_Algebra.Call.Branch<Wide.Call, String, Branch.C15> {
            .init(
                .init(
                    embed: Wide.Call.c15,
                    extract: { call in
                        if case .c15(let text) = call { text } else { nil }
                    }
                )
            )
        }

        var c16: Call_Algebra.Call.Branch<Wide.Call, String, Branch.C16> {
            .init(
                .init(
                    embed: Wide.Call.c16,
                    extract: { call in
                        if case .c16(let text) = call { text } else { nil }
                    }
                )
            )
        }
    }
}

extension Wide.Call.Branch.C1: Call_Algebra.Call.Operation {
    typealias Input = String
    typealias Output = String
    typealias Failure = Never
}
extension Wide.Call.Branch.C2: Call_Algebra.Call.Operation {
    typealias Input = String
    typealias Output = String
    typealias Failure = Never
}
extension Wide.Call.Branch.C3: Call_Algebra.Call.Operation {
    typealias Input = String
    typealias Output = String
    typealias Failure = Never
}
extension Wide.Call.Branch.C4: Call_Algebra.Call.Operation {
    typealias Input = String
    typealias Output = String
    typealias Failure = Never
}
extension Wide.Call.Branch.C5: Call_Algebra.Call.Operation {
    typealias Input = String
    typealias Output = String
    typealias Failure = Never
}
extension Wide.Call.Branch.C6: Call_Algebra.Call.Operation {
    typealias Input = String
    typealias Output = String
    typealias Failure = Never
}
extension Wide.Call.Branch.C7: Call_Algebra.Call.Operation {
    typealias Input = String
    typealias Output = String
    typealias Failure = Never
}
extension Wide.Call.Branch.C8: Call_Algebra.Call.Operation {
    typealias Input = String
    typealias Output = String
    typealias Failure = Never
}
extension Wide.Call.Branch.C9: Call_Algebra.Call.Operation {
    typealias Input = String
    typealias Output = String
    typealias Failure = Never
}
extension Wide.Call.Branch.C10: Call_Algebra.Call.Operation {
    typealias Input = String
    typealias Output = String
    typealias Failure = Never
}
extension Wide.Call.Branch.C11: Call_Algebra.Call.Operation {
    typealias Input = String
    typealias Output = String
    typealias Failure = Never
}
extension Wide.Call.Branch.C12: Call_Algebra.Call.Operation {
    typealias Input = String
    typealias Output = String
    typealias Failure = Never
}
extension Wide.Call.Branch.C13: Call_Algebra.Call.Operation {
    typealias Input = String
    typealias Output = String
    typealias Failure = Never
}
extension Wide.Call.Branch.C14: Call_Algebra.Call.Operation {
    typealias Input = String
    typealias Output = String
    typealias Failure = Never
}
extension Wide.Call.Branch.C15: Call_Algebra.Call.Operation {
    typealias Input = String
    typealias Output = String
    typealias Failure = Never
}
extension Wide.Call.Branch.C16: Call_Algebra.Call.Operation {
    typealias Input = String
    typealias Output = String
    typealias Failure = Never
}

extension Wide.Call: Call_Algebra.Call.`Protocol` {
    typealias Coverage = Call_Algebra.Call.Coverage<Call_Algebra.Call.Coverage<Call_Algebra.Call.Coverage<Call_Algebra.Call.Coverage<Call_Algebra.Call.Coverage<Call_Algebra.Call.Coverage<Call_Algebra.Call.Coverage<Call_Algebra.Call.Coverage<Call_Algebra.Call.Coverage<Call_Algebra.Call.Coverage<Call_Algebra.Call.Coverage<Call_Algebra.Call.Coverage<Call_Algebra.Call.Coverage<Call_Algebra.Call.Coverage<Call_Algebra.Call.Coverage<Branch.C1, Branch.C2>, Branch.C3>, Branch.C4>, Branch.C5>, Branch.C6>, Branch.C7>, Branch.C8>, Branch.C9>, Branch.C10>, Branch.C11>, Branch.C12>, Branch.C13>, Branch.C14>, Branch.C15>, Branch.C16>

    static var branches: Branches { .init() }
}

extension Wide: HTTP.Routable {

    static var route: some HTTP.Routing<Call> {
        HTTP.Route.Case(\.c1) {
            HTTP.Method.post
            HTTP.Target.resource(.init(unchecked: "/c1"))
            HTTP.Content(HTTP.Message.Content.Text())
        }
        HTTP.Route.Case(\.c2) {
            HTTP.Method.post
            HTTP.Target.resource(.init(unchecked: "/c2"))
            HTTP.Content(HTTP.Message.Content.Text())
        }
        HTTP.Route.Case(\.c3) {
            HTTP.Method.post
            HTTP.Target.resource(.init(unchecked: "/c3"))
            HTTP.Content(HTTP.Message.Content.Text())
        }
        HTTP.Route.Case(\.c4) {
            HTTP.Method.post
            HTTP.Target.resource(.init(unchecked: "/c4"))
            HTTP.Content(HTTP.Message.Content.Text())
        }
        HTTP.Route.Case(\.c5) {
            HTTP.Method.post
            HTTP.Target.resource(.init(unchecked: "/c5"))
            HTTP.Content(HTTP.Message.Content.Text())
        }
        HTTP.Route.Case(\.c6) {
            HTTP.Method.post
            HTTP.Target.resource(.init(unchecked: "/c6"))
            HTTP.Content(HTTP.Message.Content.Text())
        }
        HTTP.Route.Case(\.c7) {
            HTTP.Method.post
            HTTP.Target.resource(.init(unchecked: "/c7"))
            HTTP.Content(HTTP.Message.Content.Text())
        }
        HTTP.Route.Case(\.c8) {
            HTTP.Method.post
            HTTP.Target.resource(.init(unchecked: "/c8"))
            HTTP.Content(HTTP.Message.Content.Text())
        }
        HTTP.Route.Case(\.c9) {
            HTTP.Method.post
            HTTP.Target.resource(.init(unchecked: "/c9"))
            HTTP.Content(HTTP.Message.Content.Text())
        }
        HTTP.Route.Case(\.c10) {
            HTTP.Method.post
            HTTP.Target.resource(.init(unchecked: "/c10"))
            HTTP.Content(HTTP.Message.Content.Text())
        }
        HTTP.Route.Case(\.c11) {
            HTTP.Method.post
            HTTP.Target.resource(.init(unchecked: "/c11"))
            HTTP.Content(HTTP.Message.Content.Text())
        }
        HTTP.Route.Case(\.c12) {
            HTTP.Method.post
            HTTP.Target.resource(.init(unchecked: "/c12"))
            HTTP.Content(HTTP.Message.Content.Text())
        }
        HTTP.Route.Case(\.c13) {
            HTTP.Method.post
            HTTP.Target.resource(.init(unchecked: "/c13"))
            HTTP.Content(HTTP.Message.Content.Text())
        }
        HTTP.Route.Case(\.c14) {
            HTTP.Method.post
            HTTP.Target.resource(.init(unchecked: "/c14"))
            HTTP.Content(HTTP.Message.Content.Text())
        }
        HTTP.Route.Case(\.c15) {
            HTTP.Method.post
            HTTP.Target.resource(.init(unchecked: "/c15"))
            HTTP.Content(HTTP.Message.Content.Text())
        }
        HTTP.Route.Case(\.c16) {
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

    typealias Input = Byte.Input
    typealias Output = String
    typealias Buffer = [Byte]
    typealias Failure = Error

    func parse(_ input: inout Byte.Input) throws(Error) -> String {
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
            try HTTP.Route.Case<Root.Call, Root.Call.Branch.Ping, HTTP.Method>(\.ping) { HTTP.Method.get }
                .serialize(.middle(.leaf(.op("x"))), into: &buffer)
        }
        #expect(buffer == HTTP.Route.Request.blank)
    }

    @Test
    func `a three-level domain routes through nested cases`() throws {
        let deep = Root.Call.middle(.leaf(.op("deep")))
        let request = try HTTP.request(Root.self, for: deep)
        #expect(request.method == .put)
        #expect(request.target == .resource(.init(unchecked: "/leaf")))
        #expect(request.content == utf8("deep"))
        #expect(try HTTP.route(Root.self, request) == deep)

        let ping = try HTTP.request(Root.self, for: .ping)
        #expect(ping.method == .get)
        #expect(ping.content == nil)
        #expect(try HTTP.route(Root.self, ping) == .ping)

        var extra = ping
        extra.content = utf8("noise")
        #expect(throws: HTTP.Route.Error.malformed) {
            try HTTP.route(Root.self, extra)
        }
    }

    @Test
    func `sixteen request routes type-check as one committed choice`() throws {
        for call in [Wide.Call.c1("a"), .c9("i"), .c16("p")] {
            let request = try HTTP.request(Wide.self, for: call)
            #expect(try HTTP.route(Wide.self, request) == call)
        }
        let unknown = HTTP.Route.Request(method: .post, target: .resource(.init(unchecked: "/c17")))
        #expect(throws: HTTP.Route.Error.mismatch) {
            try HTTP.route(Wide.self, unknown)
        }
    }
}
