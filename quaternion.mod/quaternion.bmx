' Copyright (c) 2020-2023 Bruce A Henderson
'
' This software is provided 'as-is', without any express or implied
' warranty. In no event will the authors be held liable for any damages
' arising from the use of this software.
' 
' Permission is granted to anyone to use this software for any purpose,
' including commercial applications, and to alter it and redistribute it
' freely, subject to the following restrictions:
' 
'    1. The origin of this software must not be misrepresented; you must not
'    claim that you wrote the original software. If you use this software
'    in a product, an acknowledgment in the product documentation would be
'    appreciated but is not required.
' 
'    2. Altered source versions must be plainly marked as such, and must not be
'    misrepresented as being the original software.
' 
'    3. This notice may not be removed or altered from any source
'    distribution.
' 
SuperStrict

Rem
bbdoc: Math/Quaternion
End Rem
Module Math.Quaternion

ModuleInfo "Version: 1.03"
ModuleInfo "Author: Bruce A Henderson"
ModuleInfo "License: zlib"
ModuleInfo "Copyright: 2020-2023 Bruce A Henderson"

ModuleInfo "History: 1.03"
ModuleInfo "History: Moved to Math.Quaternion."
ModuleInfo "History: 1.02"
ModuleInfo "History: Fixed Normal()."
ModuleInfo "History: Refactored Euler methods. Added rotation enum."
ModuleInfo "History: 1.01"
ModuleInfo "History: Fixed Euler conversions."
ModuleInfo "History: 1.00"
ModuleInfo "History: Initial Release"

Import BRL.Math
Import Math.Matrix
Import BRL.StringBuilder

