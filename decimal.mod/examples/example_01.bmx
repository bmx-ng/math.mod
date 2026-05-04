SuperStrict

Framework Math.decimal
Import BRL.StandardIO

Local num:TDecimal = Decimal("0")
Print(num.ToString()) ' 0

num = Decimal("1")
Print(num.ToString()) ' 1

num = Decimal("-.0123")
Print(num.ToString()) ' -0.0123

num = Decimal(123456)
Print(num.ToString()) ' 123456

num = Decimal("123.45e30")
Print(num.ToString()) ' 1.23450000000000000000000000000000000

num = Decimal("1.33") + Decimal("1.27")
Print(num.ToString()) ' 2.60

num = Decimal("12.34") + Decimal("3.87") - Decimal("18.41")
Print(num.ToString()) ' -2.20

Local dig:TDecimal = Decimal(1)
Print((dig / Decimal(3)).ToString()) ' 0.333333333

TDecimal.GetContext().SetPrec(18)
Print((dig / Decimal(3)).ToString()) ' 0.333333333333333333

Print "Pi to 50 digits: " + CalcPi(50).ToString() ' Pi to 50 digits: 3.141592653589793238462643383279502884197169399375105

Local t:Int = MilliSecs()

For Local i:Int = 0 until 10000
	CalcPi(50)
Next

Print "Time taken: " + (MilliSecs() - t) + "ms"

Local assigned:TDecimal = Decimal("123.45")
Print "Assigned: " + assigned.ToString()

assigned = "3.14159265358979323846264338327950288419716939937510"
Print "Assigned: " + assigned.ToString()

assigned = 876
Print "Assigned: " + assigned.ToString()


Function CalcPi:TDecimal(prec:Int)
	Local context:TMpdContext = TDecimal.GetContext()
	context.SetPrec( prec + 2 ) ' guard digits
	
	Local lasts:TDecimal = Decimal(0)
	Local t:TDecimal = Decimal(3)
	Local s:TDecimal = Decimal(3)
	Local n:TDecimal = Decimal(1)
	Local na:TDecimal = Decimal(0)
	Local d:TDecimal = Decimal(0)
	Local da:TDecimal = Decimal(24)

	While s <> lasts
		lasts = s
		n :+ na
		na :+ 8
		d :+ da
		da :+ 32
		't = (t * n) / d
		t :* n
		t :/ d
		s :+ t
	End While

	context.SetPrec( prec - 2 )

	Return s
	
End Function

