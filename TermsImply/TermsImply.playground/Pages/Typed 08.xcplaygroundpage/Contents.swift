//: [Previous](@previous)

typealias Identifier = String

enum Error : Swift.Error {
    case undefinedValue(identifier: Identifier)
    case unboundVariable(Identifier)
    case mismatchedFunctionArguments(received: [LCType], expected: [LCType])
    case mismatchedBranchTypes(LCType, LCType)
    case invalidZeroPredicate(Value)
    case applicationOfNonFunction(LCType)
    case application(ofArgument: LCType, expected: LCType)
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

    func setting(value: LCType, for identifier: Identifier) -> Environment {
        var newLookup = lookup
        newLookup[identifier] = value
        return Environment(lookup: newLookup)
    }


    func typeEvaluate(_ term: Term) throws -> LCType {
        switch term {
        case .integer:
            return .integer
        case .variable(let identifier):
            guard let value = lookup[identifier] else { throw Error.undefinedValue(identifier: identifier) }
            return value
        case .add(let lhs, let rhs):
            return try typeEvaluateClosedBinaryIntegerOp(lhs: lhs, rhs: rhs)
        case .ifIsZero(let predicate, let thenTerm, let elseTerm):
            return try typeEvaluateIfIsZero(predicate: predicate, then: thenTerm, else: elseTerm)
        case .lambda(let body, let type, let argument):
            return try .closure(type, setting(value: type, for: body).typeEvaluate(argument))
        case .application(let e1, let argument):
            return try typeEvaluateApplication(body: e1, argument: argument)
        }
    }

    private func typeEvaluateClosedBinaryIntegerOp(lhs: Term, rhs: Term) throws -> LCType {
        let left = try typeEvaluate(lhs)
        let right = try typeEvaluate(rhs)
        switch (left, right) {
        case (.integer, .integer):
            return .integer
        case (.integer, _), (.closure, _):
            throw Error.mismatchedFunctionArguments(received: [left, right], expected: [.integer, .integer])
        }
    }

    private func typeEvaluateIfIsZero(predicate: Term, then thenTerm: Term, else elseTerm: Term) throws -> LCType {
        let v1 = try typeEvaluate(predicate)
        let thenType = try typeEvaluate(thenTerm)
        let elseType = try typeEvaluate(elseTerm)
        switch (v1, thenType == elseType) {
        case (.integer, true):
            return thenType
        case (.integer, _), (.closure, _):
            throw Error.mismatchedBranchTypes(thenType, elseType)
        }
    }

    // teval env (A e1 e2) =
    //     let t1 = teval env e1
    //         t2 = teval env e2
    //     in case t1 of
    //        t1a :> t1r | t1a == t2 -> t1r
    //        t1a :> t1r -> error $
    //                      unwords ["Applying a function of arg type",
    //                               show t1a, "to argument of type",
    //                               show t2]
    //        t1 -> error $ "Trying to apply a non-function: " ++ show t1
    private func typeEvaluateApplication(body: Term, argument: Term) throws -> LCType {
        let t1 = try typeEvaluate(body)
        let t2 = try typeEvaluate(argument)
        switch t1 {
        case .closure(let left, let right) where left == t2:
            return right
        case .integer:
            throw Error.applicationOfNonFunction(t1)
        case .closure(let left, _):
            throw Error.application(ofArgument: t2, expected: left)
        }
    }
}

extension LCType : Equatable {
    public static func ==(lhs: LCType, rhs: LCType) -> Bool {
        switch (lhs, rhs) {
        case (.integer, .integer):
            return true
        case (let .closure(left), let .closure(right)):
            return left == right
        case (.integer, _), (.closure, _):
            return false
        }
    }
}

//: [Next](@next)
