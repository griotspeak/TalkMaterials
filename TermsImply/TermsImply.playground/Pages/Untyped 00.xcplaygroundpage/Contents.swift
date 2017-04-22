//: [Previous](@previous)

// Content for Lambda! Lambda Everywhere: Terms Imply, You Infer
// given by @griotspeak at CocoaConf
//: A derivative work of [Interpreting types as abstract values by Oleg Kiselyov & Chung-chieh Shan](http://okmij.org/ftp/Computation/FLOLAC/lecture.pdf)


typealias Identifier = String

/// type VarName = String
/// `data Term = V VarName
///     | L VarName Term
///     | A Term Term
///     | I Int
///     | Term :+ Term
///     | IFZ Term Term Term
/// deriving (Show, Eq)`

enum Term {
    case variable(Identifier)
    indirect case lambda(varName: Identifier, body: Term)
    indirect case application(Term, argument: Term)
    case integer(Int)
    indirect case add(Term, Term)
    indirect case ifIsZero(predicate: Term, then: Term, else: Term)

    static func + (lhs: Term, rhs: Term) -> Term {
        return .add(lhs, rhs)
    }
}

//: [Next](@next)
