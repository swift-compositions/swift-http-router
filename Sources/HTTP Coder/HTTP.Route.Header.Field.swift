public import Coder_Primitive
public import HTTP
public import Parser_Conversion_Primitives
public import Parser_Primitive
public import Serializer_Primitive

extension HTTP.Route.Header {

    /// Binds one named header field through a bidirectional conversion.
    ///
    /// A field that is absent or inadmissible to the conversion is `noMatch`,
    /// not `malformed`: a header field is a routing discriminator, so a sibling
    /// branch must still get its turn.
    ///
    /// A repeated name is normalized: parsing binds the first value and
    /// consumes every occurrence, and printing emits one field.
    public struct Field<Conversion: Parser.Conversion.`Protocol`>
    where Conversion.Input == String {

        public let name: HTTP.Header.Field.Name

        public let conversion: Conversion

        public init(_ name: HTTP.Header.Field.Name, _ conversion: Conversion) {
            self.name = name
            self.conversion = conversion
        }
    }
}

extension HTTP.Route.Header.Field: Coder.`Protocol` {

    public typealias Input = HTTP.Route.Input
    public typealias Output = Conversion.Output
    public typealias Buffer = HTTP.Route.Input
    public typealias Failure = HTTP.Route.Error
    public typealias Body = Never

    public borrowing func parse(
        _ input: inout HTTP.Route.Input
    ) throws(HTTP.Route.Error) -> Conversion.Output {
        guard let value = input.headers[name]?.first else {
            throw .noMatch
        }
        let output: Conversion.Output
        do {
            output = try conversion.apply(value.rawValue)
        } catch {
            throw .noMatch
        }
        input.headers.removeAll(named: name)
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
        let field: HTTP.Header.Field
        do {
            field = .init(name: name, value: try HTTP.Header.Field.Value(value))
        } catch {
            throw .unprintable
        }
        buffer.headers.append(field)
    }
}
