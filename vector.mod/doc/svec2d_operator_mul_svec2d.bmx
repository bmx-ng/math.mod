SuperStrict

Framework brl.standardio
Import Math.Vector

Local a:SVec2D = New SVec2D(2, 3)
Local b:SVec2D = New SVec2D(5, 6)

Local c:SVec2D = a * b

Print c.ToString() ' 10, 18