Rem
bbdoc: A Quaternion.
about: Quaternions are used to represent 3D rotations.
about: They are compact, don't suffer from gimbal lock, and can easily be interpolated.
Quaternions consist of four components (x, y, z, w), where x, y, z form the vector part,
and w is the scalar part.
End Rem
Struct SQuatD
	Field x:Double
	Field y:Double
	Field z:Double
	Field w:Double
	
	Method New()
		Self.w = 1
	End Method
	
	Rem
	bbdoc: Creates a new #SQuatD instance with the supplied @x, @y, @z, and @w components.
	End Rem
	Method New(x:Double, y:Double, z:Double, w:Double = 1)
		Self.x = x
		Self.y = y
		Self.z = z
		Self.w = w
	End Method
	
	Rem
	bbdoc: Creates a new #SQuatD instance from the rotation specified by the Euler angles and the rotation @order.
	End Rem
	Function CreateFromEuler:SQuatD(euler:SVec3D, order:ERotationOrder = ERotationOrder.XYZ)
		Return New SQuatD.EulerRotate(euler, order)
	End Function
	
	Rem
	bbdoc: Creates a new #SQuatD instance from the rotation component of the 4x4 matrix @mat.
	about: see http://www.euclideanspace.com/maths/geometry/rotations/conversions/matrixToQuaternion/index.htm
	End Rem
	Function CreateFromRotation:SQuatD(mat:SMat4D)
		Local trace:Double = mat.a + mat.f + mat.k
		
		If trace > 0 Then
		
			Local s:Double = 0.5 / Sqr( trace + 1 )
			
			Return New SQuatD((mat.g - mat.j) * s, (mat.i - mat.c) * s, (mat.b - mat.e) * s, 0.25 / s)
		
		Else If mat.a > mat.f And mat.a > mat.k Then
		
			Local s:Double = 2.0 * Sqr(1.0 + mat.a - mat.f - mat.k)
			
			Return New SQuatD(0.25 * s, (mat.e + mat.b) / s, (mat.i + mat.c) / s, (mat.g - mat.j) / s)
		
		Else If mat.f > mat.k Then
		
			Local s:Double = 2.0 * Sqr(1.0 + mat.f - mat.a - mat.k)
		
			Return New SQuatD((mat.e + mat.b) / s, 0.25 * s, (mat.j + mat.g) / s, (mat.i - mat.c) / s)
		
		Else
		
			Local s:Double = 2.0 * Sqr( 1.0 + mat.k - mat.a - mat.f )
		
			Return New SQuatD((mat.i + mat.c) / s, (mat.j + mat.g) / s, 0.25 * s, (mat.b - mat.e) / s)
			
		End If
		
	End Function

	Rem
	bbdoc: Converts the quaternion @a to a 3x3 rotation matrix, returning a new matrix that represents the same rotation as the quaternion.
	End Rem
	Function ToMat3:SMat3D(a:SQuatD)
		Local ax:Double = a.x
		Local ay:Double = a.y
		Local az:Double = a.z
		Local aw:Double = a.w
		Local ax2:Double = ax + ax
		Local ay2:Double = ay + ay
		Local az2:Double = az + az
		Local axx:Double = ax * ax2
		Local ayx:Double = ay * ax2
		Local ayy:Double = ay * ay2
		Local azx:Double = az * ax2
		Local azy:Double = az * ay2
		Local azz:Double = az * az2
		Local awx:Double = aw * ax2
		Local awy:Double = aw * ay2
		Local awz:Double = aw * az2
		Return New SMat3D(1 - (ayy + azz), ayx + awz, azx - awy, ayx - awz, 1.0 - (axx + azz), azy + awx, azx + awy, azy - awx, 1.0 - (axx + ayy))
	End Function

	Rem
	bbdoc: Converts the quaternion @a to a 4x4 rotation matrix, returning a new matrix that represents the same rotation as the quaternion.
	End Rem
	Function ToMat4:SMat4D(a:SQuatD)
		Local ax:Double = a.x
		Local ay:Double = a.y
		Local az:Double = a.z
		Local aw:Double = a.w
		Local ax2:Double = ax + ax
		Local ay2:Double = ay + ay
		Local az2:Double = az + az
		Local axx:Double = ax * ax2
		Local ayx:Double = ay * ax2
		Local ayy:Double = ay * ay2
		Local azx:Double = az * ax2
		Local azy:Double = az * ay2
		Local azz:Double = az * az2
		Local awx:Double = aw * ax2
		Local awy:Double = aw * ay2
		Local awz:Double = aw * az2
		Return New SMat4D(1.0 - (ayy + azz), ayx + awz, azx - awy, 0, ..
			ayx - awz, 1.0 - (axx + azz), azy + awx, 0, ..
			azx + awy, azy - awx, 1.0 - (axx + ayy), 0, ..
			0, 0, 0, 1)
	End Function	

	Rem
	bbdoc: Creates a 4x4 matrix that represents both translation and rotation.
	about: The returned matrix places objects at position @s, oriented with the rotation specified by quaternion @a.
	End Rem
	Function RotTrans:SMat4D(a:SQuatD, s:SVec3D)
		Local ax:Double = a.x
		Local ay:Double = a.y
		Local az:Double = a.x
		Local aw:Double = a.w
		Local ax2:Double = ax + ax
		Local ay2:Double = ay + ay
		Local az2:Double = az + az
		Local axx:Double = ax * ax2
		Local axy:Double = ax * ay2
		Local axz:Double = ax * az2
		Local ayy:Double = ay * ay2
		Local ayz:Double = ay * az2
		Local azz:Double = az * az2
		Local awx:Double = aw * ax2
		Local awy:Double = aw * ay2
		Local awz:Double = aw * az2
		Return New SMat4D(1.0 - (ayy + azz), axy + awz, axz - awy, 0, ..
			axy - awz, 1.0 - (axx + azz), ayz + awx, 0, ..
			axz + awy, ayz - awx, 1.0 - (axx + ayy), 0, ..
			s.x, s.y, s.z, 1)
	End Function
	
	Rem
	bbdoc: Creates a translation, rotation and scaling matrix.
	about: The returned matrix is such that it places objects at position @origin, oriented in rotation @a and scaled by @s.
	End Rem
	Function RotTransOrigin:SMat4D(a:SQuatD, s:SVec3D, origin:SVec3D)
		Local ax:Double = a.x
		Local ay:Double = a.y
		Local az:Double = a.x
		Local aw:Double = a.w
		Local ax2:Double = ax + ax
		Local ay2:Double = ay + ay
		Local az2:Double = az + az
		Local axx:Double = ax * ax2
		Local axy:Double = ax * ay2
		Local axz:Double = ax * az2
		Local ayy:Double = ay * ay2
		Local ayz:Double = ay * az2
		Local azz:Double = az * az2
		Local awx:Double = aw * ax2
		Local awy:Double = aw * ay2
		Local awz:Double = aw * az2
		Local ox:Double = origin.x
		Local oy:Double = origin.y
		Local oz:Double = origin.z
		Local o00:Double = 1.0 - (ayy + azz)
		Local o01:Double = axy + awz
		Local o02:Double = axz - awy
		Local o10:Double = axy - awz
		Local o11:Double = 1.0 - (axx + azz)
		Local o12:Double = ayz + awx
		Local o20:Double = axz + awy
		Local o21:Double = ayz - awx
		Local o22:Double = 1.0 - (axx + ayy)
		Return New SMat4D(o00, o01, o02, 0, ..
			o10, o11, o12, 0, ..
			o20, o21, o22, 0, ..
			s.x + ox - (o00 * ox + o10 * oy + o20 * oz), ..
			s.y + oy - (o01 * ox + o11 * oy + o21 * oz), ..
			s.z + oz - (o02 * ox + o12 * oy + o22 * oz), 1)
	End Function

	Rem
	bbdoc: Returns the angle (in degrees) between this quaternion and the quaternion @quat, representing the difference in their rotations.
	End Rem
	Method AngleTo:Double(quat:SQuatD)
		Local d:Double = Max(-1, Min( 1, dot(quat)))
		Return 114.591559026:Double * _acos(Abs(d))
	End Method
	
	Rem
	bbdoc: Calculates the dot product between this quaternion and quaternion b, which is useful for various mathematical operations, such as finding the angle between two rotations.
	End Rem
	Method Dot:Double(b:SQuatD)
		Return x * b.x + y * b.y + z * b.z + w * b.w
	End Method
	
	Rem
	bbdoc: Returns the inverse of this quaternion, representing the opposite rotation.
	End Rem
	Method Invert:SQuatD()
		Local dot:Double = x * x + y * y + z * z + w * w
		Local invdot:Double
		If dot <> 0 Then
			invdot = 1 / dot
		End If
		Return New SQuatD(-x * invdot, -y * invdot, -z * invdot, w * invdot)
	End Method
	
	Rem
	bbdoc: Performs linear interpolation between this quaternion and quaternion @b by the factor @t `(0 <= t <= 1)`, and normalizes the result afterwards.
	End Rem
	Method Interpolate:SQuatD(b:SQuatD, t:Double)
		Return New SQuatD(Lerp(x, b.x, t), Lerp(y, b.y, t), Lerp(z, b.z, t), Lerp(w, b.w, t))
	End Method
	
	Rem
	bbdoc: Computes the length (magnitude) of this quaternion when considered as a 4-dimensional vector.
	End Rem
	Method Length:Double()
		Return Sqr(x * x + y * y + z * z + w * w)
	End Method
	
	Rem
	bbdoc: Computes the squared length (squared magnitude) of this quaternion when considered as a 4-dimensional vector.
	about: Calculating the squared length instead of the length is much faster.
	Often if you are comparing lengths of two quaternions, you can just compare their squared lengths.
	End Rem
	Method LengthSquared:Double()
		Return x * x + y * y + z * z + w * w
	End Method
	
	Rem
	bbdoc: Multiplies this quaternion by quaternion @b, returning a new quaternion that represents the combined rotation.
	End Rem
	Method Operator*:SQuatD(b:SQuatD)
		Return New SQuatD(x * b.w + w * b.x + y * b.z - z * b.y, ..
			y * b.w + w * b.y + z * b.x - x * b.z, ..
			z * b.w + w * b.z + x * b.y - y * b.x, ..
			w * b.w - x * b.x - y * b.y - z * b.z)
	End Method
	
	Rem
	bbdoc: Returns a new quaternion with the negation of this quaternion's components, representing the inverse rotation.
	End Rem
	Method Operator-:SQuatD()
		Return New SQuatD(-x, -y, -z, -w)
	End Method
	
	Rem
	bbdoc: Returns the identity quaternion, representing no rotation (x=0, y=0, z=0, w=1).
	End Rem
	Function Identity:SQuatD()
		Return New SQuatD(0, 0, 0, 1)
	End Function
	
	Rem
	bbdoc: Normalizes this quaternion, resulting in a quaternion with the same orientation but with a magnitude of 1.
	End Rem
	Method Normal:SQuatD()
		Local length:Double = x * x + y * y + z * z + w * w
		If length = 0 Then
			Return New SQuatD(0, 0, 0, 1)
		Else
			length = 1 / Sqr(length)
			Return New SQuatD(x * length, y * length, z * length, w * length)
		End If
	End Method
	
	Rem
	bbdoc: Rotates this quaternion by an angular step @s (in degrees) towards the specified quaternion @quat.
	End Rem
	Method RotateTowards:SQuatD(quat:SQuatD, s:Double)
		Local angle:Double = AngleTo(quat)
		
		If angle = 0 Then
			Return Self
		End If
		
		Local t:Double = Min(1, s / angle)
		
		Return SphericalInterpolate(quat, t)
	End Method
	
	Rem
	bbdoc: Performs spherical linear interpolation (slerp) between this quaternion and quaternion @b by the factor @t `(0 <= t <= 1)`.
	End Rem
	Method SphericalInterpolate:SQuatD(b:SQuatD, t:Double)
		Local bx:Double = b.x
		Local by:Double = b.y
		Local bz:Double = b.z
		Local bw:Double = b.w
		Local scale0:Double
		Local scale1:Double

		Local cosom:Double = x * bx + y * by + z * bz + w * bw

		If cosom < 0 Then
			cosom = -cosom
			bx = -bx
			by = -by
			bz = -bz
			bw = -bw
		End If
		
		If 1 - cosom > 0.000001 Then
			Local omega:Double = _acos(cosom)
			Local sinom:Double = _sin(omega)
			scale0 = _sin((1.0 - t) * omega) / sinom
			scale1 = _sin(t * omega) / sinom
		Else
			scale0 = 1 - t
			scale1 = t
		End If
		
		Return New SQuatD(scale0 * x + scale1 * bx, scale0 * y + scale1 * by, scale0 * z + scale1 * bz, scale0 * w + scale1 * bw)
	End Method

	Rem
	bbdoc: Returns a quaternion representing a rotation around the Euler angles specified by @rot, using the specified rotation order.
	End Rem
	Method EulerRotate:SQuatD(rot:SVec3D, order:ERotationOrder = ERotationOrder.XYZ)
		Local cx:Double = Cos(rot.x * .5)
		Local cy:Double = Cos(rot.y * .5)
		Local cz:Double = Cos(rot.z * .5)
		Local sx:Double = Sin(rot.x * .5)
		Local sy:Double = Sin(rot.y * .5)
		Local sz:Double = Sin(rot.z * .5)

		Select order
			Case ERotationOrder.XYZ
				Return New SQuatD(sx * cy * cz + cx * sy * sz, ..
					cx * sy * cz - sx * cy * sz, ..
					cx * cy * sz + sx * sy * cz, ..
					cx * cy * cz - sx * sy * sz)
			Case ERotationOrder.XZY
				Return New SQuatD(sx * cy * cz - cx * sy * sz, ..
					cx * sy * cz - sx * cy * sz, ..
					cx * cy * sz + sx * sy * cz, ..
					cx * cy * cz + sx * sy * sz)
			Case ERotationOrder.YXZ
				Return New SQuatD(sx * cy * cz + cx * sy * sz, ..
					cx * sy * cz - sx * cy * sz, ..
					cx * cy * sz - sx * sy * cz, ..
					cx * cy * cz + sx * sy * sz)
			Case ERotationOrder.YZX
				Return New SQuatD(sx * cy * cz + cx * sy * sz, ..
					cx * sy * cz + sx * cy * sz, ..
					cx * cy * sz - sx * sy * cz, ..
					cx * cy * cz - sx * sy * sz)
			Case ERotationOrder.ZXY
				Return New SQuatD(sx * cy * cz - cx * sy * sz, ..
					cx * sy * cz + sx * cy * sz, ..
					cx * cy * sz + sx * sy * cz, ..
					cx * cy * cz - sx * sy * sz)
			Case ERotationOrder.ZYX
				Return New SQuatD(sx * cy * cz - cx * sy * sz, ..
					cx * sy * cz + sx * cy * sz, ..
					cx * cy * sz - sx * sy * cz, ..
					cx * cy * cz + sx * sy * sz)
		End Select
	End Method

	Rem
	bbdoc: Converts this quaternion to Euler angles (in degrees) using the specified rotation @order.
	End Rem
	Method ToEuler:SVec3D(order:ERotationOrder = ERotationOrder.XYZ)
		Local q:SQuatD = Normal()
		Local mat:SMat4D = ToMat4(q)
		
		Local x:Double
		Local y:Double
		Local z:Double

		Select order
			Case ERotationOrder.XYZ
				y = ASin( Max( -1, Min( 1, mat.i ) ) )
		
				If Abs(mat.i) < 0.9999999 Then
					x = ATan2( -mat.j, mat.k )
					z = ATan2( -mat.e, mat.a )
				Else
					x = ATan2( mat.g, mat.f )
				End If
				
			Case ERotationOrder.XZY
				z = ASin( -Max( -1, Min( 1, mat.e ) ) )

				If Abs(mat.e) < 0.9999999 Then
					x = ATan2( mat.g, mat.f )
					y = ATan2( mat.i, mat.a )
				Else
					x = ATan2( -mat.j, mat.k )
				End If

			Case ERotationOrder.YXZ
				x = ASin( -Max( -1, Min( 1, mat.j ) ) )
		
				If Abs(mat.j) < 0.9999999 Then
					y = ATan2( mat.i, mat.k )
					z = ATan2( mat.b, mat.f )
				Else
					y = ATan2( -mat.c, mat.a )
				End If
			
			Case ERotationOrder.YZX
				z = ASin( Max( -1, Min( 1, mat.b ) ) )
		
				If Abs(mat.b) < 0.9999999 Then
					x = ATan2( -mat.j, mat.f )
					y = ATan2( -mat.c, mat.a )
				Else
					y = ATan2( mat.i, mat.k )
				End If
			
			Case ERotationOrder.ZXY
				x = ASin( Max( -1, Min( 1, mat.g ) ) )
		
				If Abs(mat.g) < 0.9999999 Then
					y = ATan2( -mat.c, mat.k )
					z = ATan2( -mat.e, mat.f )
				Else
					z = ATan2( mat.b, mat.a )
				End If
			
			Case ERotationOrder.ZYX
				y = ASin( -Max( -1, Min( 1, mat.c ) ) )
		
				If Abs(mat.c) < 0.9999999 Then
					x = ATan2( mat.g, mat.k )
					z = ATan2( mat.b, mat.a )
				Else
					z = ATan2( -mat.e, mat.f )
				End If
			
		End Select
		
		Return New SVec3D(x, y, z)
	End Method

	Rem
	bbdoc: Returns a #String representation of the quaternion.
	End Rem
	Method ToString:String() Override
		Local sb:TStringBuilder = New TStringBuilder
		
		sb.Append("(").Append(x).Append(", ").Append(y).Append(", ").Append(z).Append(", ").Append(w).Append(")")
		
		Return sb.ToString()
	End Method

