'
' Copyright (c) 2026 Bruce A Henderson
'
' Redistribution and use in source and binary forms, with or without
' modification, are permitted provided that the following conditions
' are met:
'
' 1. Redistributions of source code must retain the above copyright
'    notice, this list of conditions and the following disclaimer.
' 2. Redistributions in binary form must reproduce the above copyright
'    notice, this list of conditions and the following disclaimer in the
'    documentation and/or other materials provided with the distribution.
'
' THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
' ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
' IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
' ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
' FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
' DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
' OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
' HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
' LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
' OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
' SUCH DAMAGE.
'
SuperStrict

Rem
bbdoc: Arbitrary precision decimal arithmetic.
End Rem
Module Math.Decimal

ModuleInfo "Version: 1.00"
ModuleInfo "Author: Bruce A Henderson"
ModuleInfo "License: BSD-2-Clause"
ModuleInfo "Copyright: mpdecimal - 2008-2024 Stefan Krah"
ModuleInfo "Copyright: wrapper - 2026 Bruce A Henderson"

ModuleInfo "History: 1.00"
ModuleInfo "History: Initial Release"


?Ptr64
ModuleInfo "CC_OPTS: -DMPD_CONFIG_64 -DCONFIG_64"
?Ptr32
ModuleInfo "CC_OPTS: -DMPD_CONFIG_32 -DCONFIG_32"
?
ModuleInfo "CC_OPTS: -std=c99"
ModuleInfo "CC_OPTS: -DANSI"

Import "common.bmx"

