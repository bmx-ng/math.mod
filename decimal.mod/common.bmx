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

Import "source.bmx"

Const INT_MAX:Int = 2147483647

?Ptr64
Const MPD_IEEE_CONTEXT_MAX_BITS:Int = 512
?Ptr32
Const MPD_IEEE_CONTEXT_MAX_BITS:Int = 256
?
Const MPD_DECIMAL32:Int = 32
Const MPD_DECIMAL64:Int = 64
Const MPD_DECIMAL128:Int = 128


Const MPD_POS:Byte = 0
Const MPD_NEG:Byte = 1
Const MPD_INF:Byte = 2
Const MPD_NAN:Byte = 4
Const MPD_SNAN:Byte = 8
Const MPD_SPECIAL:Byte = MPD_INF|MPD_NAN|MPD_SNAN
Const MPD_STATIC:Byte = 16
Const MPD_STATIC_DATA:Byte = 32
Const MPD_SHARED_DATA:Byte = 64
Const MPD_CONST_DATA:Byte = 128
Const MPD_DATAFLAGS:Byte = MPD_STATIC_DATA|MPD_SHARED_DATA|MPD_CONST_DATA

Rem
bbdoc: Rounding modes for the context.
about:

| Mode | Description |
| --- | --- |
| Round_Up | Round away from 0 |
| Round_Down | Round toward 0 (truncate) |
| Round_Ceiling | Round toward +infinity |
| Round_Floor | Round toward -infinity |
| Round_HalfUp | 0.5 is rounded up |
| Round_HalfDown | 0.5 is rounded down |
| Round_HalfEven | 0.5 is rounded to even |
| Round_05Up | Round zero or five away from 0 |
| Round_Trunc | Truncate, but set infinity |
| Round_Guard | Guard digits are used to reduce rounding errors in some operations. |

End Rem
Enum ERoundingMode
	Round_Up = 0
	Round_Down = 1
	Round_Ceiling = 2
	Round_Floor = 3
	Round_HalfUp = 4
	Round_HalfDown = 5
	Round_HalfEven = 6
	Round_05Up = 7
	Round_Trunc = 8
	Round_Guard = 9
End Enum

Rem
bbdoc: Clamping modes for the context.
End Rem
Enum EClampMode
	Clamp_Default = 0
	Clamp_IEEE_754 = 1
	Clamp_Guard = 2
End Enum

Const MPD_Clamped:UInt = $00000001
Const MPD_Conversion_syntax:UInt = $00000002
Const MPD_Division_by_zero:UInt = $00000004
Const MPD_Division_impossible:UInt = $00000008
Const MPD_Division_undefined:UInt = $00000010
Const MPD_Fpu_error:UInt = $00000020
Const MPD_Inexact:UInt = $00000040
Const MPD_Invalid_context:UInt = $00000080
Const MPD_Invalid_operation:UInt = $00000100
Const MPD_Malloc_error:UInt = $00000200
Const MPD_Not_implemented:UInt = $00000400
Const MPD_Overflow:UInt = $00000800
Const MPD_Rounded:UInt = $00001000
Const MPD_Subnormal:UInt = $00002000
Const MPD_Underflow:UInt = $00004000
Const MPD_Max_status:UInt = $00007FFF

Const MPD_ConversionErrors:UInt = MPD_Invalid_operation | MPD_Division_by_zero | MPD_Overflow

Struct SMpdContext
?Ptr64
	Field prec:Long   ' precision
	Field emax:Long   ' max positive exp
	Field emin:Long   ' min negative exp
?Ptr32
	Field prec:Int   ' precision
	Field emax:Int   ' max positive exp
	Field emin:Int   ' min negative exp
?
	Field traps:UInt   ' status events that should be trapped
	Field status:UInt   ' status flags
	Field newtrap:UInt   ' set by mpd_addstatus_raise()
	Field round:ERoundingMode   ' rounding mode
	Field clamp:EClampMode   ' clamp mode
	Field allcr:Int   '

End Struct

Struct SMpd
	Field flags:Byte = MPD_STATIC|MPD_STATIC_DATA|MPD_SNAN
?Ptr64
	Field exp:Long
	Field digits:Long
	Field len:Long
	Field alloc:Long = 4
	Field data:ULong Ptr
