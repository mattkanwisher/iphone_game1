/*  Copyright © 2008 Jens Alfke. All Rights Reserved.

    Redistribution and use in source and binary forms, with or without modification, are permitted
    provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions
      and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of
      conditions and the following disclaimer in the documentation and/or other materials provided
      with the distribution.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
    IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND 
    FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRI-
    BUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
    (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
    PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
    CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF 
    THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
#import "GGBUtils.h"
//#import <AudioToolbox/AudioToolbox.h>


#ifndef _MYUTILITIES_COLLECTIONUTILS_
void setObj( id *variable, id newValue )
{
    if( *variable != newValue ) {
        [*variable release];
        *variable = [newValue retain];
    }
}

void setObjCopy( id<NSCopying> *variable, id<NSCopying> newValue )
{
    if( *variable != newValue ) {
        [(id)*variable release];
        *variable = [(id)newValue copy];
    }
}
#endif


void DelayFor( NSTimeInterval interval )
{
    NSDate *end = [NSDate dateWithTimeIntervalSinceNow: interval];
    while( [end timeIntervalSinceNow] > 0 ) {
        if( ! [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate: end] )
            break;
    }
}    