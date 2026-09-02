public import Call_Algebra
public import Client
public import Either
public import HTTP
import Optic
import Parser
public import RFC_9110

extension HTTP {

    public static func client<Domain, Failure: Swift.Error>(
        _: Domain.Type,
        transport: HTTP.Client<Failure>
    ) -> Client::Client<
        Domain.Call.Operation.Input,
        Domain.Call.Operation.Output,
        Either<Either<Failure, HTTP.Route.Error>, Domain.Call.Operation.Failure>
    >
    where
        Domain: HTTP.Routable & HTTP.Respondable,
        Domain.Call: Call_Algebra.Call.Singleton
    {
        .init(
            run: { input throws(Either<Either<Failure, HTTP.Route.Error>, Domain.Call.Operation.Failure>) in
                let request: HTTP.Route.Request
                do throws(HTTP.Route.Error) {
                    request = try HTTP.request(Domain.self, for: Domain.Call.value.embed(input))
                } catch {
                    throw .left(.right(error))
                }

                let received: HTTP.Route.Response
                do throws(Failure) {
                    received = try await transport(request)
                } catch {
                    throw .left(.left(error))
                }

                let result: Swift.Result<Domain.Call.Operation.Output, Domain.Call.Operation.Failure>
                do throws(HTTP.Route.Error) {
                    var input = received
                    result = try Domain.response.parse(&input)
                    guard input.content == nil else {
                        throw .malformed
                    }
                } catch {
                    throw .left(.right(error))
                }

                switch result {
                case .success(let output):
                    return output
                case .failure(let refusal):
                    throw .right(refusal)
                }
            }
        )
    }
}