?Ptr32
	Field exp:Int
	Field digits:Int
	Field len:Int
	Field alloc:Int = 4
	Field data:UInt Ptr
?
End Struct

Extern
	Function mpd_defaultcontext(context:SMpdContext Var)
	Function mpd_maxcontext(context:SMpdContext Var)
	Function mpd_basiccontext(context:SMpdContext Var)
	Function mpd_ieee_context:Int(context:SMpdContext Var, bits:Int)

	Function mpd_new:Byte Ptr(context:SMpdContext Var)
	Function mpd_del(handle:Byte Ptr)

	Function mpd_qadd(result:Byte Ptr, a:Byte Ptr, b:Byte Ptr, context:SMpdContext Var, status:UInt Var)
	Function mpd_qsub(result:Byte Ptr, a:Byte Ptr, b:Byte Ptr, context:SMpdContext Var, status:UInt Var)
	Function mpd_qmul(result:Byte Ptr, a:Byte Ptr, b:Byte Ptr, context:SMpdContext Var, status:UInt Var)
	Function mpd_qdiv(result:Byte Ptr, a:Byte Ptr, b:Byte Ptr, context:SMpdContext Var, status:UInt Var)
	Function mpd_qadd_i32(result:Byte Ptr, a:Byte Ptr, b:Int, context:SMpdContext Var, status:UInt Var)
	Function mpd_qsub_i32(result:Byte Ptr, a:Byte Ptr, b:Int, context:SMpdContext Var, status:UInt Var)
	Function mpd_qmul_i32(result:Byte Ptr, a:Byte Ptr, b:Int, context:SMpdContext Var, status:UInt Var)
	Function mpd_qdiv_i32(result:Byte Ptr, a:Byte Ptr, b:Int, context:SMpdContext Var, status:UInt Var)
	Function mpd_qadd_u32(result:Byte Ptr, a:Byte Ptr, b:UInt, context:SMpdContext Var, status:UInt Var)
	Function mpd_qsub_u32(result:Byte Ptr, a:Byte Ptr, b:UInt, context:SMpdContext Var, status:UInt Var)
	Function mpd_qmul_u32(result:Byte Ptr, a:Byte Ptr, b:UInt, context:SMpdContext Var, status:UInt Var)
	Function mpd_qdiv_u32(result:Byte Ptr, a:Byte Ptr, b:UInt, context:SMpdContext Var, status:UInt Var)
	Function mpd_qadd_i64(result:Byte Ptr, a:Byte Ptr, b:Long, context:SMpdContext Var, status:UInt Var)
	Function mpd_qsub_i64(result:Byte Ptr, a:Byte Ptr, b:Long, context:SMpdContext Var, status:UInt Var)
	Function mpd_qmul_i64(result:Byte Ptr, a:Byte Ptr, b:Long, context:SMpdContext Var, status:UInt Var)
	Function mpd_qdiv_i64(result:Byte Ptr, a:Byte Ptr, b:Long, context:SMpdContext Var, status:UInt Var)
	Function mpd_qadd_u64(result:Byte Ptr, a:Byte Ptr, b:ULong, context:SMpdContext Var, status:UInt Var)
	Function mpd_qsub_u64(result:Byte Ptr, a:Byte Ptr, b:ULong, context:SMpdContext Var, status:UInt Var)
	Function mpd_qmul_u64(result:Byte Ptr, a:Byte Ptr, b:ULong, context:SMpdContext Var, status:UInt Var)
	Function mpd_qdiv_u64(result:Byte Ptr, a:Byte Ptr, b:ULong, context:SMpdContext Var, status:UInt Var)
						
?Ptr64
	Function mpd_qsetprec:Int(context:SMpdContext Var, prec:Long)
	Function mpd_qsetemax:Int(context:SMpdContext Var, emax:Long)
	Function mpd_qsetemin:Int(context:SMpdContext Var, emin:Long)
?Ptr32
	Function mpd_qsetprec:Int(context:SMpdContext Var, prec:Int)
	Function mpd_qsetemax:Int(context:SMpdContext Var, emax:Int)
	Function mpd_qsetemin:Int(context:SMpdContext Var, emin:Int)
