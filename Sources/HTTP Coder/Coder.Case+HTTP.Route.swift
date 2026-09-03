public import Coder
public import HTTP
public import RFC_9110
public import Optic_Coder
public import Parser
public import Serializer

extension Coder.Case: HTTP.Route.`Protocol`
where
    Input: HTTP.Message.`Protocol`,
    Source: ~Copyable,
    Focus: ~Copyable,
    Content.Buffer == Input,
    Content.Failure == HTTP.Route.Error
{
    public typealias Message = Input

    public typealias Operations = Never
}