End Struct

Rem
bbdoc: A #Float backed Quaternion.
about: Quaternions are used to represent rotations.
They are compact, don't suffer from gimbal lock and can easily be interpolated.
End Rem
Struct SQuatF
	Field x:Float
	Field y:Float
	Field z:Float
	Field w:Float

	Method New()
		Self.w = 1
	End Method

	Rem
	bbdoc: Creates a new #SQuatF from the supplied arguments.
	End Rem
	Method New(x:Float, y:Float, z:Float, w:Float)
		Self.x = x
		Self.y = y
		Self.z = z
		Self.w = w
	End Method

	Rem
	bbdoc: Creates a new #SQuatF from the rotation specified by the @euler angle and @order.
	End Rem
	Function CreateFromEuler:SQuatF(euler:SVec3F, order:ERotationOrder = ERotationOrder.XYZ)
		Return New SQuatF.EulerRotate(euler, order)
	End Function
	
	Rem
	bbdoc: Creates a new #SQuatD from the rotation component of matrix @mat.
	about: see http://www.euclideanspace.com/maths/geometry/rotations/conversions/matrixToQuaternion/index.htm
	End Rem
	Function CreateFromRotation:SQuatF(mat:SMat4F)
		Local trace:Float = mat.a + mat.f + mat.k
		
		If trace > 0 Then
		
			Local s:Float = 0.5 / Sqr( trace + 1 )
			
			Return New SQuatF((mat.g - mat.j) * s, (mat.i - mat.c) * s, (mat.b - mat.e) * s, 0.25 / s)
		
		Else If mat.a > mat.f And mat.a > mat.k Then
		
			Local s:Float = 2.0 * Sqr(1.0 + mat.a - mat.f - mat.k)
			
			Return New SQuatF(0.25 * s, (mat.e + mat.b) / s, (mat.i + mat.c) / s, (mat.g - mat.j) / s)
		
		Else If mat.f > mat.k Then
		
			Local s:Float = 2.0 * Sqr(1.0 + mat.f - mat.a - mat.k)
		
			Return New SQuatF((mat.e + mat.b) / s, 0.25 * s, (mat.j + mat.g) / s, (mat.i - mat.c) / s)
		
		Else
		
			Local s:Float = 2.0 * Sqr( 1.0 + mat.k - mat.a - mat.f )
		
			Return New SQuatF((mat.i + mat.c) / s, (mat.j + mat.g) / s, 0.25 * s, (mat.b - mat.e) / s)
			
		End If
		
	End Function

	Rem
	bbdoc: Applies the quaternion @a to the matrix, returning a new matrix.
	End Rem
	Function ToMat3:SMat3F(a:SQuatF)
		Local ax:Float = a.x
		Local ay:Float = a.y
		Local az:Float = a.z
		Local aw:Float = a.w
		Local ax2:Float = ax + ax
		Local ay2:Float = ay + ay
		Local az2:Float = az + az
		Local axx:Float = ax * ax2
		Local ayx:Float = ay * ax2
		Local ayy:Float = ay * ay2
		Local azx:Float = az * ax2
		Local azy:Float = az * ay2
		Local azz:Float = az * az2
		Local awx:Float = aw * ax2
		Local awy:Float = aw * ay2
		Local awz:Float = aw * az2
		Return New SMat3F(1 - ayy - azz, ayx + awz, azx - awy, ayx - awz, 1.0 - axx - azz, azy + awx, azx + awy, azy - awx, 1.0 - axx - ayy)
	End Function

	Rem
	bbdoc: Applies the quaternian to the matrix, return the new matrix.
	End Rem
	Function ToMat4:SMat4F(a:SQuatF)
		Local ax:Float = a.x
		Local ay:Float = a.y
		Local az:Float = a.z
		Local aw:Float = a.w
		Local ax2:Float = ax + ax
		Local ay2:Float = ay + ay
		Local az2:Float = az + az
		Local axx:Float = ax * ax2
		Local ayx:Float = ay * ax2
		Local ayy:Float = ay * ay2
		Local azx:Float = az * ax2
		Local azy:Float = az * ay2
		Local azz:Float = az * az2
		Local awx:Float = aw * ax2
		Local awy:Float = aw * ay2
		Local awz:Float = aw * az2
		Return New SMat4F(1.0 - (ayy + azz), ayx + awz, azx - awy, 0, ..
			ayx - awz, 1.0 - (axx + azz), azy + awx, 0, ..
			azx + awy, azy - awx, 1.0 - (axx + ayy), 0, ..
			0, 0, 0, 1)
	End Function	

	Rem
	bbdoc: Creates a translation and rotation matrix.
	about: The returned matrix is such that it places objects at position @s, oriented in rotation @a.
	End Rem
	Function RotTrans:SMat4F(a:SQuatF, s:SVec3F)
		Local ax:Float = a.x
		Local ay:Float = a.y
		Local az:Float = a.x
		Local aw:Float = a.w
		Local ax2:Float = ax + ax
		Local ay2:Float = ay + ay
		Local az2:Float = az + az
		Local axx:Float = ax * ax2
		Local axy:Float = ax * ay2
		Local axz:Float = ax * az2
		Local ayy:Float = ay * ay2
		Local ayz:Float = ay * az2
		Local azz:Float = az * az2
		Local awx:Float = aw * ax2
		Local awy:Float = aw * ay2
		Local awz:Float = aw * az2
		Return New SMat4F(1.0 - ayy - azz, axy + awz, axz - awy, 0, ..
			axy - awz, 1.0 - axx - azz, ayz + awx, 0, ..
			axz + awy, ayz - awx, 1.0 - axx - ayy, 0, ..
			s.x, s.y, s.z, 1)
	End Function
	
	Rem
	bbdoc: Creates a translation, rotation and scaling matrix.
	about: The returned matrix is such that it places objects at position @origin, oriented in rotation @a and scaled by @s.
	End Rem
	Function RotTransOrigin:SMat4F(a:SQuatF, s:SVec3F, origin:SVec3F)
		Local ax:Float = a.x
		Local ay:Float = a.y
		Local az:Float = a.x
		Local aw:Float = a.w
		Local ax2:Float = ax + ax
		Local ay2:Float = ay + ay
		Local az2:Float = az + az
		Local axx:Float = ax * ax2
		Local axy:Float = ax * ay2
		Local axz:Float = ax * az2
		Local ayy:Float = ay * ay2
		Local ayz:Float = ay * az2
		Local azz:Float = az * az2
		Local awx:Float = aw * ax2
		Local awy:Float = aw * ay2
		Local awz:Float = aw * az2
		Local ox:Float = origin.x
		Local oy:Float = origin.y
		Local oz:Float = origin.z
		Local o00:Float = 1.0 - ayy - azz
		Local o01:Float = axy + awz
		Local o02:Float = axz - awy
		Local o10:Float = axy - awz
		Local o11:Float = 1.0 - axx - azz
		Local o12:Float = ayz + awx
		Local o20:Float = axz + awy
		Local o21:Float = ayz - awx
		Local o22:Float = 1.0 - axx - ayy
		Return New SMat4F(o00, o01, o02, 0, ..
			o10, o11, o12, 0, ..
			o20, o21, o22, 0, ..
			s.x + ox - (o00 * ox + o10 * oy + o20 * oz), ..
			s.y + oy - (o01 * ox + o11 * oy + o21 * oz), ..
			s.z + oz - (o02 * ox + o12 * oy + o22 * oz), 1)
	End Function

	Rem
	bbdoc: Returns the angle between ths quaternion and the quaternion @quat.
	End Rem
	Method AngleTo:Float(quat:SQuatF)
		Local d:Float = Max(-1, Min( 1, dot(quat)))
		Return 114.591559026 * _acos(Abs(d))
	End Method

	Rem
	bbdoc: The dot product between two rotations.
	End Rem
	Method Dot:Float(b:SQuatF)
		Return x * b.x + y * b.y + z * b.z + w * b.w
	End Method
	
	Rem
	bbdoc: Returns the Inverse of rotation.
	End Rem
	Method Invert:SQuatF()
		Local dot:Float = x * x + y * y + z * z + w * w
		Local invdot:Float
		If dot <> 0 Then
			invdot = 1 / dot
		End If
		Return New SQuatF(-x * invdot, -y * invdot, -z * invdot, w * invdot)
	End Method
	
	Rem
	bbdoc: Interpolates between the SQuatF and @b by @t and normalizes the result afterwards.
	End Rem
	Method Interpolate:SQuatF(b:SQuatF, t:Float)
		Return New SQuatF(LerpF(x, b.x, t), LerpF(y, b.y, t), LerpF(z, b.z, t), LerpF(w, b.w, t))
	End Method

	Rem
	bbdoc: Computes the length of this quaternion, considered as a 4 dimensional vector.
	End Rem
	Method Length:Float()
		Return Sqr(x * x + y * y + z * z + w * w)
	End Method
	
	Rem
	bbdoc: Computes the length of this quaternion, considered as a 4 dimensional vector.
	about: Calculating the squared length instead of the length is much faster.
	Often if you are comparing lengths of two quaternions you can just compare their squared lengths.
	End Rem
	Method LengthSquared:Float()
		Return x * x + y * y + z * z + w * w
	End Method

	Rem
	bbdoc: Multiplies the quaternion by @b, returning a new quaternion.
	End Rem
	Method Operator*:SQuatF(b:SQuatF)
		Return New SQuatF(x * b.w + w * b.x + y * b.z - z * b.y, ..
			y * b.w + w * b.y + z * b.x - x * b.z, ..
			z * b.w + w * b.z + x * b.y - y * b.x, ..
			w * b.w - x * b.x - y * b.y - z * b.z)
	End Method
	
	Rem
	bbdoc: Returns a new quaternion, negated.
	End Rem
	Method Operator-:SQuatF()
		Return New SQuatF(-x, -y, -z, -w)
	End Method
	
	Rem
	bbdoc: The identity rotation.
	End Rem
	Function Identity:SQuatF()
		Return New SQuatF(0, 0, 0, 1)
	End Function
	
	Rem
	bbdoc: Converts this quaternion to one with the same orientation but with a magnitude of 1.
	End Rem
	Method Normal:SQuatF()
		Local length:Float = x * x + y * y + z * z + w * w
		If length = 0 Then
			Return New SQuatF(0, 0, 0, 1)
		Else
			length = 1 / Sqr(length)

			Return New SQuatF(x * length, y * length, z * length, w * length)
		End If
	End Method

	Rem
	bbdoc: Rotates this quaternion by a given angular step @s to the specified quaternion @quat.
	End Rem
	Method RotateTowards:SQuatF(quat:SQuatF, s:Float)
		Local angle:Float = AngleTo(quat)
		
		If angle = 0 Then
			Return Self
		End If
		
		Local t:Float = Min(1, s / angle)
		
		Return SphericalInterpolate(quat, t)
	End Method

	Rem
	bbdoc: Spherically interpolates between this SQuatF and @b by @t.
	End Rem
	Method SphericalInterpolate:SQuatF(b:SQuatF, t:Float)
		Local bx:Float = b.x
		Local by:Float = b.y
		Local bz:Float = b.z
		Local bw:Float = b.w
		Local scale0:Float
		Local scale1:Float

		Local cosom:Float = x * bx + y * by + z * bz + w * bw

		If cosom < 0 Then
			cosom = -cosom
			bx = -bx
			by = -by
			bz = -bz
			bw = -bw
		End If
		
		If 1 - cosom > 0.000001 Then
			Local omega:Float = _acos(cosom)
			Local sinom:Float = _sin(omega)
			scale0 = _sin((1.0 - t) * omega) / sinom
			scale1 = _sin(t * omega) / sinom
		Else
			scale0 = 1 - t
			scale1 = t
		End If
		
		Return New SQuatF(scale0 * x + scale1 * bx, scale0 * y + scale1 * by, scale0 * z + scale1 * bz, scale0 * w + scale1 * bw)
	End Method
	
	Rem
	bbdoc: Returns a rotation that rotates around @rot.
	End Rem
	Method EulerRotate:SQuatF(rot:SVec3F, order:ERotationOrder = ERotationOrder.XYZ)
		Local cx:Float = Cos(rot.x * .5)
		Local cy:Float = Cos(rot.y * .5)
		Local cz:Float = Cos(rot.z * .5)
		Local sx:Float = Sin(rot.x * .5)
		Local sy:Float = Sin(rot.y * .5)
		Local sz:Float = Sin(rot.z * .5)
		
		Select order
			Case ERotationOrder.XYZ
				Return New SQuatF(sx * cy * cz + cx * sy * sz, ..
					cx * sy * cz - sx * cy * sz, ..
					cx * cy * sz + sx * sy * cz, ..
					cx * cy * cz - sx * sy * sz)
			Case ERotationOrder.XZY
				Return New SQuatF(sx * cy * cz - cx * sy * sz, ..
					cx * sy * cz - sx * cy * sz, ..
					cx * cy * sz + sx * sy * cz, ..
					cx * cy * cz + sx * sy * sz)
			Case ERotationOrder.YXZ
				Return New SQuatF(sx * cy * cz + cx * sy * sz, ..
					cx * sy * cz - sx * cy * sz, ..
					cx * cy * sz - sx * sy * cz, ..
					cx * cy * cz + sx * sy * sz)
			Case ERotationOrder.YZX
				Return New SQuatF(sx * cy * cz + cx * sy * sz, ..
					cx * sy * cz + sx * cy * sz, ..
					cx * cy * sz - sx * sy * cz, ..
					cx * cy * cz - sx * sy * sz)
			Case ERotationOrder.ZXY
				Return New SQuatF(sx * cy * cz - cx * sy * sz, ..
					cx * sy * cz + sx * cy * sz, ..
					cx * cy * sz + sx * sy * cz, ..
					cx * cy * cz - sx * sy * sz)
			Case ERotationOrder.ZYX
				Return New SQuatF(sx * cy * cz - cx * sy * sz, ..
					cx * sy * cz + sx * cy * sz, ..
					cx * cy * sz - sx * sy * cz, ..
					cx * cy * cz + sx * sy * sz)
		End Select
	End Method

	Rem
	bbdoc: Returns the quaternion converted to Euler angles, using the specified rotation @order.
	End Rem
	Method ToEuler:SVec3F(order:ERotationOrder = ERotationOrder.XYZ)
		Local q:SQuatF = Normal()
		Local mat:SMat4F = ToMat4(q)
		
		Local x:Float
		Local y:Float
		Local z:Float

		Select order
			Case ERotationOrder.XYZ
				y = ASin( Max( -1, Min( 1, mat.i ) ) )
		
				If Abs(mat.i) < 0.9999999 Then
					x = ATan2( -mat.j, mat.k )
					z = ATan2( -mat.e, mat.a )
				Else
					x = ATan2( mat.g, mat.f )
				End If
				
			Case ERotationOrder.XZY
				z = ASin( -Max( -1, Min( 1, mat.e ) ) )

				If Abs(mat.e) < 0.9999999 Then
					x = ATan2( mat.g, mat.f )
					y = ATan2( mat.i, mat.a )
				Else
					x = ATan2( -mat.j, mat.k )
				End If

			Case ERotationOrder.YXZ
				x = ASin( -Max( -1, Min( 1, mat.j ) ) )
		
				If Abs(mat.j) < 0.9999999 Then
					y = ATan2( mat.i, mat.k )
					z = ATan2( mat.b, mat.f )
				Else
					y = ATan2( -mat.c, mat.a )
				End If
			
			Case ERotationOrder.YZX
				z = ASin( Max( -1, Min( 1, mat.b ) ) )
		
				If Abs(mat.b) < 0.9999999 Then
					x = ATan2( -mat.j, mat.f )
					y = ATan2( -mat.c, mat.a )
				Else
					y = ATan2( mat.i, mat.k )
				End If
			
			Case ERotationOrder.ZXY
				x = ASin( Max( -1, Min( 1, mat.g ) ) )
		
				If Abs(mat.g) < 0.9999999 Then
					y = ATan2( -mat.c, mat.k )
					z = ATan2( -mat.e, mat.f )
				Else
					z = ATan2( mat.b, mat.a )
				End If
			
			Case ERotationOrder.ZYX
				y = ASin( -Max( -1, Min( 1, mat.c ) ) )
		
				If Abs(mat.c) < 0.9999999 Then
					x = ATan2( mat.g, mat.k )
					z = ATan2( mat.b, mat.a )
				Else
					z = ATan2( -mat.e, mat.f )
				End If
			
		End Select
		
		Return New SVec3F(x, y, z)
	End Method

	Rem
	bbdoc: Returns a #String representation of the quaternion.
	End Rem
	Method ToString:String() Override
		Local sb:TStringBuilder = New TStringBuilder
		
		sb.Append("(").Append(x).Append(", ").Append(y).Append(", ").Append(z).Append(", ").Append(w).Append(")")
		
		Return sb.ToString()
	End Method

