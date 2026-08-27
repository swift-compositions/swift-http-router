import Byte_Primitive
import Coder_Primitive
import HTTP
import HTTP_Coder
import Testing

@Suite
struct `HTTP.Representation Tests` {
    @Test
    func `representation is bidirectional`() throws {
        let coder = HTTP.Representation(.ok, HTTP.Message.Content.Text())
        var response: HTTP.Message.Response<[Byte]>?

        try coder.serialize("hello", into: &response)
        #expect(response?.status == .ok)

        #expect(try coder.parse(&response) == "hello")
        #expect(response == nil)
    }
}
