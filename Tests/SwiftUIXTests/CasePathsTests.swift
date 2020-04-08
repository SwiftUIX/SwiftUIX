import XCTest
import SwiftUIX

final class CasePathsTests: XCTestCase {
  func testEmbed() {
    enum Foo: Equatable { case bar(Int) }

    XCTAssertEqual(.bar(42), (/Foo.bar).embed(42))
    XCTAssertEqual(.bar(42), (/Foo.self).embed(Foo.bar(42)))
  }

  func testNestedEmbed() {
    enum Foo: Equatable { case bar(Bar) }
    enum Bar: Equatable { case baz(Int) }

    XCTAssertEqual(.bar(.baz(42)), (/Foo.bar..Bar.baz).embed(42))
  }

  func testVoidCasePath() {
    enum Foo: Equatable { case bar }

    XCTAssertEqual(.bar, (/Foo.bar).embed(()))
  }

  func testCasePaths() {
    XCTAssertEqual(
      .some("Hello"),
      (/String?.some)
        .extract(from: "Hello")
    )
    XCTAssertNil(
      (/String?.some)
        .extract(from: .none)
    )

    XCTAssertEqual(
      .some("Hello"),
      (/Result<String, Error>.success)
        .extract(from: .success("Hello"))
    )
    XCTAssertNil(
      (/Result<String, Error>.failure)
        .extract(from: .success("Hello"))
    )

    struct MyError: Equatable, Error {}

    XCTAssertEqual(
      .some(MyError()),
      (/Result<String, Error>.failure)
        .extract(from: .failure(MyError()))
    )
    XCTAssertNil(
      (/Result<String, Error>.success)
        .extract(from: .failure(MyError()))
    )
  }

  func testIdentity() {
    XCTAssertEqual(
      .some(42),
      (/Int.self)
        .extract(from: 42)
    )

    XCTAssertEqual(
      .some(42),
      (/{ $0 })
        .extract(from: 42)
    )
  }

  func testLabeledCases() {
    enum Foo: Equatable {
      case bar(some: Int)
      case bar(none: Int)
    }

    XCTAssertEqual(
      .some(42),
      (/Foo.bar(some:))
        .extract(from: .bar(some: 42))
    )
    XCTAssertNil(
      (/Foo.bar(some:))
        .extract(from: .bar(none: 42))
    )

    XCTAssertEqual(
      .some(42),
//      (/Foo.bar(none:)) // Abort trap: 6
      CasePath.case { Foo.bar(none: $0) }
        .extract(from: .bar(none: 42))
    )
    XCTAssertNil(
//      (/Foo.bar(none:)) // Abort trap: 6
      CasePath.case { Foo.bar(none: $0) }
        .extract(from: .bar(some: 42))
    )
  }

  func testMultiCases() {
    enum Foo {
      case bar(Int, String)
    }

    guard let fizzBuzz = (/Foo.bar)
      .extract(from: .bar(42, "Blob"))
      else {
        XCTFail()
        return
    }
    XCTAssertEqual(42, fizzBuzz.0)
    XCTAssertEqual("Blob", fizzBuzz.1)
  }

  func testMultiLabeledCases() {
    enum Foo {
      case bar(fizz: Int, buzz: String)
    }

    guard let fizzBuzz = CasePath<Foo, (fizz: Int, buzz: String)>.case(Foo.bar)
      .extract(from: .bar(fizz: 42, buzz: "Blob"))
      else {
        XCTFail()
        return
    }
    XCTAssertEqual(42, fizzBuzz.fizz)
    XCTAssertEqual("Blob", fizzBuzz.buzz)
  }

  func testSingleValueExtractionFromMultiple() {
    enum Foo {
      case bar(fizz: Int, buzz: String)
    }

    XCTAssertEqual(
      .some(42),
      extract(case: { Foo.bar(fizz: $0, buzz: "Blob") }, from: .bar(fizz: 42, buzz: "Blob"))
    )
  }

  func testMultiMixedCases() {
    enum Foo {
      case bar(Int, buzz: String)
    }

    guard let fizzBuzz = (/Foo.bar)
      .extract(from: .bar(42, buzz: "Blob"))
      else {
        XCTFail()
        return
    }
    XCTAssertEqual(42, fizzBuzz.0)
    XCTAssertEqual("Blob", fizzBuzz.1)
  }

  func testNestedReflection() {
    enum Foo {
      case bar(Bar)
    }
    enum Bar {
      case baz(Int)
    }

    XCTAssertEqual(
      42,
      extract(case: { Foo.bar(.baz($0)) }, from: .bar(.baz(42)))
    )
  }

  func testNestedZeroMemoryLayout() {
    enum Foo {
      case bar(Bar)
    }
    enum Bar: Equatable {
      case baz
    }

    XCTAssertEqual(
      .baz,
      (/Foo.bar)
        .extract(from: .bar(.baz))
    )
  }
  
