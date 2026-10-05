import Byte
import Case_Macro
import Coder
import HTTP
import HTTP_Router
import RFC_3986
import RFC_9110
import Tagged
import Testing

struct Note: Codable, Equatable, Sendable {
    var title: String
}

@Prisms
@Folds
@Cases
enum Notes: Equatable, Sendable {
    case text(String)
    case note(Note)
}

extension Notes: HTTP.Routable {

    static var router: some HTTP.Router.`Protocol`<Notes> {
        Coder::Case(Notes.cases.text.prism, Notes.cases.text.fold, absent: .mismatch) {
            .post
            HTTP.Segment("text")
            HTTP.Segment.End()
            HTTP.Body.Coded(UTF8Text())
        }
        #if Foundation
            Coder::Case(Notes.cases.note.prism, Notes.cases.note.fold, absent: .mismatch) {
                .post
                HTTP.Segment("note")
                HTTP.Segment.End()
                HTTP.Body.Coded(HTTP.Body.JSON<Note>())
            }
        #endif
    }
}

@Suite
struct `HTTP.Body.Coded Tests` {

    @Test
    func `a coded body round-trips bytes and content type`() throws {
        let request = try HTTP.request(Notes.self, for: .text("héllo"))
        #expect(request.content == bytes("héllo"))
        #expect(request.headers[.contentType].map(\.rawValue) == [UTF8Text.contentType.value])
        #expect(try HTTP.route(Notes.self, request) == .text("héllo"))
    }

    @Test
    func `a body of another media type is a mismatch`() throws {
        var request = try HTTP.request(Notes.self, for: .text("x"))
        request.headers.remove(.contentType)
        request.headers.append(RFC_9110.Field(name: .contentType, value: .init(unchecked: "image/png")))
        #expect(throws: HTTP.Router.Error.mismatch) {
            try HTTP.route(Notes.self, request)
        }
    }

    @Test
    func `a missing body is a mismatch, so an alternative can match`() throws {
        var request = try HTTP.request(Notes.self, for: .text("x"))
        request.content = nil
        #expect(throws: HTTP.Router.Error.mismatch) {
            try HTTP.route(Notes.self, request)
        }
    }

    #if Foundation
        @Test
        func `a JSON body round-trips bytes and content type`() throws {
            let note = Note(title: "a")
            let request = try HTTP.request(Notes.self, for: .note(note))
            #expect(request.headers[.contentType].map(\.rawValue) == ["application/json"])
            #expect(request.content == bytes(#"{"title":"a"}"#))
            #expect(try HTTP.route(Notes.self, request) == .note(note))
        }

        @Test
        func `a malformed JSON body is malformed`() throws {
            var request = try HTTP.request(Notes.self, for: .note(Note(title: "a")))
            request.content = bytes("{\"title\":")
            #expect(throws: HTTP.Router.Error.malformed) {
                try HTTP.route(Notes.self, request)
            }
        }
    #endif
}
