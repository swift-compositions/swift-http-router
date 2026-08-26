import Byte_Primitive
import Coder_Primitive
import Either_Primitives
import HTTP
import HTTP_Coder
import Parser_Primitive
import RFC_3986
import Serializer_Primitive
import Testing

@Test
func `malformed UTF-8 is rejected`() {
    let coder = HTTP.Coding.Body.Text<String>(
        decode: { $0 },
        encode: { $0 }
    )
    var body: [Byte]? = [Byte(0xFF)]

    #expect(throws: HTTP.Coding.Body.Error.invalid) {
        _ = try coder.parse(&body)
    }
    #expect(body != nil)
}

@Test
func `structural coders reject unconsumed bodies without consuming their input`() {
    let requestCoder = HTTP.Coding.Request(
        method: .post,
        target: .origin(path: ["value"], query: nil),
        content: UnconsumingBody()
    )
    var request = Optional(
        HTTP.Request(
            method: .post,
            target: .origin(path: ["value"], query: nil),
            body: [Byte(1)]
        )
    )
    let originalRequest = request
    #expect(throws: HTTP.Coding.Error.request) {
        _ = try requestCoder.parse(&request)
    }
    #expect(request == originalRequest)

    let responseCoder = HTTP.Coding.Response.Success(
        status: .ok,
        content: UnconsumingBody()
    )
    var response = Optional(HTTP.Response(status: .ok, body: [Byte(1)]))
    let originalResponse = response
    #expect(throws: HTTP.Coding.Error.response) {
        _ = try responseCoder.parse(&response)
    }
    #expect(response == originalResponse)

    let choiceCoder = HTTP.Coding.Response.Choice(
        refusalStatus: .badRequest,
        refusal: UnconsumingBody(),
        successStatus: .ok,
        success: UnconsumingBody()
    )
    var choiceResponse = Optional(HTTP.Response(status: .ok, body: [Byte(1)]))
    let originalChoiceResponse = choiceResponse
    #expect(throws: HTTP.Coding.Error.response) {
        _ = try choiceCoder.parse(&choiceResponse)
    }
    #expect(choiceResponse == originalChoiceResponse)
}

@Test
func `a declarative request coder round trips`() throws {
    let content = HTTP.Coding.Body.Text<String>(
        decode: { $0 },
        encode: { $0 }
    )
    let coder = HTTP.Coding.Request(
        method: .post,
        target: .origin(path: ["value"], query: nil),
        content: content
    )

    var request: HTTP.Request?
    try coder.serialize("hello", into: &request)
    let canonical = request
    let value = try coder.parse(&request)
    #expect(value == "hello")
    #expect(request == nil)

    var serialized: HTTP.Request?
    try coder.serialize(value, into: &serialized)
    #expect(serialized == canonical)
}

@Test
func `a declarative success response round trips the Never row`() throws {
    let content = HTTP.Coding.Body.Text<Int>(
        decode: { text throws(HTTP.Coding.Body.Error) in
            guard let value = Int(text) else {
                throw .invalid
            }
            return value
        },
        encode: { String($0) }
    )
    let coder = HTTP.Coding.Response.Success(status: .ok, content: content)

    var response: HTTP.Response?
    try coder.serialize(Either<Swift.Never, Int>.right(7), into: &response)
    let canonical = response
    let value = try coder.parse(&response)
    #expect(value.value == 7)
    #expect(response == nil)

    var serialized: HTTP.Response?
    try coder.serialize(value, into: &serialized)
    #expect(serialized == canonical)
}

@Test
func `a declarative response choice round trips both branches`() throws {
    let refusal = HTTP.Coding.Body.Text<String>(
        decode: { $0 },
        encode: { $0 }
    )
    let success = HTTP.Coding.Body.Text<Int>(
        decode: { text throws(HTTP.Coding.Body.Error) in
            guard let value = Int(text) else {
                throw .invalid
            }
            return value
        },
        encode: { String($0) }
    )
    let coder = HTTP.Coding.Response.Choice(
        refusalStatus: .badRequest,
        refusal: refusal,
        successStatus: .ok,
        success: success
    )

    var refusalResponse: HTTP.Response?
    try coder.serialize(Either<String, Int>.left("limit"), into: &refusalResponse)
    let canonicalRefusal = refusalResponse
    let refusalValue = try coder.parse(&refusalResponse)
    #expect(refusalValue == .left("limit"))

    var serializedRefusal: HTTP.Response?
    try coder.serialize(refusalValue, into: &serializedRefusal)
    #expect(serializedRefusal == canonicalRefusal)

    var successResponse: HTTP.Response?
    try coder.serialize(Either<String, Int>.right(7), into: &successResponse)
    let canonicalSuccess = successResponse
    let successValue = try coder.parse(&successResponse)
    #expect(successValue == .right(7))

    var serializedSuccess: HTTP.Response?
    try coder.serialize(successValue, into: &serializedSuccess)
    #expect(serializedSuccess == canonicalSuccess)
}
