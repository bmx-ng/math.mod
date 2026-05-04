SuperStrict

Framework brl.standardio
Import BRL.MaxUnit
Import Math.Decimal

New TTestSuite.run()


Type TDecimalBasicTest Extends TTest

	Method TestConstructFromString() { test }
		Local d:TDecimal = Decimal("123.45")
		AssertNotNull(d, "Decimal should be created")
		AssertEquals("123.45", d.ToString(), "Decimal string value should match")
		AssertTrue(d = Decimal("123.45"), "Decimal should compare equal to same value")
	End Method

	Method TestConstructFromInt() { test }
		Local d:TDecimal = Decimal(42)
		AssertEquals("42", d.ToString(), "Integer conversion should produce correct decimal")
		AssertTrue(d = Decimal("42"), "Int and string constructions should match")
	End Method

End Type

Type TDecimalArithmeticTest Extends TTest

	Method TestAddition() { test }
		AssertEquals("5", (Decimal("2") + Decimal("3")).ToString(), "2 + 3 should equal 5")
		AssertEquals("5.75", (Decimal("2.5") + Decimal("3.25")).ToString(), "2.5 + 3.25 should equal 5.75")
		AssertEquals("-1", (Decimal("2") + Decimal("-3")).ToString(), "2 + -3 should equal -1")
	End Method

	Method TestSubtraction() { test }
		AssertEquals("-1", (Decimal("2") - Decimal("3")).ToString(), "2 - 3 should equal -1")
		AssertEquals("4.75", (Decimal("8") - Decimal("3.25")).ToString(), "8 - 3.25 should equal 4.75")
		AssertEquals("5", (Decimal("2") - Decimal("-3")).ToString(), "2 - -3 should equal 5")
	End Method

	Method TestMultiplication() { test }
		AssertEquals("6", (Decimal("2") * Decimal("3")).ToString(), "2 * 3 should equal 6")
		AssertEquals("8.125", (Decimal("2.5") * Decimal("3.25")).ToString(), "2.5 * 3.25 should equal 8.125")
		AssertEquals("-6", (Decimal("2") * Decimal("-3")).ToString(), "2 * -3 should equal -6")
	End Method

	Method TestDivision() { test }
		AssertEquals("2", (Decimal("6") / Decimal("3")).ToString(), "6 / 3 should equal 2")
		AssertEquals("2.5", (Decimal("5") / Decimal("2")).ToString(), "5 / 2 should equal 2.5")
		AssertEquals("-2", (Decimal("6") / Decimal("-3")).ToString(), "6 / -3 should equal -2")
	End Method

	Method TestArithmeticWithInts() { test }
		AssertEquals("5", (Decimal("2") + 3).ToString(), "Decimal + Int should work")
		AssertEquals("-1", (Decimal("2") - 3).ToString(), "Decimal - Int should work")
		AssertEquals("6", (Decimal("2") * 3).ToString(), "Decimal * Int should work")
		AssertEquals("2.5", (Decimal("5") / 2).ToString(), "Decimal / Int should work")
	End Method

	Method TestInPlaceAddition() { test }
		Local d:TDecimal = Decimal("2")
		d :+ Decimal("3")

		AssertEquals("5", d.ToString(), "2 :+ 3 should mutate value to 5")
	End Method

	Method TestInPlaceSubtraction() { test }
		Local d:TDecimal = Decimal("2")
		d :- Decimal("3")

		AssertEquals("-1", d.ToString(), "2 :- 3 should mutate value to -1")
	End Method

	Method TestInPlaceMultiplication() { test }
		Local d:TDecimal = Decimal("2")
		d :* Decimal("3")

		AssertEquals("6", d.ToString(), "2 :* 3 should mutate value to 6")
	End Method

	Method TestInPlaceDivision() { test }
		Local d:TDecimal = Decimal("5")
		d :/ Decimal("2")

		AssertEquals("2.5", d.ToString(), "5 :/ 2 should mutate value to 2.5")
	End Method

	Method TestOriginalValueUnchangedForNormalOperators() { test }
		Local a:TDecimal = Decimal("2")
		Local b:TDecimal = a + Decimal("3")

		AssertEquals("2", a.ToString(), "Normal + should not mutate left-hand value")
		AssertEquals("5", b.ToString(), "Result of 2 + 3 should be 5")
	End Method

End Type