Rem
bbdoc: The #TDecimal type represents an arbitrary precision decimal number.
End Rem
Type TDecimal

	ThreadedGlobal context:TMpdContext

	Private
	Field mpdPtr:Byte Ptr ' pointer reference to value

	Field value:SMpd = New SMpd
	Field data:ULong[4]
	Public

	Rem
	bbdoc: Sets the global context to the default context.
	End Rem
	Function SetDefaultContext()
		context = TMpdContext.CreateDefault()
	End Function

	Rem
	bbdoc: Sets the global context to the maximum context.
	End Rem
	Function SetMaxContext()
		context = TMpdContext.CreateMax()
	End Function

	Rem
	bbdoc: Sets the global context to the minimum context.
	End Rem
	Function SetBasicContext()
		context = TMpdContext.CreateBasic()
	End Function

	Rem
	bbdoc: Sets the global context to an IEEE 754 compatible context with the specified number of bits.
	returns: 0 on success, -1 on failure.
	End Rem
	Function SetIEEEContext:Int(bits:Int)
		Local result:Int
		context = TMpdContext.CreateIEEE(bits, result)
		Return result
	End Function

	Rem
	bbdoc: Gets the current global context.
	End Rem
	Function GetContext:TMpdContext()
		Return context
	End Function
	
	Rem
	bbdoc: Creates a new #TDecimal object with the value of 0.
	End Rem
	Method New()
		mpdPtr = VarPtr value
		value.data = data
	End Method

	Rem
	bbdoc: Creates a new #TDecimal object with the #String value of @v.
	End Rem
	Method New(v:String)
		mpdPtr = VarPtr value
		value.data = data
		bmx_mpd_set_string(mpdPtr, v, context.context)
	End Method

	Rem
	bbdoc: Creates a new #TDecimal object with the value of the #Int @v.
	End Rem
	Method New(v:Int)
		mpdPtr = VarPtr value
		value.data = data
		mpd_set_i32(mpdPtr, v, context.context)
	End Method

	Rem
	bbdoc: Creates a new #TDecimal object with the value of the #Long @v.
	End Rem
	Method New(v:Long)
		mpdPtr = VarPtr value
		value.data = data
		mpd_set_i64(mpdPtr, v, context.context)
	End Method

	Rem
	bbdoc: Creates a new #TDecimal object with the value of the #UInt @v.
	End Rem
	Method New(v:UInt)
		mpdPtr = VarPtr value
		value.data = data
		mpd_set_u32(mpdPtr, v, context.context)
	End Method

	Rem
	bbdoc: Creates a new #TDecimal object with the value of the #ULong @v.
	End Rem
	Method New(v:ULong)
		mpdPtr = VarPtr value
		value.data = data
		mpd_set_u64(mpdPtr, v, context.context)
	End Method

	Rem
	bbdoc: Assigns the #TDecimal value of @b to the current decimal object.
	End Rem
	Method Operator :=:TDecimal(b:TDecimal)
		Local status:Int = mpd_qcopy_cxx(mpdPtr, b.mpdPtr)
		Return Self
	End Method

	Rem
	bbdoc: Assigns the #String value of @b to the current decimal object.
	End Rem
	Method Operator :=:TDecimal(b:String)
		Local status:UInt
		bmx_mpd_qset_string_exact(mpdPtr, b, status)
		Return Self
	End Method

	Rem
	bbdoc: Assigns the #Int value of @b to the current decimal object.
	End Rem
	Method Operator :=:TDecimal(b:Int)
		Local status:UInt
		mpd_qset_i32(mpdPtr, b, context.context, status)
		Return Self
	End Method

	Rem
	bbdoc: Assigns the #UInt value of @b to the current decimal object.
	End Rem
	Method Operator :=:TDecimal(b:UInt)
		Local status:UInt
		mpd_qset_u32(mpdPtr, b, context.context, status)
		Return Self
	End Method

	Rem
	bbdoc: Assigns the #Long value of @b to the current decimal object.
	End Rem
	Method Operator :=:TDecimal(b:Long)
		Local status:UInt
		mpd_qset_i64_exact(mpdPtr, b, status)
		Return Self
	End Method

	Rem
	bbdoc: Assigns the #ULong value of @b to the current decimal object.
	End Rem
	Method Operator :=:TDecimal(b:ULong)
		Local status:UInt
		mpd_qset_u64_exact(mpdPtr, b, status)
		Return Self
	End Method

	Rem
	bbdoc: Multiplies the current decimal object by the #TDecimal value of @b, in place.
	End Rem
	Method Operator :*:TDecimal(b:TDecimal)
		Local status:UInt
		mpd_qmul(mpdPtr, mpdPtr, b.mpdPtr, context.context, status)
		Return Self
	End Method

	Rem
	bbdoc: Multiplies the current decimal object by the #Int value of @b, in place.
	End Rem
	Method Operator :*:TDecimal(b:Int)
		Local status:UInt
		mpd_qmul_i32(mpdPtr, mpdPtr, b, context.context, status)
		Return Self
	End Method

	Rem
	bbdoc: Multiplies the current decimal object by the #UInt value of @b, in place.
	End Rem
	Method Operator :*:TDecimal(b:UInt)
		Local status:UInt
		mpd_qmul_u32(mpdPtr, mpdPtr, b, context.context, status)
		Return Self
	End Method

	Rem
	bbdoc: Multiplies the current decimal object by the #Long value of @b, in place.
	End Rem
	Method Operator :*:TDecimal(b:Long)
		Local status:UInt
		mpd_qmul_i64(mpdPtr, mpdPtr, b, context.context, status)
		Return Self
	End Method

	Rem
	bbdoc: Multiplies the current decimal object by the #ULong value of @b, in place.
	End Rem
	Method Operator :*:TDecimal(b:ULong)
		Local status:UInt
		mpd_qmul_u64(mpdPtr, mpdPtr, b, context.context, status)
		Return Self
	End Method

	Rem
	bbdoc: Divides the current decimal object by the #TDecimal value of @b, in place.
	End Rem
	Method Operator :/:TDecimal(b:TDecimal)
		Local status:UInt
		mpd_qdiv(mpdPtr, mpdPtr, b.mpdPtr, context.context, status)
		Return Self
	End Method

	Rem
	bbdoc: Divides the current decimal object by the #Int value of @b, in place.
	End Rem
	Method Operator :/:TDecimal(b:Int)
		Local status:UInt
		mpd_qdiv_i32(mpdPtr, mpdPtr, b, context.context, status)
		Return Self
	End Method

	Rem
	bbdoc: Divides the current decimal object by the #UInt value of @b, in place.
	End Rem
	Method Operator :/:TDecimal(b:UInt)
		Local status:UInt
		mpd_qdiv_u32(mpdPtr, mpdPtr, b, context.context, status)
		Return Self
	End Method

	Rem
	bbdoc: Divides the current decimal object by the #Long value of @b, in place.
	End Rem
	Method Operator :/:TDecimal(b:Long)
		Local status:UInt
		mpd_qdiv_i64(mpdPtr, mpdPtr, b, context.context, status)
		Return Self
	End Method

	Rem
	bbdoc: Divides the current decimal object by the #ULong value of @b, in place.
	End Rem
	Method Operator :/:TDecimal(b:ULong)
		Local status:UInt
		mpd_qdiv_u64(mpdPtr, mpdPtr, b, context.context, status)
		Return Self
	End Method

	Rem
	bbdoc: Compares the current decimal object with the #TDecimal value of @b for equality.
	returns: #True if the values are equal, #False otherwise.
	End Rem
	Method Operator =:Int(b:TDecimal)
		Local status:UInt
		Local result:Int = mpd_qcmp(mpdPtr, b.mpdPtr, status)
		If result = INT_MAX Then
			If IsNaN() Or b.IsNaN() Then
				context.Raise(status)
			End If
			Return False
		End If
		Return result = 0
	End Method

	Rem
	bbdoc: Compares the current decimal object with the #TDecimal value of @b for inequality.
	returns: #True if the values are not equal, #False otherwise.
	End Rem
	Method Operator <>:Int(b:TDecimal)
		Local status:UInt
		Local result:Int = mpd_qcmp(mpdPtr, b.mpdPtr, status)
		If result = INT_MAX Then
			If IsNaN() Or b.IsNaN() Then
				context.Raise(status)
			End If
			Return True
		End If
		Return result <> 0
	End Method

	Rem
	bbdoc: Determines whether the value of the current decimal object is less than the #TDecimal value of @b.
	returns: #True if the current decimal object is less than @b, #False otherwise.
	End Rem
	Method Operator <:Int(b:TDecimal)
		Local status:UInt
		Local result:Int = mpd_qcmp(mpdPtr, b.mpdPtr, status)
		If result = INT_MAX Then
			context.Raise(status)
			Return False
		End If
		Return result < 0
	End Method

	Rem
	bbdoc: Determines whether the value of the current decimal object is less than or equal to the #TDecimal value of @b.
	returns: #True if the current decimal object is less than or equal to @b, #False otherwise.
	End Rem
	Method Operator <=:Int(b:TDecimal)
		Local status:UInt
		Local result:Int = mpd_qcmp(mpdPtr, b.mpdPtr, status)
		If result = INT_MAX Then
			context.Raise(status)
			Return False
		End If
		Return result <= 0
	End Method

	Rem
	bbdoc: Determines whether the value of the current decimal object is greater than or equal to the #TDecimal value of @b.
	returns: #True if the current decimal object is greater than or equal to @b, #False otherwise.
	End Rem
	Method Operator >=:Int(b:TDecimal)
		Local status:UInt
		Local result:Int = mpd_qcmp(mpdPtr, b.mpdPtr, status)
		If result = INT_MAX Then
			context.Raise(status)
			Return False
		End If
		Return result >= 0
	End Method

	Rem
	bbdoc: Determines whether the value of the current decimal object is greater than the #TDecimal value of @b.
	returns: #True if the current decimal object is greater than @b, #False otherwise.
	End Rem
	Method Operator >:Int(b:TDecimal)
		Local status:UInt
		Local result:Int = mpd_qcmp(mpdPtr, b.mpdPtr, status)
		If result = INT_MAX Then
			context.Raise(status)
			Return False
		End If
		Return result > 0
	End Method

	Rem
	bbdoc: Adds the #TDecimal value of @b to the current decimal object and returns the result as a new #TDecimal object.
	End Rem
	Method Operator +:TDecimal(b:TDecimal)
		Local result:TDecimal = New TDecimal()
		Local status:UInt
		mpd_qadd(result.mpdPtr, mpdPtr, b.mpdPtr, context.context, status)
		Return result
	End Method

	Rem
	bbdoc: Subtracts the #TDecimal value of @b from the current decimal object and returns the result as a new #TDecimal object.
	End Rem
	Method Operator -:TDecimal(b:TDecimal)
		Local result:TDecimal = New TDecimal()
		Local status:UInt
		mpd_qsub(result.mpdPtr, mpdPtr, b.mpdPtr, context.context, status)
		Return result
	End Method

	Rem
	bbdoc: Multiplies the current decimal object by the #TDecimal value of @b and returns the result as a new #TDecimal object.
	End Rem
	Method Operator *:TDecimal(b:TDecimal)
		Local result:TDecimal = New TDecimal()
		Local status:UInt
		mpd_qmul(result.mpdPtr, mpdPtr, b.mpdPtr, context.context, status)
		Return result
	End Method

	Rem
	bbdoc: Divides the current decimal object by the #TDecimal value of @b and returns the result as a new #TDecimal object.
	End Rem
	Method Operator /:TDecimal(b:TDecimal)
		Local result:TDecimal = New TDecimal()
		Local status:UInt
		mpd_qdiv(result.mpdPtr, mpdPtr, b.mpdPtr, context.context, status)
		If status Then
			If status & MPD_Division_by_zero
				Throw New TDecimalDivisionByZeroException()
			Else
				context.Raise(status)
			End If
		End If
		Return result
	End Method

	Rem
	bbdoc: Adds the #Int value of @b to the current decimal object and returns the result as a new #TDecimal object.
	End Rem
	Method Operator +:TDecimal(b:Int)
		Local result:TDecimal = New TDecimal()
		Local status:UInt
		mpd_qadd_i32(result.mpdPtr, mpdPtr, b, context.context, status)
		Return result
	End Method

	Rem
	bbdoc: Subtracts the #Int value of @b from the current decimal object and returns the result as a new #TDecimal object.
	End Rem
	Method Operator -:TDecimal(b:Int)
		Local result:TDecimal = New TDecimal()
		Local status:UInt
		mpd_qsub_i32(result.mpdPtr, mpdPtr, b, context.context, status)
		Return result
	End Method

	Rem
	bbdoc: Multiplies the current decimal object by the #Int value of @b and returns the result as a new #TDecimal object.
	End Rem
	Method Operator *:TDecimal(b:Int)
		Local result:TDecimal = New TDecimal()
		Local status:UInt
		mpd_qmul_i32(result.mpdPtr, mpdPtr, b, context.context, status)
		Return result
	End Method

	Rem
	bbdoc: Divides the current decimal object by the #Int value of @b and returns the result as a new #TDecimal object.
	End Rem
	Method Operator /:TDecimal(b:Int)
		Local result:TDecimal = New TDecimal()
		Local status:UInt
		mpd_qdiv_i32(result.mpdPtr, mpdPtr, b, context.context, status)
		Return result
	End Method

	Rem
	bbdoc: Adds the #UInt value of @b to the current decimal object and returns the result as a new #TDecimal object.
	End Rem
	Method Operator +:TDecimal(b:UInt)
		Local result:TDecimal = New TDecimal()
		Local status:UInt
		mpd_qadd_u32(result.mpdPtr, mpdPtr, b, context.context, status)
		Return result
	End Method

	Rem
	bbdoc: Subtracts the #UInt value of @b from the current decimal object and returns the result as a new #TDecimal object.
	End Rem
	Method Operator -:TDecimal(b:UInt)
		Local result:TDecimal = New TDecimal()
		Local status:UInt
		mpd_qsub_u32(result.mpdPtr, mpdPtr, b, context.context, status)
		Return result
	End Method

	Rem
	bbdoc: Multiplies the current decimal object by the #UInt value of @b and returns the result as a new #TDecimal object.
	End Rem
	Method Operator *:TDecimal(b:UInt)
		Local result:TDecimal = New TDecimal()
		Local status:UInt
		mpd_qmul_u32(result.mpdPtr, mpdPtr, b, context.context, status)
		Return result
	End Method

	Rem
	bbdoc: Divides the current decimal object by the #UInt value of @b and returns the result as a new #TDecimal object.
	End Rem
	Method Operator /:TDecimal(b:UInt)
		Local result:TDecimal = New TDecimal()
		Local status:UInt
		mpd_qdiv_u32(result.mpdPtr, mpdPtr, b, context.context, status)
		Return result
	End Method

	Rem
	bbdoc: Adds the #Long value of @b to the current decimal object and returns the result as a new #TDecimal object.
	End Rem
	Method Operator +:TDecimal(b:Long)
		Local result:TDecimal = New TDecimal()
		Local status:UInt
		mpd_qadd_i64(result.mpdPtr, mpdPtr, b, context.context, status)
		Return result
	End Method

	Rem
	bbdoc: Subtracts the #Long value of @b from the current decimal object and returns the result as a new #TDecimal object.
	End Rem
	Method Operator -:TDecimal(b:Long)
		Local result:TDecimal = New TDecimal()
		Local status:UInt
		mpd_qsub_i64(result.mpdPtr, mpdPtr, b, context.context, status)
		Return result
	End Method

	Rem
	bbdoc: Multiplies the current decimal object by the #Long value of @b and returns the result as a new #TDecimal object.
	End Rem
	Method Operator *:TDecimal(b:Long)
		Local result:TDecimal = New TDecimal()
		Local status:UInt
		mpd_qmul_i64(result.mpdPtr, mpdPtr, b, context.context, status)
		Return result
	End Method

	Rem
	bbdoc: Divides the current decimal object by the #Long value of @b and returns the result as a new #TDecimal object.
	End Rem
	Method Operator /:TDecimal(b:Long)
		Local result:TDecimal = New TDecimal()
		Local status:UInt
		mpd_qdiv_i64(result.mpdPtr, mpdPtr, b, context.context, status)
		Return result
	End Method

	Rem
	bbdoc: Adds the #ULong value of @b to the current decimal object and returns the result as a new #TDecimal object.
	End Rem
	Method Operator +:TDecimal(b:ULong)
		Local result:TDecimal = New TDecimal()
		Local status:UInt
		mpd_qadd_u64(result.mpdPtr, mpdPtr, b, context.context, status)
		Return result
	End Method

	Rem
	bbdoc: Subtracts the #ULong value of @b from the current decimal object and returns the result as a new #TDecimal object.
	End Rem
	Method Operator -:TDecimal(b:ULong)
		Local result:TDecimal = New TDecimal()
		Local status:UInt
		mpd_qsub_u64(result.mpdPtr, mpdPtr, b, context.context, status)
		Return result
	End Method

	Rem
	bbdoc: Multiplies the current decimal object by the #ULong value of @b and returns the result as a new #TDecimal object.
	End Rem
	Method Operator *:TDecimal(b:ULong)
		Local result:TDecimal = New TDecimal()
		Local status:UInt
		mpd_qmul_u64(result.mpdPtr, mpdPtr, b, context.context, status)
		Return result
	End Method

	Rem
	bbdoc: Divides the current decimal object by the #ULong value of @b and returns the result as a new #TDecimal object.
	End Rem
	Method Operator /:TDecimal(b:ULong)
		Local result:TDecimal = New TDecimal()
		Local status:UInt
		mpd_qdiv_u64(result.mpdPtr, mpdPtr, b, context.context, status)
		Return result
	End Method

	Rem
	bbdoc: Adds the #TDecimal value of @b to the current decimal object, in place.
	End Rem
	Method Operator :+:TDecimal(b:TDecimal)
		Local status:UInt
		mpd_qadd(mpdPtr, mpdPtr, b.mpdPtr, context.context, status)
		Return Self
	End Method

	Rem
	bbdoc: Adds the #Int value of @b to the current decimal object, in place.
	End Rem
	Method Operator :+:TDecimal(b:Int)
		Local status:UInt
		mpd_qadd_i32(mpdPtr, mpdPtr, b, context.context, status)
		Return Self
	End Method

	Rem
	bbdoc: Adds the #UInt value of @b to the current decimal object, in place.
	End Rem
	Method Operator :+:TDecimal(b:UInt)
		Local status:UInt
		mpd_qadd_u32(mpdPtr, mpdPtr, b, context.context, status)
		Return Self
	End Method

	Rem
	bbdoc: Adds the #Long value of @b to the current decimal object, in place.
	End Rem
	Method Operator :+:TDecimal(b:Long)
		Local status:UInt
		mpd_qadd_i64(mpdPtr, mpdPtr, b, context.context, status)
		Return Self
	End Method

	Rem
	bbdoc: Adds the #ULong value of @b to the current decimal object, in place.
	End Rem
	Method Operator :+:TDecimal(b:ULong)
		Local status:UInt
		mpd_qadd_u64(mpdPtr, mpdPtr, b, context.context, status)
		Return Self
	End Method

	Rem
	bbdoc: Subtracts the #TDecimal value of @b from the current decimal object, in place.
	End Rem
	Method Operator :-:TDecimal(b:TDecimal)
		Local status:UInt
		mpd_qsub(mpdPtr, mpdPtr, b.mpdPtr, context.context, status)
		Return Self
	End Method

	Rem
	bbdoc: Subtracts the #Int value of @b from the current decimal object, in place.
	End Rem
	Method Operator :-:TDecimal(b:Int)
		Local status:UInt
		mpd_qsub_i32(mpdPtr, mpdPtr, b, context.context, status)
		Return Self
	End Method

	Rem
	bbdoc: Subtracts the #UInt value of @b from the current decimal object, in place.
	End Rem
	Method Operator :-:TDecimal(b:UInt)
		Local status:UInt
		mpd_qsub_u32(mpdPtr, mpdPtr, b, context.context, status)
		Return Self
	End Method

	Rem
	bbdoc: Subtracts the #Long value of @b from the current decimal object, in place.
	End Rem
	Method Operator :-:TDecimal(b:Long)
		Local status:UInt
		mpd_qsub_i64(mpdPtr, mpdPtr, b, context.context, status)
		Return Self
	End Method

	Rem
	bbdoc: Subtracts the #ULong value of @b from the current decimal object, in place.
	End Rem
	Method Operator :-:TDecimal(b:ULong)
		Local status:UInt
		mpd_qsub_u64(mpdPtr, mpdPtr, b, context.context, status)
		Return Self
	End Method

	Rem
	bbdoc: Applies the bitwise AND operator to the current decimal object and the #TDecimal value of @b and returns the result as a new #TDecimal object.
	End Rem
	Method Operator &:TDecimal(b:TDecimal)
		Local result:TDecimal = New TDecimal()
		Local status:UInt
		mpd_qand(result.mpdPtr, mpdPtr, b.mpdPtr, context.context, status)
		Return result
	End Method

	Rem
	bbdoc: Applies the bitwise AND operator to the current decimal object and the #TDecimal value of @b, in place.
	End Rem
	Method Operator :&:TDecimal(b:TDecimal)
		Local status:UInt
		mpd_qand(mpdPtr, mpdPtr, b.mpdPtr, context.context, status)
		Return Self
	End Method

	Rem
	bbdoc: Applies the bitwise OR operator to the current decimal object and the #TDecimal value of @b and returns the result as a new #TDecimal object.
	End Rem
	Method Operator |:TDecimal(b:TDecimal)
		Local result:TDecimal = New TDecimal()
		Local status:UInt
		mpd_qor(result.mpdPtr, mpdPtr, b.mpdPtr, context.context, status)
		Return result
	End Method

	Rem
	bbdoc: Applies the bitwise OR operator to the current decimal object and the #TDecimal value of @b, in place.
	End Rem
	Method Operator :|:TDecimal(b:TDecimal)
		Local status:UInt
		mpd_qor(mpdPtr, mpdPtr, b.mpdPtr, context.context, status)
		Return Self
	End Method

	Rem
	bbdoc: Applies the bitwise XOR operator to the current decimal object and the #TDecimal value of @b and returns the result as a new #TDecimal object.
	End Rem
	Method Operator ~:TDecimal(b:TDecimal)
		Local result:TDecimal = New TDecimal()
		Local status:UInt
		mpd_qxor(result.mpdPtr, mpdPtr, b.mpdPtr, context.context, status)
		Return result
	End Method

	Rem
	bbdoc: Applies the bitwise XOR operator to the current decimal object and the #TDecimal value of @b, in place.
	End Rem
	Method Operator :~:TDecimal(b:TDecimal)
		Local status:UInt
		mpd_qxor(mpdPtr, mpdPtr, b.mpdPtr, context.context, status)
		Return Self
	End Method

	' Method Operator Mod:TDecimal(b:TDecimal)
	' 	Local result:TDecimal = New TDecimal()
	' 	Local status:UInt
	' 	mpd_qmod(result.mpdPtr, mpdPtr, b.mpdPtr, context.context, status)
	' 	Return result
	' End Method

	Rem
	bbdoc: Returns a result shifted by @b places.
	about: @b must be in the range `[-prec, prec]`.
	A negative @b indicates a right shift, a positive b a left shift. Digits that do not fit are discarded.
	End Rem
	Method Shift:TDecimal(b:TDecimal)
		Local result:TDecimal = New TDecimal()
		Local status:UInt
		mpd_qshift(result.mpdPtr, mpdPtr, b.mpdPtr, context.context, status)
		Return result
	End Method

	Rem
	bbdoc: Returns a result shifted by @b places.
	about: @b must be in the range `[-prec, prec]`.
	A negative @b indicates a right shift, a positive b a left shift. Digits that do not fit are discarded.
	End Rem