  func testEnumsWithoutAssociatedValues() {
    enum Foo: Equatable {
      case bar
      case baz
    }
    
    XCTAssertNotNil(
      (/Foo.bar)
        .extract(from: .bar)
    )
    XCTAssertNil(
      (/Foo.bar)
        .extract(from: .baz)
    )

    XCTAssertNotNil(
      (/Foo.baz)
        .extract(from: .baz)
    )
    XCTAssertNil(
      (/Foo.baz)
        .extract(from: .bar)
    )

    XCTAssertNotNil(
      extract(case: { Foo.bar }, from: .bar)
    )
    XCTAssertNil(
      extract(case: { Foo.bar }, from: .baz)
    )
    
    XCTAssertNotNil(
      extract(case: { Foo.baz }, from: .baz)
    )
    XCTAssertNil(
      extract(case: { Foo.baz }, from: .bar)
    )
  }

  func testEnumsWithClosures() {
    enum Foo {
      case bar(() -> Void)
    }

    var didRun = false
    guard let bar = (/Foo.bar)
      .extract(from: .bar { didRun = true })
      else {
        XCTFail()
        return
    }
    bar()
    XCTAssertTrue(didRun)
  }

  func testRecursive() {
    indirect enum Foo {
      case foo(Foo)
      case bar(Int)
    }

    XCTAssertEqual(
      .some(42),
      extract(case: { Foo.foo(.foo(.foo(.bar($0)))) }, from: .foo(.foo(.foo(.bar(42)))))
    )
    XCTAssertNil(
      extract(case: { Foo.foo(.foo(.foo(.bar($0)))) }, from: .foo(.foo(.bar(42))))
    )
  }

  func testExtract() {
    struct MyError: Error {}

    XCTAssertEqual(
      [1],
      [Result.success(1), .success(nil), .failure(MyError())]
        .compactMap(/Result.success..Optional.some)
    )

    XCTAssertEqual(
      [1],
      [Result.success(1), .success(nil), .failure(MyError())]
        .compactMap(/{ .success(.some($0)) })
    )

    enum Authentication {
      case authenticated(token: String)
      case unauthenticated
    }

    XCTAssertEqual(
      ["deadbeef"],
      [Authentication.authenticated(token: "deadbeef"), .unauthenticated]
        .compactMap(/Authentication.authenticated)
    )

    XCTAssertEqual(
      1,
      [Authentication.authenticated(token: "deadbeef"), .unauthenticated]
        .compactMap(/Authentication.unauthenticated)
        .count
    )
  }

  func testAppending() {
    XCTAssertEqual(
      .some(42),
      (/Result<Int?, Error>.success .. /Int?.some)
        .extract(from: .success(.some(42)))
    )
  }

  func testExample() {
    XCTAssertEqual("Blob", extract(case: Result<String, Error>.success, from: .success("Blob")))
    XCTAssertNil(extract(case: Result<String, Error>.failure, from: .success("Blob")))

    XCTAssertEqual(42, (/Int??.some..Int?.some).extract(from: Optional(Optional(42))))
  }

  func testConstantCasePath() {
    XCTAssertEqual(.some(42), CasePath.constant(42).extract(from: ()))
    XCTAssertNotNil(CasePath.constant(42).embed(42))
  }

  func testNeverCasePath() {
    XCTAssertNil(CasePath.never.extract(from: 42))
  }

  func testRawValuePath() {
    enum Foo: String { case bar, baz }

    XCTAssertEqual(.some(.bar), CasePath<String, Foo>.rawValue.extract(from: "bar"))
    XCTAssertEqual("baz", CasePath.rawValue.embed(Foo.baz))
  }

  func testDescriptionPath() {
    XCTAssertEqual(.some(42), CasePath.description.extract(from: "42"))
    XCTAssertEqual("42", CasePath.description.embed(42))
  }

  func testA() {
    enum EnumWithLabeledCase {
      case labeled(label: Int, otherLabel: Int)
      case labeled(Int, Int)
    }
    XCTAssertNil((/EnumWithLabeledCase.labeled(label:otherLabel:)).extract(from: .labeled(2, 2)))
    XCTAssertNotNil((/EnumWithLabeledCase.labeled(label:otherLabel:)).extract(from: .labeled(label: 2, otherLabel: 2)))
  }

//  func testStructs() {
//    struct Point { var x: Double, y: Double }
//
//    guard
//      let (x, y) = CasePath(Point.init(x:y:))
//        .extract(from: Point(x: 16, y: 8))
//      else {
//        XCTFail()
//        return
//    }
//
//    XCTAssertEqual(16, x)
//    XCTAssertEqual(8, y)
//
//    guard
//      let (x1, y2) = CasePath(Point.init(what:where:))
//        .extract(from: Point(x: 16, y: 8))
//      else {
//        XCTFail()
//        return
//    }
//  }
}
