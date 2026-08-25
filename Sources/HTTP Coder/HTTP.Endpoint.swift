public import Coder_Primitive
public import HTTP

extension HTTP {

    public struct Endpoint<RequestCoder, ResponseCoder>
    where
        RequestCoder: Coder.`Protocol`,
        RequestCoder.Input == HTTP.Request?,
        RequestCoder.Buffer == HTTP.Request?,
        RequestCoder.Failure == HTTP.Coding.Error,
        ResponseCoder: Coder.`Protocol`,
        ResponseCoder.Input == HTTP.Response?,
        ResponseCoder.Buffer == HTTP.Response?,
        ResponseCoder.Failure == HTTP.Coding.Error
    {

        public let request: RequestCoder

        public let response: ResponseCoder

        public init(request: RequestCoder, response: ResponseCoder) {
            self.request = request
            self.response = response
        }
    }
}