Type TDecimalComparisonTest Extends TTest

	Method TestEquality() { test }
		AssertTrue(Decimal("5") = Decimal("5"), "5 should equal 5")
		AssertTrue(Decimal("5.0") = Decimal("5.00"), "5.0 should equal 5.00")
		AssertFalse(Decimal("5") = Decimal("6"), "5 should not equal 6")
	End Method

	Method TestNotEqual() { test }
		AssertTrue(Decimal("5") <> Decimal("6"), "5 should not equal 6")
		AssertFalse(Decimal("5") <> Decimal("5"), "5 should equal 5")
	End Method

	Method TestLessThan() { test }
		AssertTrue(Decimal("4") < Decimal("5"), "4 should be less than 5")
		AssertTrue(Decimal("-6") < Decimal("-5"), "-6 should be less than -5")
		AssertFalse(Decimal("5") < Decimal("5"), "5 should not be less than 5")
	End Method

	Method TestLessThanOrEqual() { test }
		AssertTrue(Decimal("4") <= Decimal("5"), "4 should be <= 5")
		AssertTrue(Decimal("5") <= Decimal("5"), "5 should be <= 5")
		AssertFalse(Decimal("6") <= Decimal("5"), "6 should not be <= 5")
	End Method

	Method TestGreaterThan() { test }
		AssertTrue(Decimal("6") > Decimal("5"), "6 should be greater than 5")
		AssertTrue(Decimal("-4") > Decimal("-5"), "-4 should be greater than -5")
		AssertFalse(Decimal("5") > Decimal("5"), "5 should not be greater than 5")
	End Method

	Method TestGreaterThanOrEqual() { test }
		AssertTrue(Decimal("6") >= Decimal("5"), "6 should be >= 5")
		AssertTrue(Decimal("5") >= Decimal("5"), "5 should be >= 5")
		AssertFalse(Decimal("4") >= Decimal("5"), "4 should not be >= 5")
	End Method

End Type

Type TDecimalPropertiesTest Extends TTest

	Method TestZero() { test }
		Local d:TDecimal = Decimal("0")
		AssertTrue(d.IsZero(), "0 should be zero")
		AssertTrue(d.IsPositive(), "0 should be positive/non-negative according to libmpdec")
		AssertFalse(d.IsNegative(), "0 should not be negative")
		AssertTrue(d.IsFinite(), "0 should be finite")
	End Method

	Method TestPositiveNegative() { test }
		Local p:TDecimal = Decimal("5")
		Local n:TDecimal = Decimal("-5")

		AssertTrue(p.IsPositive(), "5 should be positive")
		AssertFalse(p.IsNegative(), "5 should not be negative")

		AssertTrue(n.IsNegative(), "-5 should be negative")
		AssertFalse(n.IsPositive(), "-5 should not be positive")
	End Method

	Method TestSignFunctions() { test }
		AssertEquals(0, Decimal("5").Sign(), "Sign flag of positive should be 0")
		AssertEquals(1, Decimal("-5").Sign(), "Sign flag of negative should be 1")
		AssertEquals(0, Decimal("0").Sign(), "Sign flag of positive zero should be 0")
		AssertEquals(1, Decimal("-0").Sign(), "Sign flag of negative zero should be 1")

		AssertEquals(1, Decimal("5").ArithSign(), "Arithmetic sign of positive should be 1")
		AssertEquals(-1, Decimal("-5").ArithSign(), "Arithmetic sign of negative should be -1")
		AssertEquals(1, Decimal("0").ArithSign(), "Arithmetic sign of zero should be 1 according to libmpdec")
		AssertEquals(-1, Decimal("-0").ArithSign(), "Arithmetic sign of negative zero should be -1 according to libmpdec")
	End Method

	Method TestSignedZero() { test }
		Local pz:TDecimal = Decimal("0")
		Local nz:TDecimal = Decimal("-0")
		AssertTrue(pz.IsZero(), "0 should be zero")
		AssertTrue(nz.IsZero(), "-0 should be zero")
		AssertFalse(pz.IsNegative(), "0 should not be negative")
		AssertTrue(nz.IsNegative(), "-0 should be negative")
		AssertTrue(pz.IsPositive(), "0 should be positive/non-negative")
		AssertFalse(nz.IsPositive(), "-0 should not be positive")
	End Method

	Method TestAbs() { test }
		AssertEquals("5", Decimal("5").Abs().ToString(), "Abs(5) = 5")
		AssertEquals("5", Decimal("-5").Abs().ToString(), "Abs(-5) = 5")
	End Method

	Method TestPlusMinus() { test }
		AssertEquals("5", Decimal("5").Plus().ToString(), "+5 should stay 5")
		AssertEquals("-5", Decimal("5").Minus().ToString(), "-5 should be -5")
		AssertEquals("5", Decimal("-5").Minus().ToString(), "-(-5) should be 5")
	End Method

	Method TestIntegerChecks() { test }
		AssertTrue(Decimal("5").IsInteger(), "5 should be integer")
		AssertTrue(Decimal("5.0").IsInteger(), "5.0 should be integer")
		AssertFalse(Decimal("5.1").IsInteger(), "5.1 should not be integer")
	End Method

	Method TestOddEven() { test }
		AssertTrue(Decimal("5").IsOdd(), "5 should be odd")
		AssertFalse(Decimal("5").IsEven(), "5 should not be even")

		AssertTrue(Decimal("6").IsEven(), "6 should be even")
		AssertFalse(Decimal("6").IsOdd(), "6 should not be odd")
	End Method

	Method TestMinMax() { test }
		AssertEquals("3", Decimal("3").Min(Decimal("5")).ToString(), "Min(3,5) = 3")
		AssertEquals("5", Decimal("3").Max(Decimal("5")).ToString(), "Max(3,5) = 5")
	End Method

	Method TestFloorCeilTrunc() { test }
		Local d:TDecimal = Decimal("2.7")

		AssertEquals("2", d.Floor().ToString(), "floor(2.7) = 2")
		AssertEquals("3", d.Ceil().ToString(), "ceil(2.7) = 3")
		AssertEquals("2", d.Trunc().ToString(), "trunc(2.7) = 2")

		Local n:TDecimal = Decimal("-2.7")
		AssertEquals("-3", n.Floor().ToString(), "floor(-2.7) = -3")
		AssertEquals("-2", n.Ceil().ToString(), "ceil(-2.7) = -2")
		AssertEquals("-2", n.Trunc().ToString(), "trunc(-2.7) = -2")
	End Method

