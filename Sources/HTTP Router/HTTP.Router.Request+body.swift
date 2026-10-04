public import Byte
public import HTTP
public import RFC_9110

extension HTTP.Message.Request where Content == [Byte] {

    public mutating func body<C: HTTP.Body.Coder.`Protocol`>(
        set value: C.Output,
        using coder: C
    ) throws(C.Failure) {
        var bytes: [Byte] = []
        let mediaType = try coder.encode(value, into: &bytes)
        headers.remove(.contentType)
        headers.append(RFC_9110.Field(name: .contentType, value: .init(unchecked: mediaType.value)))
        content = bytes
    }
}
