public import Coder_Primitive
public import HTTP
public import Parser_Conversion_Primitives
public import Parser_Primitive
public import Serializer_Primitive

extension HTTP.Route.Path {

    /// Binds one path segment through a bidirectional conversion.
    public struct Capture<Conversion: Parser.Conversion.`Protocol`>
    where Conversion.Input == String {

        public let conversion: Conversion

        public init(_ conversion: Conversion) {
            self.conversion = conversion
        }
    }
}

extension HTTP.Route.Path.Capture: Coder.`Protocol` {

    public typealias Input = HTTP.Route.Input
    public typealias Output = Conversion.Output
    public typealias Buffer = HTTP.Route.Input
    public typealias Failure = HTTP.Route.Error
    public typealias Body = Never

    public borrowing func parse(
        _ input: inout HTTP.Route.Input
    ) throws(HTTP.Route.Error) -> Conversion.Output {
        guard let segment = input.path.first else {
            throw .noMatch
        }
        let output: Conversion.Output
        do {
            output = try conversion.apply(segment)
        } catch {
            throw .malformed
        }
        input.path.removeFirst()
        return output
    }

    public borrowing func serialize(
        _ output: Conversion.Output,
        into buffer: inout HTTP.Route.Input
    ) throws(HTTP.Route.Error) {
        let segment: String
        do {
            segment = try conversion.unapply(output)
        } catch {
            throw .unprintable
        }
        buffer.path.append(segment)
    }
}