End Type

Type TDecimalRoundingTest Extends TTest

	Method TestFloorCeilTruncPositive() { test }
		Local d:TDecimal = Decimal("2.7")

		AssertEquals("2", d.Floor().ToString(), "floor(2.7) should be 2")
		AssertEquals("3", d.Ceil().ToString(), "ceil(2.7) should be 3")
		AssertEquals("2", d.Trunc().ToString(), "trunc(2.7) should be 2")
	End Method

	Method TestFloorCeilTruncNegative() { test }
		Local d:TDecimal = Decimal("-2.7")

		AssertEquals("-3", d.Floor().ToString(), "floor(-2.7) should be -3")
		AssertEquals("-2", d.Ceil().ToString(), "ceil(-2.7) should be -2")
		AssertEquals("-2", d.Trunc().ToString(), "trunc(-2.7) should be -2")
	End Method

	Method TestReduce() { test }
		AssertEquals("1.23", Decimal("1.2300").Reduce().ToString(), "reduce should remove trailing zeros")
		AssertTrue(Decimal("1000.000").Reduce() = Decimal("1000"), "reduce should preserve numeric value")
	End Method

	Method TestSameQuantum() { test }
		AssertTrue(Decimal("1.23").SameQuantum(Decimal("4.56")), "Both values have 2 decimal places")
		AssertFalse(Decimal("1.23").SameQuantum(Decimal("4.5")), "Different exponents should not have same quantum")
		AssertTrue(Decimal("1").SameQuantum(Decimal("4")), "Integers should have same quantum")
	End Method

	Method TestQuantize() { test }
		AssertEquals("1.23", Decimal("1.234").Quantize(Decimal("0.01")).ToString(), "quantize to 2 decimal places")
		AssertEquals("1.2", Decimal("1.234").Quantize(Decimal("0.1")).ToString(), "quantize to 1 decimal place")
		AssertEquals("1", Decimal("1.234").Quantize(Decimal("1")).ToString(), "quantize to integer")
	End Method

	Method TestRescale() { test }
		AssertEquals("1.23", Decimal("1.234").Rescale(-2).ToString(), "rescale to exponent -2")
		AssertEquals("1.2", Decimal("1.234").Rescale(-1).ToString(), "rescale to exponent -1")
		AssertEquals("1", Decimal("1.234").Rescale(0).ToString(), "rescale to exponent 0")
	End Method

