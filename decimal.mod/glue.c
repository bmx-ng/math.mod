/*
 * Copyright (c) 2026 Bruce A Henderson
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */
#include "brl.mod/blitz.mod/blitz.h"
#include "mpdecimal.h"

void bmx_mpd_set_string( void *mpd, BBString *str, mpd_context_t *ctx ) {
    char * n = bbStringToUTF8String( str );
    mpd_set_string( mpd, n, ctx );
    bbMemFree(n);
}

BBString * bmx_mpd_to_sci( void *mpd, int caps ) {
    char * n;
    mpd_ssize_t size = mpd_to_sci_size( &n, mpd, caps );
    if ( size <= 0 ) {
        return &bbEmptyString;
    }

    BBString * s = bbStringFromUTF8Bytes( (unsigned char*)n, (int)size );
    mpd_free(n);
    return s;
}

BBString * bmx_mpd_to_eng( void *mpd, int caps ) {
    char * n;
    mpd_ssize_t size = mpd_to_eng_size( &n, mpd, caps );
    if ( size <= 0 ) {
        return &bbEmptyString;
    }

    BBString * s = bbStringFromUTF8Bytes( (unsigned char*)n, (int)size );
    mpd_free(n);
    return s;
}

BBString * bmx_mpd_to_string( void *mpd, mpd_context_t *ctx, uint32_t *status ) {
    char * n = mpd_qformat( mpd, "f", ctx, status );
    BBString * s = bbStringFromUTF8String( (unsigned char*)n );
    mpd_free(n);
    return s;
}

void bmx_mpd_qset_string_exact( void *mpd, BBString *str, uint32_t *status ) {
    char * n = bbStringToUTF8String( str );
    mpd_qset_string_exact( mpd, n, status );
    bbMemFree(n);
}
