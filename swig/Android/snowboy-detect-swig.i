// swig/Android/snowboy-detect-swig.i

// Copyright 2016  KITT.AI (author: Guoguo Chen)

%module snowboy

// Suppress SWIG warnings.
#pragma SWIG nowarn=SWIGWARN_PARSE_NESTED_CLASS
%include "arrays_java.i"
%include "std_string.i"

%apply float[] {float*};
%apply short[] {int16_t*};
%apply int[]   {int32_t*};

%{
#include "include/snowboy-detect.h"
%}

%include "include/snowboy-detect.h"