End Type

Type TDecimalRemainderTest Extends TTest

	Method TestDivideInteger() { test }
		AssertEquals("2", Decimal("7").DivideInteger(Decimal("3")).ToString(), "7 div 3 should be 2")
		AssertEquals("-2", Decimal("-7").DivideInteger(Decimal("3")).ToString(), "-7 div 3 should truncate toward zero")
		AssertEquals("-2", Decimal("7").DivideInteger(Decimal("-3")).ToString(), "7 div -3 should truncate toward zero")
	End Method

	Method TestRemainder() { test }
		AssertEquals("1", Decimal("7").Remainder(Decimal("3")).ToString(), "7 remainder 3 should be 1")
		AssertEquals("-1", Decimal("-7").Remainder(Decimal("3")).ToString(), "-7 remainder 3 should be -1")
		AssertEquals("1", Decimal("7").Remainder(Decimal("-3")).ToString(), "7 remainder -3 should be 1")
	End Method

	Method TestRemainderNear() { test }
		AssertEquals("-1", Decimal("7").RemainderNear(Decimal("4")).ToString(), "7 remainderNear 4 should be -1")
		AssertEquals("1", Decimal("9").RemainderNear(Decimal("4")).ToString(), "9 remainderNear 4 should be 1")
		AssertEquals("0", Decimal("8").RemainderNear(Decimal("4")).ToString(), "8 remainderNear 4 should be 0")
	End Method

	Method TestRemainderIdentity() { test }
		Local a:TDecimal = Decimal("7")
		Local b:TDecimal = Decimal("3")
		Local q:TDecimal = a.DivideInteger(b)
		Local r:TDecimal = a.Remainder(b)

		AssertTrue((b * q + r) = a, "a should equal b * divideInteger(a,b) + remainder(a,b)")
	End Method

End Type

Type TDecimalAssignmentTest Extends TTest

	Method TestAssignFromDecimalCopiesValue() { test }
		Local a:TDecimal = Decimal("123.45")
		Local b:TDecimal = Decimal("0")

		b = a
		a :+ Decimal("1")

		AssertEquals("123.45", b.ToString(), "Assigned decimal should keep copied value after source changes")
		AssertEquals("124.45", a.ToString(), "Source decimal should mutate independently")
	End Method

	Method TestAssignFromString() { test }
		Local d:TDecimal = Decimal("0")

		d = "99.5"

		AssertEquals("99.5", d.ToString(), "Assignment from string should update value")
	End Method

	Method TestAssignFromInts() { test }
		Local d:TDecimal = Decimal("0")

		d = 42
		AssertEquals("42", d.ToString(), "Assignment from Int should update value")

		d = 42:UInt
		AssertEquals("42", d.ToString(), "Assignment from UInt should update value")

		d = 42:Long
		AssertEquals("42", d.ToString(), "Assignment from Long should update value")

		d = 42:ULong
		AssertEquals("42", d.ToString(), "Assignment from ULong should update value")
	End Method

	Method TestNormalOperatorCreatesIndependentResult() { test }
		Local a:TDecimal = Decimal("10")
		Local b:TDecimal = a + Decimal("5")

		a :+ Decimal("10")
		b :+ Decimal("1")

		AssertEquals("20", a.ToString(), "Source should mutate independently")
		AssertEquals("16", b.ToString(), "Result should mutate independently")
	End Method

	Method TestLargeValueAssignmentCopiesStorage() { test }
		Local a:TDecimal = Decimal("123456789012345678901234567890")
		Local b:TDecimal = Decimal("0")

		b = a
		a = Decimal("999")

		AssertEquals("123456789012345678901234567890", b.ToString(), "Assigned value should not change when source is reassigned")
		AssertEquals("999", a.ToString(), "Source should be reassigned independently")
	End Method

End Type