?
	Function mpd_qsetround:Int(context:SMpdContext Var, round:ERoundingMode)
	Function mpd_qsettraps:Int(context:SMpdContext Var, traps:UInt)
	Function mpd_qsetstatus:Int(context:SMpdContext Var, status:UInt)
	Function mpd_qsetclamp:Int(context:SMpdContext Var, clamp:EClampMode)
	Function mpd_qsetcr:Int(context:SMpdContext Var, allcr:Int)

?Ptr64
	Function mpd_getprec:Long(context:SMpdContext Var)
	Function mpd_getemax:Long(context:SMpdContext Var)
	Function mpd_getemin:Long(context:SMpdContext Var)
?Ptr32
	Function mpd_getprec:Int(context:SMpdContext Var)
	Function mpd_getemax:Int(context:SMpdContext Var)
	Function mpd_getemin:Int(context:SMpdContext Var)
?
	Function mpd_getround:ERoundingMode(context:SMpdContext Var)
	Function mpd_gettraps:Int(context:SMpdContext Var)
	Function mpd_getstatus:Int(context:SMpdContext Var)
	Function mpd_getclamp:EClampMode(context:SMpdContext Var)
	Function mpd_getcr:Int(context:SMpdContext Var)

	Function mpd_set_i32(result:Byte Ptr, value:Int, context:SMpdContext Var)
	Function mpd_set_u32(result:Byte Ptr, value:UInt, context:SMpdContext Var)
	Function mpd_set_i64(result:Byte Ptr, value:Long, context:SMpdContext Var)
	Function mpd_set_u64(result:Byte Ptr, value:ULong, context:SMpdContext Var)

	Function mpd_isfinite:Int(handle:Byte Ptr)
	Function mpd_isinfinite:Int(handle:Byte Ptr)
	Function mpd_isnan:Int(handle:Byte Ptr)
	Function mpd_isnegative:Int(handle:Byte Ptr)
	Function mpd_isnormal:Int(handle:Byte Ptr)
	Function mpd_issubnormal:Int(handle:Byte Ptr)
	FUnction mpd_ispositive:Int(handle:Byte Ptr)
	Function mpd_iszero:Int(handle:Byte Ptr)
	Function mpd_isspecial:Int(handle:Byte Ptr)
	Function mpd_isinteger:Int(handle:Byte Ptr)
	Function mpd_issigned:Int(handle:Byte Ptr)
	Function mpd_isodd:Int(handle:Byte Ptr)
	Function mpd_iseven:Int(handle:Byte Ptr)
	Function mpd_sign:Int(handle:Byte Ptr)
	Function mpd_arith_sign:Int(handle:Byte Ptr)

	Function bmx_mpd_set_string(result:Byte Ptr, value:String, context:SMpdContext Var)
	Function bmx_mpd_to_sci:String(result:Byte Ptr, caps:Int)
	Function bmx_mpd_to_eng:String(result:Byte Ptr, caps:Int)
	Function bmx_mpd_to_string:String(result:Byte Ptr, context:SMpdContext Var, status:UInt Var)

	Function mpd_qshift(result:Byte Ptr, a:Byte Ptr, b:Byte Ptr, context:SMpdContext Var, status:UInt Var)
?Ptr64
	Function mpd_qshiftn(result:Byte Ptr, a:Byte Ptr, n:Long, context:SMpdContext Var, status:UInt Var)
?Ptr32
	Function mpd_qshiftn(result:Byte Ptr, a:Byte Ptr, n:Int, context:SMpdContext Var, status:UInt Var)