?Ptr64
	Method Shift:TDecimal(b:Long)
?Ptr32
	Method Shift:TDecimal(b:Int)
?
		Local result:TDecimal = New TDecimal()
		Local status:UInt
		mpd_qshiftn(result.mpdPtr, mpdPtr, b, context.context, status)
		Return result
	End Method

	Rem
	bbdoc: Returns the integer part of the division of the current decimal object by the #TDecimal value of @b.
	End Rem
	Method DivideInteger:TDecimal(b:TDecimal)
		Local result:TDecimal = New TDecimal()
		Local status:UInt
		mpd_qdivint(result.mpdPtr, mpdPtr, b.mpdPtr, context.context, status)
		Return result
	End Method

	Rem
	bbdoc: Returns the remainder of the division of the current decimal object by the #TDecimal value of @b.
	End Rem
	Method Remainder:TDecimal(b:TDecimal)
		Local result:TDecimal = New TDecimal()
		Local status:UInt
		mpd_qrem(result.mpdPtr, mpdPtr, b.mpdPtr, context.context, status)
		Return result
	End Method

	Rem
	bbdoc: Returns the remainder of the division of the current decimal object by the #TDecimal value of @b.
	about: Returns a - b * n, where n is the integer nearest the exact value of a / b. If two integers are equally near then the even one is chosen.
	End Rem
	Method RemainderNear:TDecimal(b:TDecimal)
		Local result:TDecimal = New TDecimal()
		Local status:UInt
		mpd_qrem_near(result.mpdPtr, mpdPtr, b.mpdPtr, context.context, status)
		Return result
	End Method

	Rem
	bbdoc: Returns the result of raising the current decimal object to the power of the #TDecimal value of @b.
	End Rem
	Method Exp:TDecimal()
		Local result:TDecimal = New TDecimal()
		Local status:UInt
		mpd_qexp(result.mpdPtr, mpdPtr, context.context, status)
		Return result
	End Method

	Rem
	bbdoc: Returns the natural logarithm of the current decimal object.
	about: Results are correctly rounded if the allcr field in the context is set to 1.
	End Rem
	Method Ln:TDecimal()
		Local result:TDecimal = New TDecimal()
		Local status:UInt
		mpd_qln(result.mpdPtr, mpdPtr, context.context, status)
		Return result
	End Method

	Rem
	bbdoc: Returns the base 10 logarithm of the current decimal object.
	about: Results are correctly rounded if the allcr field in the context is set to 1.
	End Rem
	Method Log10:TDecimal()
		Local result:TDecimal = New TDecimal()
		Local status:UInt
		mpd_qlog10(result.mpdPtr, mpdPtr, context.context, status)
		Return result
	End Method

	Rem
	bbdoc: Returns the result of raising the current decimal object to the power of the #TDecimal value of @exponent.
	about: Integer powers are exact, provided that that the result is finite and fits into prec.
	Results are not correctly rounded, even if the allcr context field is set to 1. This might change in a future release.
	The error of the function is less than 0.5ULP+t (1ULP+t for directed rounding modes), where t has a maximum of 0.1ULP, but is almost always less than 0.01ULP.
	End Rem
	Method Pow:TDecimal(exponent:TDecimal)
		Local result:TDecimal = New TDecimal()
		Local status:UInt
		mpd_qpow(result.mpdPtr, mpdPtr, exponent.mpdPtr, context.context, status)
		Return result
	End Method

	Rem
	bbdoc: Returns the square root of the current decimal object.
	about: This is always correctly rounded and always uses the ROUND_HALF_EVEN mode.
	End Rem
	Method Sqrt:TDecimal()
		Local result:TDecimal = New TDecimal()
		Local status:UInt
		mpd_qsqrt(result.mpdPtr, mpdPtr, context.context, status)
		If status Then
			context.Raise(status)
		End If
		Return result
	End Method

	Rem
	bbdoc: Returns the inverse square root of the current decimal object.
	about: Always uses the ROUND_HALF_EVEN mode. Results are not correctly rounded, even if the allcr context field is set to 1.
	End Rem
	Method InvSqrt:TDecimal()
		Local result:TDecimal = New TDecimal()
		Local status:UInt
		mpd_qinvroot(result.mpdPtr, mpdPtr, context.context, status)
		Return result
	End Method

	Rem
	bbdoc: Applies the unary minus operator to the current decimal object and returns the result as a new #TDecimal object.
	about: The operation is context sensitive.
	End Rem
	Method Minus:TDecimal()
		Local result:TDecimal = New TDecimal()
		Local status:UInt
		mpd_qminus(result.mpdPtr, mpdPtr, context.context, status)
		Return result
	End Method

	Rem
	bbdoc: Returns the result of applying the unary plus operator to the current decimal object.
	about: The operation is context sensitive.
	End Rem
	Method Plus:TDecimal()
		Local result:TDecimal = New TDecimal()
		Local status:UInt
		mpd_qplus(result.mpdPtr, mpdPtr, context.context, status)
		Return result
	End Method

	Rem
	bbdoc: Returns the absolute value of the current decimal object.
	about: The operation is context sensitive.
	End Rem
	Method Abs:TDecimal()
		Local result:TDecimal = New TDecimal()
		Local status:UInt
		mpd_qabs(result.mpdPtr, mpdPtr, context.context, status)
		Return result
	End Method

	Rem
	bbdoc: Returns the result of quantizing the current decimal object to the exponent of the #TDecimal value of @exponent.
	End Rem
	Method Quantize:TDecimal(exponent:TDecimal)
		Local result:TDecimal = New TDecimal()
		Local status:UInt
		mpd_qquantize(result.mpdPtr, mpdPtr, exponent.mpdPtr, context.context, status)
		Return result
	End Method

	Rem
	bbdoc: Returns a number that is equal in value to the current decimal object, but has the exponent @exponent.
	End Rem
