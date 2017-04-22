//: [Previous](@previous)

typealias Identifier = String

enum Error : Swift.Error {
    case undefinedValue(identifier: Identifier)
    case unboundVariable(Identifier)
    case mismatchedFunctionArguments(received: [LCType], expected: [LCType])
    case invalidZeroPredicate(Value)
    case applicationOfNonFunction(Value)
}

enum Term {
    case variable(name: Identifier)
    // | L VarName Typ Term
    indirect case lambda(varName: Identifier, type: LCType, body: Term)
    indirect case application(Term, argument: Term)

    case integer(Int)

    indirect case add(Term, Term)
    indirect case ifIsZero(predicate: Term, then: Term, else: Term)

    public init(_ identifier: Identifier) {
        self = .variable(name: identifier)
    }

    static func + (lhs: Term, rhs: Term) -> Term {
        return .add(lhs, rhs)
    }

    init(integerLiteral value: Int) {
        self = .integer(value)
    }
}

enum Value : ExpressibleByIntegerLiteral, CustomStringConvertible {
    typealias RawClosure = (Value) throws -> Value
    case integer(Int)
    case closure(RawClosure)

    init(integerLiteral value: Int) {
        self = .integer(value)
    }

    var description: String {
        switch self {
        case .integer(let value):
            return value.description
        case .closure:
            return "(Closure)"
        }
    }
}

enum LCType {
    case integer
    indirect case closure(LCType, LCType)
}

public struct Environment {
    var lookup: [Identifier:LCType]

    init() {
        self.init(lookup: [:])
    }

    init(lookup: [Identifier:LCType]) {
        self.lookup = lookup
    }

    func typeEvaluate(_ term: Term) throws -> LCType {
        switch term {
        // teval env (I n) = TInt
        case .integer:
            return .integer
        default:
            fatalError()
        }
    }
}

//: [Next](@next)
