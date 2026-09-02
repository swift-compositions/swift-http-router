public import Call_Algebra
public import Client
public import HTTP
public import RFC_9110
import Serializer

extension HTTP {

    public static func response<Domain: HTTP.Respondable>(
        _: Domain.Type,
        to input: Domain.Call.Operation.Input,
        using client: Client::Client<
            Domain.Call.Operation.Input,
            Domain.Call.Operation.Output,
            Domain.Call.Operation.Failure
        >
    ) async throws(HTTP.Route.Error) -> HTTP.Route.Response {
        let result: Swift.Result<Domain.Call.Operation.Output, Domain.Call.Operation.Failure>
        do throws(Domain.Call.Operation.Failure) {
            result = .success(try await client(input))
        } catch {
            result = .failure(error)
        }
        var buffer = HTTP.Route.Response.blank
        try Domain.response.serialize(result, into: &buffer)
        return buffer
    }
}