Type TDecimalStringFormatTest Extends TTest

	Method TestToStringUsesPlainFixedFormat() { test }
		AssertEquals("12345", Decimal("12345").ToString(), "ToString should not use exponent notation")
		AssertEquals("1000", Decimal("1E+3").ToString(), "ToString should expand exponent notation")
		AssertEquals("0.001", Decimal("1E-3").ToString(), "ToString should expand negative exponent notation")
	End Method

	Method TestToSciString() { test }
		AssertEquals("1.2345E+9", Decimal("1.2345E+9").ToSciString(True), "Scientific string should preserve uppercase exponent form")
		AssertEquals("1.2345e+9", Decimal("1.2345E+9").ToSciString(False), "Scientific string should support lowercase exponent form")
	End Method

	Method TestToEngString() { test }
		AssertEquals("1.2345E+9", Decimal("1.2345E+9").ToEngString(True), "Engineering string should use exponent multiple of 3")
		AssertEquals("1.2345e+9", Decimal("1.2345E+9").ToEngString(False), "Engineering string should support lowercase exponent form")
	End Method

	Method TestSciVsEngDifference() { test }
		AssertEquals("1.2345E+8", Decimal("1.2345E+8").ToSciString(True), "Scientific exponent can be any power")
		AssertEquals("123.45E+6", Decimal("1.2345E+8").ToEngString(True), "Engineering exponent should be multiple of 3")
	End Method

	Method TestTrailingZeros() { test }
		AssertEquals("1.2300", Decimal("1.2300").ToString(), "ToString should preserve trailing zeros before reduce")
		AssertEquals("1.23", Decimal("1.2300").Reduce().ToString(), "Reduce should remove trailing zeros")
	End Method

End Type

Type TDecimalMathTest Extends TTest

	Method TestSqrt() { test }
		AssertEquals("2", Decimal("4").Sqrt().ToString(), "sqrt(4) should be 2")
		AssertEquals("3", Decimal("9").Sqrt().ToString(), "sqrt(9) should be 3")
		AssertEquals("1.5", Decimal("2.25").Sqrt().ToString(), "sqrt(2.25) should be 1.5")
	End Method

	Method TestInvSqrt() { test }
		AssertEquals("0.5", Decimal("4").InvSqrt().ToString(), "invsqrt(4) should be 0.5")
		AssertEquals("0.25", Decimal("16").InvSqrt().ToString(), "invsqrt(16) should be 0.25")
	End Method

	Method TestPowIntegerExponent() { test }
		AssertEquals("8", Decimal("2").Pow(Decimal("3")).ToString(), "2^3 should be 8")
		AssertEquals("1", Decimal("5").Pow(Decimal("0")).ToString(), "5^0 should be 1")
		AssertEquals("0.25", Decimal("2").Pow(Decimal("-2")).ToString(), "2^-2 should be 0.25")
	End Method

	Method TestExpLnRoundTrip() { test }
		Local x:TDecimal = Decimal("2")
		Local y:TDecimal = x.Ln().Exp()

		AssertTrue(y.Quantize(Decimal("0.0000000001")) = x.Quantize(Decimal("0.0000000001")), "exp(ln(2)) should approximately equal 2")
	End Method

	Method TestLnExpConstants() { test }
		AssertEquals("0", Decimal("1").Ln().ToString(), "ln(1) should be 0")
		AssertEquals("1", Decimal("0").Exp().ToString(), "exp(0) should be 1")
	End Method

	Method TestLog10() { test }
		AssertEquals("0", Decimal("1").Log10().ToString(), "log10(1) should be 0")
		AssertEquals("1", Decimal("10").Log10().ToString(), "log10(10) should be 1")
		AssertEquals("2", Decimal("100").Log10().ToString(), "log10(100) should be 2")
	End Method

End Type

Type TDecimalConversionTest Extends TTest

	Method TestToInt() { test }
		AssertEquals(42, Decimal("42").ToInt(), "42 should convert to Int")
		AssertEquals(-42, Decimal("-42").ToInt(), "-42 should convert to Int")
		AssertEquals(42, Decimal("42.9").ToInt(), "ToInt should truncate toward zero")
		AssertEquals(-42, Decimal("-42.9").ToInt(), "ToInt should truncate toward zero")
	End Method

	Method TestToUInt() { test }
		AssertEquals(42:UInt, Decimal("42").ToUInt(), "42 should convert to UInt")
		AssertEquals(42:UInt, Decimal("42.9").ToUInt(), "ToUInt should truncate toward zero")
	End Method

	Method TestToLong() { test }
		AssertEquals(42:Long, Decimal("42").ToLong(), "42 should convert to Long")
		AssertEquals(-42:Long, Decimal("-42").ToLong(), "-42 should convert to Long")
		AssertEquals(42:Long, Decimal("42.9").ToLong(), "ToLong should truncate toward zero")
		AssertEquals(-42:Long, Decimal("-42.9").ToLong(), "ToLong should truncate toward zero")
	End Method

	Method TestToULong() { test }
		AssertEquals(42:ULong, Decimal("42").ToULong(), "42 should convert to ULong")
		AssertEquals(42:ULong, Decimal("42.9").ToULong(), "ToULong should truncate toward zero")
	End Method

	Method TestConstructUnsignedValues() { test }
		AssertEquals("42", Decimal(42:UInt).ToString(), "UInt constructor should work")
		AssertEquals("42", Decimal(42:ULong).ToString(), "ULong constructor should work")
	End Method

