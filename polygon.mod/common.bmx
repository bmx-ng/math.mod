' ISC License
' 
' Copyright (c) 2023-2024, Bruce A Henderson
' 
' Permission to use, copy, modify, and/or distribute this software for any purpose
' with or without fee is hereby granted, provided that the above copyright notice
' and this permission notice appear in all copies.
' 
' THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
' REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND
' FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
' INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS
' OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
' TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF
' THIS SOFTWARE.
'
SuperStrict

Import Math.Vector

Import "earcut/include/*.h"
Import "clipper2/CPP/Clipper2Lib/include/*.h"

Import "clipper2/CPP/Clipper2Lib/src/clipper.engine.cpp"
Import "clipper2/CPP/Clipper2Lib/src/clipper.offset.cpp"
Import "clipper2/CPP/Clipper2Lib/src/clipper.rectclip.cpp"

Import "glue.cpp"

Extern

	Function bmx_polygon_tri_svec2i:Int[](poly:SVec2I Ptr, size:Int)
	Function bmx_polygon_tri_svec2f:Int[](poly:SVec2F Ptr, size:Int)

End Extern
