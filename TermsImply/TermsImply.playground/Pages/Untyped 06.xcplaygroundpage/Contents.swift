//: [Previous](@previous)

//        // TJ: Should not fail but… this fake laziness doesn't cut it.
//        // tmul1 = L "x" (L "y"
//        //     (IFZ vx (I 0)
//        //     ((tmul1 ‘A‘ (vx :+ (I (-1))) ‘A‘ vy) :+ vy)))
//
//        let tmul1: UntypedLC.Term!
//
//        func wrapTMul1() -> UntypedLC.Term {
//            return .lambda(varName: x, body: .lambda(varName: y,
//                                                     body: .ifIsZero(predicate: "x", then: 0,
//                                                                     else: ((Term.deferred(wrapTMul1)↔︎("x" + -1))↔︎"y") + "y")))
//        }
//
//        tmul1 = wrapTMul1()
//
//        // testm1 = eval env0 (tmul1 ‘A‘ (I 2) ‘A‘ (I 3))
//        if case .some(.integer(9)) = try? environment.evaluate(tmul1↔︎2↔︎3) {
//            XCTAssertTrue(true)
//        } else {
//            XCTFail()
//        }


//        tmul = termY ‘A‘ (L "self" (L "x" (L "y"
//            (IFZ vx (I 0)
//            (((V "self") ‘A‘ (vx :+ (I (-1))) ‘A‘ vy) :+ vy)))))

//: [Next](@next)