End Type

Type TDecimalInPlaceOperatorTest Extends TTest

	Method TestInPlaceAssign() { test }
		Local d:TDecimal = Decimal("1")
		d = Decimal("42")

		AssertEquals("42", d.ToString(), ":= should replace value")
	End Method

	Method TestInPlaceBitwiseAnd() { test }
		Local d:TDecimal = Decimal("1101")
		d :& Decimal("1011")

		AssertEquals("1001", d.ToString(), "1101 :& 1011 should equal 1001")
	End Method

	Method TestInPlaceBitwiseOr() { test }
		Local d:TDecimal = Decimal("1101")
		d :| Decimal("1011")

		AssertEquals("1111", d.ToString(), "1101 :| 1011 should equal 1111")
	End Method

	Method TestInPlaceBitwiseXor() { test }
		Local d:TDecimal = Decimal("1101")
		d :~ Decimal("1011")

		AssertEquals("110", d.ToString(), "1101 :~~ 1011 should equal 110")
	End Method

	Method TestInPlaceBitwiseDoesNotAliasOperand() { test }
		Local a:TDecimal = Decimal("1101")
		Local b:TDecimal = Decimal("1011")

		a :& b
		b = Decimal("1111")

		AssertEquals("1001", a.ToString(), "In-place AND result should not depend on later operand changes")
		AssertEquals("1111", b.ToString(), "Operand should be independently assignable after operation")
	End Method

End Type

Type TDecimalSpecialTest Extends TTest

	Method TestNaN() { test }
		Local d:TDecimal = Decimal("NaN")
		AssertTrue(d.IsNaN(), "NaN should be NaN")
		AssertFalse(d.IsFinite(), "NaN should not be finite")
		AssertTrue(d.IsSpecial(), "NaN should be special")
	End Method

	Method TestInfinity() { test }
		Local d:TDecimal = Decimal("Infinity")

		AssertTrue(d.IsInfinite(), "Infinity should be infinite")
		AssertFalse(d.IsFinite(), "Infinity should not be finite")
	End Method

	Method TestNaNComparisonRaisesInvalidOperation() { test }
		Local d:TDecimal = Decimal("NaN")
		Try
			Local result:Int = d = d
			Fail("Comparing NaN with = should raise invalid operation")
		Catch e:TDecimalException
			AssertTrue(True, "NaN comparison raised expected decimal exception")
		End Try
	End Method

End Type

Type TDecimalAliasingTest Extends TTest

	Method TestSelfAddition() { test }
		Local d:TDecimal = Decimal("5")
		d :+ d
		AssertEquals("10", d.ToString(), "d :+ d should work")
	End Method

	Method TestSelfSubtraction() { test }
		Local d:TDecimal = Decimal("5")
		d :- d
		AssertEquals("0", d.ToString(), "d :- d should be zero")
	End Method

	Method TestSelfMultiplication() { test }
		Local d:TDecimal = Decimal("5")
		d :* d
		AssertEquals("25", d.ToString(), "d :* d should work")
	End Method

End Type

Type TDecimalErrorTest Extends TTest

	Method TestDivideByZeroRaises() { test }
		Try
			Local d:TDecimal = Decimal("1") / Decimal("0")
			Fail("Division by zero should raise")
		Catch e:TDecimalException
			AssertTrue(True, "Expected decimal exception")
		End Try
	End Method

	Method TestSqrtNegativeRaises() { test }
		Try
			Local d:TDecimal = Decimal("-1").Sqrt()
			Fail("sqrt(-1) should raise")
		Catch e:TDecimalException
			AssertTrue(True, "Expected decimal exception")
		End Try
	End Method

End Type