?Ptr64
	Method Rescale:TDecimal(exponent:Long)
?Ptr32
	Method Rescale:TDecimal(exponent:Int)
?
		Local result:TDecimal = New TDecimal()
		Local status:UInt
		mpd_qrescale(result.mpdPtr, mpdPtr, exponent, context.context, status)
		Return result
	End Method

	Rem
	bbdoc: Returns #True if the current decimal object has the same exponent as the #TDecimal value of @b, #False otherwise.
	End Rem
	Method SameQuantum:Int(b:TDecimal)
		Return mpd_same_quantum(mpdPtr, b.mpdPtr)
	End Method

	Rem
	bbdoc: If the current decimal object is finite after applying rounding and overflow/underflow checks, result is set to the simplest form of a with all trailing zeros removed.
	End Rem
	Method Reduce:TDecimal()
		Local result:TDecimal = New TDecimal()
		Local status:UInt
		mpd_qreduce(result.mpdPtr, mpdPtr, context.context, status)
		Return result
	End Method

	Rem
	bbdoc: Returns the largest integer less than or equal to the current decimal object.
	End Rem
	Method Floor:TDecimal()
		Local result:TDecimal = New TDecimal()
		Local status:UInt
		mpd_qfloor(result.mpdPtr, mpdPtr, context.context, status)
		Return result
	End Method

	Rem
	bbdoc: Returns the smallest integer greater than or equal to the current decimal object.
	End Rem
	Method Ceil:TDecimal()
		Local result:TDecimal = New TDecimal()
		Local status:UInt
		mpd_qceil(result.mpdPtr, mpdPtr, context.context, status)
		Return result
	End Method

	Rem
	bbdoc: Truncates the current decimal object to an integer, rounding towards zero.
	End Rem
	Method Trunc:TDecimal()
		Local result:TDecimal = New TDecimal()
		Local status:UInt
		mpd_qtrunc(result.mpdPtr, mpdPtr, context.context, status)
		Return result
	End Method

	Rem
	bbdoc: Returns the maximum of the current decimal object and the #TDecimal value of @b.
	End Rem
	Method Max:TDecimal(b:TDecimal)
		Local result:TDecimal = New TDecimal()
		Local status:UInt
		mpd_qmax(result.mpdPtr, mpdPtr, b.mpdPtr, context.context, status)
		Return result
	End Method

	Rem
	bbdoc: Returns the minimum of the current decimal object and the #TDecimal value of @b.
	End Rem
	Method Min:TDecimal(b:TDecimal)
		Local result:TDecimal = New TDecimal()
		Local status:UInt
		mpd_qmin(result.mpdPtr, mpdPtr, b.mpdPtr, context.context, status)
		Return result
	End Method

	Rem
	bbdoc: Returns #True if the decimal number is finite, #False otherwise.
	End Rem
	Method IsFinite:Int()
		Return mpd_isfinite(mpdPtr)
	End Method

	Rem
	bbdoc: Returns #True if the decimal number is infinite, #False otherwise.
	End Rem
	Method IsInfinite:Int()
		Return mpd_isinfinite(mpdPtr)
	End Method

	Rem
	bbdoc: Returns #True if the decimal number is NaN, #False otherwise.
	End Rem
	Method IsNaN:Int()
		Return mpd_isnan(mpdPtr)
	End Method

	Rem
	bbdoc: Returns #True if the decimal number is negative, #False otherwise.
	End Rem
	Method IsNegative:Int()
		Return mpd_isnegative(mpdPtr)
	End Method

	Rem
	bbdoc: Returns 0 if the decimal is special or zero, or the exponent is less than emin. Return 1 otherwise.
	End Rem
	Method IsNormal:Int()
		Return mpd_isnormal(mpdPtr)
	End Method

	Rem
	bbdoc: Returns #True if the decimal number is positive, #False otherwise.
	End Rem
	Method IsPositive:Int()
		Return mpd_ispositive(mpdPtr)
	End Method

	Rem
	bbdoc: Returns #True if the decimal number is signed, #False otherwise.
	End Rem
	Method IsSigned:Int()
		Return mpd_issigned(mpdPtr)
	End Method

	Rem
	bbdoc: Returns #True if the decimal number is special, #False otherwise.
	End Rem
	Method IsSpecial:Int()
		Return mpd_isspecial(mpdPtr)
	End Method

	Rem
	bbdoc: Returns #True if the decimal number is zero, #False otherwise.
	End Rem
	Method IsZero:Int()
		Return mpd_iszero(mpdPtr)
	End Method

	Rem
	bbdoc: Return 0 if the decimal is special or zero, or the exponent is greater or equal to emin. Return 1 otherwise.
	End Rem
	Method IsSubnormal:Int()
		Return mpd_issubnormal(mpdPtr)
	End Method

	Rem
	bbdoc: Determines whether decimal is an (arbitrary precision) integer.
	about: The exponent of an integer is not necessarily zero and may be negative if the coefficient has trailing zeros.
	End Rem
	Method IsInteger:Int()
		Return mpd_isinteger(mpdPtr)
	End Method

	Rem
	bbdoc: Determine whether an integer is odd.
	about: This method is undefined for non-integers, so it should only be used after calling #IsInteger.
	End Rem
	Method IsOdd:Int()
		Return mpd_isodd(mpdPtr)
	End Method

	Rem
	bbdoc: Determine whether an integer is even.
	about: This method is undefined for non-integers, so it should only be used after calling #IsInteger.
	End Rem
	Method IsEven:Int()
		Return mpd_iseven(mpdPtr)
	End Method

	Rem
	bbdoc: Returns the sign flag, which is 0 for positive decimals and 1 for negative.
	End Rem
	Method Sign:Int()
		Return mpd_sign(mpdPtr)
	End Method

	Rem
	bbdoc: Returns 1 for positive decimals and -1 for negative.
	End Rem
	Method ArithSign:Int()
		Return mpd_arith_sign(mpdPtr)
	End Method

	Rem
	bbdoc: Performs checks the exponent limits and performs rounding.
	about: The following conditions can occur:
	MPD_Clamped, MPD_Inexact, MPD_Overflow, MPD_Rounded, MPD_Subnormal, MPD_Underflow
	End Rem
	Method Finalize()
		Local status:UInt
		mpd_qfinalize(mpdPtr, context.context, status)
	End Method

	Rem
	bbdoc: Returns a string representation of the decimal number.
	End Rem
	Method ToString:String() Override
		Local status:UInt
		Return bmx_mpd_to_string(mpdPtr, context.context, status)
	End Method

	Rem
	bbdoc: Returns a science string representation of the decimal number.
	about: The caps parameter determines whether the exponent is in uppercase or lowercase.
	End Rem
	Method ToSciString:String(caps:Int = True)
		Return bmx_mpd_to_sci(mpdPtr, caps)
	End Method

	Rem
	bbdoc: Returns an engineering string representation of the decimal number.
	about: The caps parameter determines whether the exponent is in uppercase or lowercase.
	End Rem
	Method ToEngString:String(caps:Int = True)
		Return bmx_mpd_to_eng(mpdPtr, caps)
	End Method

	Rem
	bbdoc: Returns the #Int value of the decimal number.
	about: If the decimal number is not an integer, it is truncated towards zero before conversion. If the result of the conversion does not fit into an #Int, a #TDecimalValueException is thrown.
	End Rem
	Method ToInt:Int()
		Local status:UInt
		Local result:Int
		If IsInteger() Then
			result = mpd_qget_i32(mpdPtr, status)
			If status & MPD_ConversionErrors Then
				Throw New TDecimalValueException("Cannot convert to an Int")
			End If
		Else
			Local d:TDecimal = Trunc()
			result = mpd_qget_i32(d.mpdPtr, status)
			If status & MPD_ConversionErrors Then
				Throw New TDecimalValueException("Cannot convert to an Int")
			End If
		End If
		Return result
	End Method

	Rem
	bbdoc: Returns the #UInt value of the decimal number.
	about: If the decimal number is not an integer, it is truncated towards zero before conversion. If the result of the conversion does not fit into a #UInt, a #TDecimalValueException is thrown.
	End Rem
	Method ToUInt:UInt()
		Local status:UInt
		Local result:UInt
		If IsInteger() Then
			result = mpd_qget_u32(mpdPtr, status)
			If status & MPD_ConversionErrors Then
				Throw New TDecimalValueException("Cannot convert to a UInt")
			End If
		Else
			Local d:TDecimal = Trunc()
			result = mpd_qget_u32(d.mpdPtr, status)
			If status & MPD_ConversionErrors Then
				Throw New TDecimalValueException("Cannot convert to a UInt")
			End If
		End If
		Return result
	End Method

	Rem
	bbdoc: Returns the #Long value of the decimal number.
	about: If the decimal number is not an integer, it is truncated towards zero before conversion. If the result of the conversion does not fit into a #Long, a #TDecimalValueException is thrown.
	End Rem
	Method ToLong:Long()
		Local status:UInt
		Local result:Long
		If IsInteger() Then
			result = mpd_qget_i64(mpdPtr, status)
			If status & MPD_ConversionErrors Then
				Throw New TDecimalValueException("Cannot convert to a Long")
			End If
		Else
			Local d:TDecimal = Trunc()
			result = mpd_qget_i64(d.mpdPtr, status)
			If status & MPD_ConversionErrors Then
				Throw New TDecimalValueException("Cannot convert to a Long")
			End If
		End If
		Return result
	End Method

	Rem
	bbdoc: Returns the #ULong value of the decimal number.
	about: If the decimal number is not an integer, it is truncated towards zero before conversion. If the result of the conversion does not fit into a #ULong, a #TDecimalValueException is thrown.
	End Rem
	Method ToULong:ULong()
		Local status:UInt
		Local result:ULong
		If IsInteger() Then
			result = mpd_qget_u64(mpdPtr, status)
			If status & MPD_ConversionErrors Then
				Throw New TDecimalValueException("Cannot convert to a ULong")
			End If
		Else
			Local d:TDecimal = Trunc()
			result = mpd_qget_u64(d.mpdPtr, status)
			If status & MPD_ConversionErrors Then
				Throw New TDecimalValueException("Cannot convert to a ULong")
			End If
		End If
		Return result
	End Method

	Method Delete()
		If value.data <> ULong Ptr(data) Then
			mpd_del(mpdPtr)
		End If
	End Method