End Struct

Rem
bbdoc: An #Int backed Quaternion.
about: Quaternions are used to represent rotations.
They are compact, don't suffer from gimbal lock and can easily be interpolated.
End Rem
Struct SQuatI
	Field x:Int
	Field y:Int
	Field z:Int
	Field w:Int

	Method New()
		Self.w = 1
	End Method
	
	Rem
	bbdoc: Creates a new #SQuatI from the supplied arguments.
	End Rem
	Method New(x:Int, y:Int, z:Int, w:Int)
		Self.x = x
		Self.y = y
		Self.z = z
		Self.w = w
	End Method

	Rem
	bbdoc: Creates a new #SQuatI from the rotation specified by the @euler angle and @order.
	End Rem
	Function CreateFromEuler:SQuatI(euler:SVec3I, order:ERotationOrder = ERotationOrder.XYZ)
		Return New SQuatI.EulerRotate(euler, order)
	End Function
	
	Rem
	bbdoc: Creates a new #SQuatI from the rotation component of matrix @mat.
	about: see http://www.euclideanspace.com/maths/geometry/rotations/conversions/matrixToQuaternion/index.htm
	End Rem
	Function CreateFromRotation:SQuatI(mat:SMat4I)
		Local trace:Double = mat.a + mat.f + mat.k
		
		If trace > 0 Then
		
			Local s:Double = 0.5 / Sqr( trace + 1 )
			
			Return New SQuatI(Int((mat.g - mat.j) * s), Int((mat.i - mat.c) * s), Int((mat.b - mat.e) * s), Int(0.25 / s))
		
		Else If mat.a > mat.f And mat.a > mat.k Then
		
			Local s:Double = 2.0 * Sqr(1.0 + mat.a - mat.f - mat.k)
			
			Return New SQuatI(Int(0.25 * s), Int((mat.e + mat.b) / s), Int((mat.i + mat.c) / s), Int((mat.g - mat.j) / s))
		
		Else If mat.f > mat.k Then
		
			Local s:Double = 2.0 * Sqr(1.0 + mat.f - mat.a - mat.k)
		
			Return New SQuatI(Int((mat.e + mat.b) / s), Int(0.25 * s), Int((mat.j + mat.g) / s), Int((mat.i - mat.c) / s))
		
		Else
		
			Local s:Double = 2.0 * Sqr( 1.0 + mat.k - mat.a - mat.f )
		
			Return New SQuatI(Int((mat.i + mat.c) / s), Int((mat.j + mat.g) / s), Int(0.25 * s), Int((mat.b - mat.e) / s))
			
		End If
		
	End Function

	Rem
	bbdoc: Applies the quaternion @a to the matrix, returning a new matrix.
	End Rem
	Function ToMat3:SMat3I(a:SQuatI)
		Local ax:Int = a.x
		Local ay:Int = a.y
		Local az:Int = a.z
		Local aw:Int = a.w
		Local ax2:Int = ax + ax
		Local ay2:Int = ay + ay
		Local az2:Int = az + az
		Local axx:Int = ax * ax2
		Local ayx:Int = ay * ax2
		Local ayy:Int = ay * ay2
		Local azx:Int = az * ax2
		Local azy:Int = az * ay2
		Local azz:Int = az * az2
		Local awx:Int = aw * ax2
		Local awy:Int = aw * ay2
		Local awz:Int = aw * az2
		Return New SMat3I(1 - ayy - azz, ayx + awz, azx - awy, ayx - awz, Int(1.0 - axx - azz), azy + awx, azx + awy, azy - awx, Int(1.0 - axx - ayy))
	End Function

	Rem
	bbdoc: Applies the quaternian to the matrix, return the new matrix.
	End Rem
	Function ToMat4:SMat4I(a:SQuatI)
		Local ax:Int = a.x
		Local ay:Int = a.y
		Local az:Int = a.z
		Local aw:Int = a.w
		Local ax2:Int = ax + ax
		Local ay2:Int = ay + ay
		Local az2:Int = az + az
		Local axx:Int = ax * ax2
		Local ayx:Int = ay * ax2
		Local ayy:Int = ay * ay2
		Local azx:Int = az * ax2
		Local azy:Int = az * ay2
		Local azz:Int = az * az2
		Local awx:Int = aw * ax2
		Local awy:Int = aw * ay2
		Local awz:Int = aw * az2
		Return New SMat4I(Int(1.0 - ayy - azz), ayx + awz, azx - awy, 0, ..
			ayx - awz, Int(1.0 - axx - azz), azy + awx, 0, ..
			azx + awy, azy - awx, Int(1.0 - axx - ayy), 0, ..
			0, 0, 0, 1)
	End Function	

	Rem
	bbdoc: Creates a translation and rotation matrix.
	about: The returned matrix is such that it places objects at position @s, oriented in rotation @a.
	End Rem
	Function RotTrans:SMat4I(a:SQuatI, s:SVec3I)
		Local ax:Int = a.x
		Local ay:Int = a.y
		Local az:Int = a.x
		Local aw:Int = a.w
		Local ax2:Int = ax + ax
		Local ay2:Int = ay + ay
		Local az2:Int = az + az
		Local axx:Int = ax * ax2
		Local axy:Int = ax * ay2
		Local axz:Int = ax * az2
		Local ayy:Int = ay * ay2
		Local ayz:Int = ay * az2
		Local azz:Int = az * az2
		Local awx:Int = aw * ax2
		Local awy:Int = aw * ay2
		Local awz:Int = aw * az2
		Return New SMat4I(Int(1.0 - ayy - azz), axy + awz, axz - awy, 0, ..
			axy - awz, Int(1.0 - axx - azz), ayz + awx, 0, ..
			axz + awy, ayz - awx, Int(1.0 - axx - ayy), 0, ..
			s.x, s.y, s.z, 1)
	End Function
	
	Rem
	bbdoc: Creates a translation, rotation and scaling matrix.
	about: The returned matrix is such that it places objects at position @origin, oriented in rotation @a and scaled by @s.
	End Rem
	Function RotTransOrigin:SMat4I(a:SQuatI, s:SVec3I, origin:SVec3I)
		Local ax:Int = a.x
		Local ay:Int = a.y
		Local az:Int = a.x
		Local aw:Int = a.w
		Local ax2:Int = ax + ax
		Local ay2:Int = ay + ay
		Local az2:Int = az + az
		Local axx:Int = ax * ax2
		Local axy:Int = ax * ay2
		Local axz:Int = ax * az2
		Local ayy:Int = ay * ay2
		Local ayz:Int = ay * az2
		Local azz:Int = az * az2
		Local awx:Int = aw * ax2
		Local awy:Int = aw * ay2
		Local awz:Int = aw * az2
		Local ox:Int = origin.x
		Local oy:Int = origin.y
		Local oz:Int = origin.z
		Local o00:Int = 1.0 - ayy - azz
		Local o01:Int = axy + awz
		Local o02:Int = axz - awy
		Local o10:Int = axy - awz
		Local o11:Int = 1.0 - axx - azz
		Local o12:Int = ayz + awx
		Local o20:Int = axz + awy
		Local o21:Int = ayz - awx
		Local o22:Int = 1.0 - axx - ayy
		Return New SMat4I(o00, o01, o02, 0, ..
			o10, o11, o12, 0, ..
			o20, o21, o22, 0, ..
			s.x + ox - (o00 * ox + o10 * oy + o20 * oz), ..
			s.y + oy - (o01 * ox + o11 * oy + o21 * oz), ..
			s.z + oz - (o02 * ox + o12 * oy + o22 * oz), 1)
	End Function

	Rem
	bbdoc: Returns the angle between ths quaternion and the quaternion @quat.
	End Rem
	Method AngleTo:Double(quat:SQuatI)
		Local d:Double = Max(-1, Min( 1, dot(quat)))
		Return 114.591559026:Double * _acos(Abs(d))
	End Method

	Rem
	bbdoc: The dot product between two rotations.
	End Rem
	Method Dot:Int(b:SQuatI)
		Return x * b.x + y * b.y + z * b.z + w * b.w
	End Method
	
	Rem
	bbdoc: Returns the Inverse of rotation.
	End Rem
	Method Invert:SQuatI()
		Local dot:Int = x * x + y * y + z * z + w * w
		Local invdot:Int
		If dot <> 0 Then
			invdot = 1 / dot
		End If
		Return New SQuatI(-x * invdot, -y * invdot, -z * invdot, w * invdot)
	End Method
	
	Rem
	bbdoc: Interpolates between the SQuatI and @b by @t and normalizes the result afterwards.
	End Rem
	Method Interpolate:SQuatI(b:SQuatI, t:Int)
		Return New SQuatI(LerpI(x, b.x, t), LerpI(y, b.y, t), LerpI(z, b.z, t), LerpI(w, b.w, t))
	End Method

	Rem
	bbdoc: Computes the length of this quaternion, considered as a 4 dimensional vector.
	End Rem
	Method Length:Double()
		Return Sqr(x * x + y * y + z * z + w * w)
	End Method
	
	Rem
	bbdoc: Computes the length of this quaternion, considered as a 4 dimensional vector.
	about: Calculating the squared length instead of the length is much faster.
	Often if you are comparing lengths of two quaternions you can just compare their squared lengths.
	End Rem
	Method LengthSquared:Double()
		Return x * x + y * y + z * z + w * w
	End Method

	Rem
	bbdoc: Multiplies the quaternion by @b, returning a new quaternion.
	End Rem
	Method Operator*:SQuatI(b:SQuatI)
		Return New SQuatI(x * b.w + w * b.x + y * b.z - z * b.y, ..
			y * b.w + w * b.y + z * b.x - x * b.z, ..
			z * b.w + w * b.z + x * b.y - y * b.x, ..
			w * b.w - x * b.x - y * b.y - z * b.z)
	End Method
	
	Rem
	bbdoc: Returns a new quaternion, negated.
	End Rem
	Method Operator-:SQuatI()
		Return New SQuatI(-x, -y, -z, -w)
	End Method
	
	Rem
	bbdoc: The identity rotation.
	End Rem
	Function Identity:SQuatI()
		Return New SQuatI(0, 0, 0, 1)
	End Function
	
	Rem
	bbdoc: Converts this quaternion to one with the same orientation but with a magnitude of 1.
	End Rem
	Method Normal:SQuatI()
		Local length:Double = x * x + y * y + z * z + w * w
		If length = 0 Then
			Return New SQuatI(0, 0, 0, 1)
		Else
			length = 1 / Sqr(length)
			Return New SQuatI(Int(x * length), Int(y * length), Int(z * length), Int(w * length))
		End If
		Return Self
	End Method

	Rem
	bbdoc: Rotates this quaternion by a given angular step @s to the specified quaternion @quat.
	End Rem
	Method RotateTowards:SQuatI(quat:SQuatI, s:Double)
		Local angle:Double = AngleTo(quat)
		
		If angle = 0 Then
			Return Self
		End If
		
		Local t:Double = Min(1, s / angle)
		
		Return SphericalInterpolate(quat, t)
	End Method
	
	Rem
	bbdoc: Spherically interpolates between this SQuatI and @b by @t.
	End Rem
	Method SphericalInterpolate:SQuatI(b:SQuatI, t:Double)
		Local bx:Int = b.x
		Local by:Int = b.y
		Local bz:Int = b.z
		Local bw:Int = b.w
		Local scale0:Double
		Local scale1:Double

		Local cosom:Int = x * bx + y * by + z * bz + w * bw

		If cosom < 0 Then
			cosom = -cosom
			bx = -bx
			by = -by
			bz = -bz
			bw = -bw
		End If
		
		If 1 - cosom > 0.000001 Then
			Local omega:Double = _acos(cosom)
			Local sinom:Double = _sin(omega)
			scale0 = _sin((1.0 - t) * omega) / sinom
			scale1 = _sin(t * omega) / sinom
		Else
			scale0 = 1 - t
			scale1 = t
		End If
		
		Return New SQuatI(Int(scale0 * x + scale1 * bx), Int(scale0 * y + scale1 * by), Int(scale0 * z + scale1 * bz), Int(scale0 * w + scale1 * bw))
	End Method
	
	Rem
	bbdoc: Returns a rotation that rotates around @rot.
	End Rem
	Method EulerRotate:SQuatI(rot:SVec3I, order:ERotationOrder = ERotationOrder.XYZ)
		Local cx:Double = Cos(rot.x * .5)
		Local cy:Double = Cos(rot.y * .5)
		Local cz:Double = Cos(rot.z * .5)
		Local sx:Double = Sin(rot.x * .5)
		Local sy:Double = Sin(rot.y * .5)
		Local sz:Double = Sin(rot.z * .5)
		
		Select order
			Case ERotationOrder.XYZ
				Return New SQuatI(Int(sx * cy * cz + cx * sy * sz), ..
					Int(cx * sy * cz - sx * cy * sz), ..
					Int(cx * cy * sz + sx * sy * cz), ..
					Int(cx * cy * cz - sx * sy * sz))
			Case ERotationOrder.XZY
				Return New SQuatI(Int(sx * cy * cz - cx * sy * sz), ..
					Int(cx * sy * cz - sx * cy * sz), ..
					Int(cx * cy * sz + sx * sy * cz), ..
					Int(cx * cy * cz + sx * sy * sz))
			Case ERotationOrder.YXZ
				Return New SQuatI(Int(sx * cy * cz + cx * sy * sz), ..
					Int(cx * sy * cz - sx * cy * sz), ..
					Int(cx * cy * sz - sx * sy * cz), ..
					Int(cx * cy * cz + sx * sy * sz))
			Case ERotationOrder.YZX
				Return New SQuatI(Int(sx * cy * cz + cx * sy * sz), ..
					Int(cx * sy * cz + sx * cy * sz), ..
					Int(cx * cy * sz - sx * sy * cz), ..
					Int(cx * cy * cz - sx * sy * sz))
			Case ERotationOrder.ZXY
				Return New SQuatI(Int(sx * cy * cz - cx * sy * sz), ..
					Int(cx * sy * cz + sx * cy * sz), ..
					Int(cx * cy * sz + sx * sy * cz), ..
					Int(cx * cy * cz - sx * sy * sz))
			Case ERotationOrder.ZYX
				Return New SQuatI(Int(sx * cy * cz - cx * sy * sz), ..
					Int(cx * sy * cz + sx * cy * sz), ..
					Int(cx * cy * sz - sx * sy * cz), ..
					Int(cx * cy * cz + sx * sy * sz))
		End Select
	End Method

	Rem
	bbdoc: Returns the quaternion converted to Euler angles, using the specified rotation @order.
	End Rem
	Method ToEuler:SVec3I(order:ERotationOrder = ERotationOrder.XYZ)
		Local q:SQuatI = Normal()
		Local mat:SMat4I = ToMat4(q)
		
		Local x:Int
		Local y:Int
		Local z:Int

		Select order
			Case ERotationOrder.XYZ
				y = ASin( Max( -1, Min( 1, mat.i ) ) )
		
				If Abs(mat.i) < 0.9999999 Then
					x = ATan2( -mat.j, mat.k )
					z = ATan2( -mat.e, mat.a )
				Else
					x = ATan2( mat.g, mat.f )
				End If
				
			Case ERotationOrder.XZY
				z = ASin( -Max( -1, Min( 1, mat.e ) ) )

				If Abs(mat.e) < 0.9999999 Then
					x = ATan2( mat.g, mat.f )
					y = ATan2( mat.i, mat.a )
				Else
					x = ATan2( -mat.j, mat.k )
				End If

			Case ERotationOrder.YXZ
				x = ASin( -Max( -1, Min( 1, mat.j ) ) )
		
				If Abs(mat.j) < 0.9999999 Then
					y = ATan2( mat.i, mat.k )
					z = ATan2( mat.b, mat.f )
				Else
					y = ATan2( -mat.c, mat.a )
				End If
			
			Case ERotationOrder.YZX
				z = ASin( Max( -1, Min( 1, mat.b ) ) )
		
				If Abs(mat.b) < 0.9999999 Then
					x = ATan2( -mat.j, mat.f )
					y = ATan2( -mat.c, mat.a )
				Else
					y = ATan2( mat.i, mat.k )
				End If
			
			Case ERotationOrder.ZXY
				x = ASin( Max( -1, Min( 1, mat.g ) ) )
		
				If Abs(mat.g) < 0.9999999 Then
					y = ATan2( -mat.c, mat.k )
					z = ATan2( -mat.e, mat.f )
				Else
					z = ATan2( mat.b, mat.a )
				End If
			
			Case ERotationOrder.ZYX
				y = ASin( -Max( -1, Min( 1, mat.c ) ) )
		
				If Abs(mat.c) < 0.9999999 Then
					x = ATan2( mat.g, mat.k )
					z = ATan2( mat.b, mat.a )
				Else
					z = ATan2( -mat.e, mat.f )
				End If
			
		End Select
		
		Return New SVec3I(x, y, z)
	End Method

	Rem
	bbdoc: Returns a #String representation of the quaternion.
	End Rem
	Method ToString:String() Override
		Local sb:TStringBuilder = New TStringBuilder
		
		sb.Append("(").Append(x).Append(", ").Append(y).Append(", ").Append(z).Append(", ").Append(w).Append(")")
		
		Return sb.ToString()
	End Method
	
End Struct

Rem
bbdoc: The order in which to apply rotations.
End Rem
Enum ERotationOrder
	XYZ
	XZY
	YXZ
	YZX
	ZXY
	ZYX
End Enum


Private
Function Lerp:Double(a:Double, b:Double, t:Double)
	Return a + (b - a) * t
End Function

Function LerpF:Float(a:Float, b:Float, t:Float)
	Return a + (b - a) * t
End Function

Function LerpI:Int(a:Int, b:Int, t:Int)
	Return a + (b - a) * t
End Function

Extern
	Function _acos:Double(x:Double)="double acos(double)!"
	Function _sin:Double(x:Double)="double sin(double)!"
End Extern
Public