Type TDecimalShiftTest Extends TTest

	Method TestShiftPositive() { test }
		AssertEquals("12300", Decimal("123").Shift(2).ToString(), "Shift(2)")
	End Method

	Method TestShiftNegative() { test }
		AssertEquals("1", Decimal("123").Shift(-2).ToString(), "Shift(-2) should discard two rightmost digits")
	End Method

End Type

Type TDecimalBitwiseTest Extends TTest

	Method TestAnd() { test }
		AssertEquals("1001", (Decimal("1101") & Decimal("1011")).ToString(), "AND")
	End Method

	Method TestOr() { test }
		AssertEquals("1111", (Decimal("1101") | Decimal("1011")).ToString(), "OR")
	End Method

	Method TestXor() { test }
		AssertEquals("110", (Decimal("1101") ~ Decimal("1011")).ToString(), "XOR")
	End Method

End Type

Type TDecimalNumericOverloadTest Extends TTest

	Method TestBasicOperatorsWithUInt() { test }
		AssertEquals("5", (Decimal("2") + 3:UInt).ToString(), "Decimal + UInt")
		AssertEquals("-1", (Decimal("2") - 3:UInt).ToString(), "Decimal - UInt")
		AssertEquals("6", (Decimal("2") * 3:UInt).ToString(), "Decimal * UInt")
		AssertEquals("2.5", (Decimal("5") / 2:UInt).ToString(), "Decimal / UInt")
	End Method

	Method TestBasicOperatorsWithLong() { test }
		AssertEquals("5", (Decimal("2") + 3:Long).ToString(), "Decimal + Long")
		AssertEquals("-1", (Decimal("2") - 3:Long).ToString(), "Decimal - Long")
		AssertEquals("6", (Decimal("2") * 3:Long).ToString(), "Decimal * Long")
		AssertEquals("2.5", (Decimal("5") / 2:Long).ToString(), "Decimal / Long")
	End Method

	Method TestBasicOperatorsWithULong() { test }
		AssertEquals("5", (Decimal("2") + 3:ULong).ToString(), "Decimal + ULong")
		AssertEquals("-1", (Decimal("2") - 3:ULong).ToString(), "Decimal - ULong")
		AssertEquals("6", (Decimal("2") * 3:ULong).ToString(), "Decimal * ULong")
		AssertEquals("2.5", (Decimal("5") / 2:ULong).ToString(), "Decimal / ULong")
	End Method

	Method TestInPlaceOperatorsWithInt() { test }
		Local d:TDecimal = Decimal("10")

		d :+ 3
		AssertEquals("13", d.ToString(), "Decimal :+ Int")

		d :- 4
		AssertEquals("9", d.ToString(), "Decimal :- Int")

		d :* 2
		AssertEquals("18", d.ToString(), "Decimal :* Int")

		d :/ 3
		AssertEquals("6", d.ToString(), "Decimal :/ Int")
	End Method

	Method TestInPlaceOperatorsWithUInt() { test }
		Local d:TDecimal = Decimal("10")

		d :+ 3:UInt
		AssertEquals("13", d.ToString(), "Decimal :+ UInt")

		d :- 4:UInt
		AssertEquals("9", d.ToString(), "Decimal :- UInt")

		d :* 2:UInt
		AssertEquals("18", d.ToString(), "Decimal :* UInt")

		d :/ 3:UInt
		AssertEquals("6", d.ToString(), "Decimal :/ UInt")
	End Method

	Method TestInPlaceOperatorsWithLong() { test }
		Local d:TDecimal = Decimal("10")

		d :+ 3:Long
		AssertEquals("13", d.ToString(), "Decimal :+ Long")

		d :- 4:Long
		AssertEquals("9", d.ToString(), "Decimal :- Long")

		d :* 2:Long
		AssertEquals("18", d.ToString(), "Decimal :* Long")

		d :/ 3:Long
		AssertEquals("6", d.ToString(), "Decimal :/ Long")
	End Method

	Method TestInPlaceOperatorsWithULong() { test }
		Local d:TDecimal = Decimal("10")

		d :+ 3:ULong
		AssertEquals("13", d.ToString(), "Decimal :+ ULong")

		d :- 4:ULong
		AssertEquals("9", d.ToString(), "Decimal :- ULong")

		d :* 2:ULong
		AssertEquals("18", d.ToString(), "Decimal :* ULong")

		d :/ 3:ULong
		AssertEquals("6", d.ToString(), "Decimal :/ ULong")
	End Method

End Type