End Type

Rem
bbdoc: Returns a new #TDecimal object with the value of the string passed in.
End Rem
Function Decimal:TDecimal(value:String)
	Return New TDecimal(value)
End Function

Rem
bbdoc: Returns a new #TDecimal object with the value of the integer passed in.
End Rem
Function Decimal:TDecimal(value:Int)
	Return New TDecimal(value)
End Function

Rem
bbdoc: Returns a new #TDecimal object with the value of the unsigned integer passed in.
End Rem
Function Decimal:TDecimal(value:UInt)
	Return New TDecimal(value)
End Function

Rem
bbdoc: Returns a new #TDecimal object with the value of the long passed in.
End Rem
Function Decimal:TDecimal(value:Long)
	Return New TDecimal(value)
End Function

Rem
bbdoc: Returns a new #TDecimal object with the value of the unsigned long passed in.
End Rem
Function Decimal:TDecimal(value:ULong)
	Return New TDecimal(value)
End Function

Rem
bbdoc: A context for decimal arithmetic operations, containing settings such as precision, rounding mode, and status flags.
End Rem
Type TMpdContext
	Field context:SMpdContext

	Rem
	bbdoc: Creates a new #TMpdContext object with the default settings.
	about: The defaults are `prec=2 * MPD_RDIGITS`, `emax=MPD_MAX_EMAX`, `emin=MPD_MIN_EMIN`, `round=MPD_ROUND_HALF_UP`, `clamp=0`, `status=0`, `traps=MPD_Traps`, `cr=0` and `allcr=1`.
	End Rem
	Function CreateDefault:TMpdContext()
		Local this:TMpdContext = New TMpdContext
		mpd_defaultcontext(this.context)
		Return this
	End Function

	Rem
	bbdoc: Creates a new #TMpdContext object with the maximum settings.
	about: The maximum settings are `prec=MPD_MAX_PREC`, `emax=MPD_MAX_EMAX`, `emin=MPD_MIN_EMIN`, `round=MPD_ROUND_HALF_EVEN`, `clamp=0`, `status=0`, `traps=MPD_Traps`, `cr=0` and `allcr=1`.
	End Rem
	Function CreateMax:TMpdContext()
		Local this:TMpdContext = New TMpdContext
		mpd_maxcontext(this.context)
		Return this
	End Function

	Rem
	bbdoc: Creates a new #TMpdContext object with the basic settings.
	about: The basic settings are `prec=9`, `emax=MPD_MAX_EMAX`, `emin=MPD_MIN_EMIN`, `round=MPD_ROUND_HALF_UP`, `clamp=0`, `status=0`, `traps=MPD_Traps | MPD_Clamped`, `cr=0` and `allcr=1`.
	End Rem
	Function CreateBasic:TMpdContext()
		Local this:TMpdContext = New TMpdContext
		mpd_basiccontext(this.context)
		Return this
	End Function

	Rem
	bbdoc: Creates a new #TMpdContext object with IEEE settings.
	about: @bits must be a multiple of 32 and less than IEEE_CONTEXT_MAX_BITS.

	For the most common values, the following constants are provided:
	
	|     | MPD_DECIMAL32 | MPD_DECIMAL64 | MPD_DECIMAL128 |
	| --- | ------------- | ------------- | -------------- |
	| prec | 7 | 16 | 34 |
	| emax | 96 | 384 | 6144 |
	| emin | -95 | -383 | -6143 |
	| round | MPD_ROUND_HALF_EVEN | MPD_ROUND_HALF_EVEN | MPD_ROUND_HALF_EVEN |
	| traps | 0 | 0 | 0 |
	| status | 0 | 0 | 0 |
	| newtrap | 0 | 0 | 0 |
	| clamp | 1 | 1 | 1 |
	| allcr | 1 | 1 | 1 |

	End Rem
	Function CreateIEEE:TMpdContext(bits:Int, result:Int Var)
		Local this:TMpdContext = New TMpdContext
		result = mpd_ieee_context(this.context, bits)
		Return this
	End Function

	Rem
	bbdoc: Sets the precision of the context.
	End Rem
	?Ptr64
	Method SetPrec:Int(prec:Long)
	?Ptr32
	Method SetPrec:Int(prec:Int)
	?
		Return mpd_qsetprec(context, prec)
	End Method

	Rem
	bbdoc: Gets the precision of the context.
	End Rem
	?Ptr64
	Method GetPrec:Long()
	?Ptr32
	Method GetPrec:Int()
	?
		Return mpd_getprec(context)
	End Method

	Rem
	bbdoc: Sets the maximum exponent of the context.
	End Rem
	?Ptr64
	Method SetEmax:Int(emax:Long)
	?Ptr32
	Method SetEmax:Int(emax:Int)
	?
		Return mpd_qsetemax(context, emax)
	End Method

	Rem
	bbdoc: Gets the maximum exponent of the context.
	End Rem
	?Ptr64
	Method GetEmax:Long()
	?Ptr32
	Method GetEmax:Int()
	?
		Return mpd_getemax(context)
	End Method

	Rem
	bbdoc: Sets the minimum exponent of the context.
	End Rem
	?Ptr64
	Method SetEmin:Int(emin:Long)
	?Ptr32
	Method SetEmin:Int(emin:Int)
	?
		Return mpd_qsetemin(context, emin)
	End Method

	Rem
	bbdoc: Gets the minimum exponent of the context.
	End Rem
	?Ptr64
	Method GetEmin:Long()
	?Ptr32
	Method GetEmin:Int()
	?
		Return mpd_getemin(context)
	End Method
	
	Rem
	bbdoc: Sets the rounding mode of the context.
	End Rem
	Method SetRound:Int(newround:ERoundingMode)
		Return mpd_qsetround(context, newround)
	End Method

	Method GetRound:ERoundingMode()
		Return mpd_getround(context)
	End Method

	Method SetClamp:Int(clamp:EClampMode)
		Return mpd_qsetclamp(context, clamp)
	End Method

	Method GetClamp:EClampMode()
		Return mpd_getclamp(context)
	End Method

	Method SetStatus:Int(status:UInt)
		Return mpd_qsetstatus(context, status)
	End Method

	Method GetStatus:Int()
		Return mpd_getstatus(context)
	End Method

	Method SetTraps:Int(traps:UInt)
		Return mpd_qsettraps(context, traps)
	End Method

	Method GetTraps:Int()
		Return mpd_gettraps(context)
	End Method

	Method SetCr:Int(cr:Int)
		Return mpd_qsetcr(context, cr)
	End Method

	Method GetCr:Int()
		Return mpd_getcr(context)
	End Method

	Method Raise(flags:UInt)
		context.status :| (flags & ~MPD_Malloc_error)
		Local active_traps:UInt = flags & (context.traps | MPD_Malloc_error)
		If active_traps Then
			Throw New TDecimalException("Decimal exception raised with flags: " + active_traps)
		End If
	End Method

End Type

Type TDecimalException Extends TRuntimeException

End Type

Type TDecimalValueException Extends TDecimalException

End Type

Type TDecimalDivisionByZeroException Extends TDecimalException

End Type

TDecimal.SetDefaultContext()