?
	Function mpd_qfinalize(result:Byte Ptr, context:SMpdContext Var, status:UInt Var)

	Function mpd_qcopy_cxx:Int(result:Byte Ptr, a:Byte Ptr)

	Function mpd_qcmp:Int(a:Byte Ptr, b:Byte Ptr, status:UInt Var)
	Function bmx_mpd_qset_string_exact(result:Byte Ptr, value:String, status:UInt Var)

	Function mpd_qset_i32(result:Byte Ptr, a:Int, context:SMpdContext Var, status:UInt Var)
	Function mpd_qset_u32(result:Byte Ptr, a:UInt, context:SMpdContext Var, status:UInt Var)
	Function mpd_qset_i64_exact(result:Byte Ptr, a:Long, status:UInt Var)
	Function mpd_qset_u64_exact(result:Byte Ptr, a:ULong, status:UInt Var)

	Function mpd_qdivint(result:Byte Ptr, a:Byte Ptr, b:Byte Ptr, context:SMpdContext Var, status:UInt Var)
	Function mpd_qrem(result:Byte Ptr, a:Byte Ptr, b:Byte Ptr, context:SMpdContext Var, status:UInt Var)
	Function mpd_qrem_near(result:Byte Ptr, a:Byte Ptr, b:Byte Ptr, context:SMpdContext Var, status:UInt Var)
	Function mpd_qdivmod(result:Byte Ptr, _rem:Byte Ptr, a:Byte Ptr, b:Byte Ptr, context:SMpdContext Var, status:UInt Var)
	Function mpd_qpow(result:Byte Ptr, base:Byte Ptr, exp:Byte Ptr, context:SMpdContext Var, status:UInt Var)
	Function mpd_qpowmod(result:Byte Ptr, base:Byte Ptr, exp:Byte Ptr, _mod:Byte Ptr, context:SMpdContext Var, status:UInt Var)
	Function mpd_qexp(result:Byte Ptr, a:Byte Ptr, context:SMpdContext Var, status:UInt Var)
	Function mpd_qln10(result:Byte Ptr, prec:Int, status:UInt Var)
	Function mpd_qln(result:Byte Ptr, a:Byte Ptr, context:SMpdContext Var, status:UInt Var)
	Function mpd_qlog10(result:Byte Ptr, a:Byte Ptr, context:SMpdContext Var, status:UInt Var)
	Function mpd_qsqrt(result:Byte Ptr, a:Byte Ptr, context:SMpdContext Var, status:UInt Var)
	Function mpd_qinvroot(result:Byte Ptr, a:Byte Ptr, context:SMpdContext Var, status:UInt Var)
	Function mpd_qminus(result:Byte Ptr, a:Byte Ptr, context:SMpdContext Var, status:UInt Var)
	Function mpd_qplus(result:Byte Ptr, a:Byte Ptr, context:SMpdContext Var, status:UInt Var)
	Function mpd_qabs(result:Byte Ptr, a:Byte Ptr, context:SMpdContext Var, status:UInt Var)

	Function mpd_qquantize(result:Byte Ptr, a:Byte Ptr, b:Byte Ptr, context:SMpdContext Var, status:UInt Var)
?Ptr64
	Function mpd_qrescale(result:Byte Ptr, a:Byte Ptr, exp:Long, context:SMpdContext Var, status:UInt Var)
?Ptr32
	Function mpd_qrescale(result:Byte Ptr, a:Byte Ptr, exp:Int, context:SMpdContext Var, status:UInt Var)
?
	Function mpd_same_quantum:Int(a:Byte Ptr, b:Byte Ptr)
	Function mpd_qreduce(result:Byte Ptr, a:Byte Ptr, context:SMpdContext Var, status:UInt Var)
	Function mpd_qtrunc(result:Byte Ptr, a:Byte Ptr, context:SMpdContext Var, status:UInt Var)
	Function mpd_qfloor(result:Byte Ptr, a:Byte Ptr, context:SMpdContext Var, status:UInt Var)
	Function mpd_qceil(result:Byte Ptr, a:Byte Ptr, context:SMpdContext Var, status:UInt Var)
	Function mpd_qmax(result:Byte Ptr, a:Byte Ptr, b:Byte Ptr, context:SMpdContext Var, status:UInt Var)
	Function mpd_qmin(result:Byte Ptr, a:Byte Ptr, b:Byte Ptr, context:SMpdContext Var, status:UInt Var)

	Function mpd_qand(result:Byte Ptr, a:Byte Ptr, b:Byte Ptr, context:SMpdContext Var, status:UInt Var)
	Function mpd_qor(result:Byte Ptr, a:Byte Ptr, b:Byte Ptr, context:SMpdContext Var, status:UInt Var)
	Function mpd_qxor(result:Byte Ptr, a:Byte Ptr, b:Byte Ptr, context:SMpdContext Var, status:UInt Var)

	Function mpd_qget_i32:Int(handle:Byte Ptr, status:UInt Var)
	Function mpd_qget_u32:UInt(handle:Byte Ptr, status:UInt Var)
	Function mpd_qget_i64:Long(handle:Byte Ptr, status:UInt Var)
	Function mpd_qget_u64:ULong(handle:Byte Ptr, status:UInt Var)
End Extern
