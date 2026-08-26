public import Coder_Primitive
public import HTTP
public import Parser_Conversion_Primitives
public import Parser_Primitive
public import Serializer_Primitive

extension HTTP.Route.Query {

    /// Binds one named query field through a bidirectional conversion.
    ///
    /// A field that is absent, valueless, or inadmissible to the conversion is
    /// `noMatch`, not `malformed`: a query field is a routing discriminator, so
    /// a sibling branch must still get its turn.
    public struct Field<Conversion: Parser.Conversion.`Protocol`>
    where Conversion.Input == String {

        public let name: String

        public let conversion: Conversion

        public init(_ name: String, _ conversion: Conversion) {
            self.name = name
            self.conversion = conversion
        }
    }
}

extension HTTP.Route.Query.Field: Coder.`Protocol` {

    public typealias Input = HTTP.Route.Input
    public typealias Output = Conversion.Output
    public typealias Buffer = HTTP.Route.Input
    public typealias Failure = HTTP.Route.Error
    public typealias Body = Never

    public borrowing func parse(
        _ input: inout HTTP.Route.Input
    ) throws(HTTP.Route.Error) -> Conversion.Output {
        let name = self.name
        guard let index = input.query.firstIndex(where: { $0.name == name }) else {
            throw .noMatch
        }
        guard let value = input.query[index].value else {
            throw .noMatch
        }
        let output: Conversion.Output
        do {
            output = try conversion.apply(value)
        } catch {
            throw .noMatch
        }
        input.query.remove(at: index)
        return output
    }

    public borrowing func serialize(
        _ output: Conversion.Output,
        into buffer: inout HTTP.Route.Input
    ) throws(HTTP.Route.Error) {
        let value: String
        do {
            value = try conversion.unapply(output)
        } catch {
            throw .unprintable
        }
        buffer.query.append(.init(name: name, value: value))
    }
}
