// swig/Python/snowboy-detect-swig.i

// Copyright 2016  KITT.AI (author: Guoguo Chen)

%module snowboydetect

// Suppress SWIG warnings.
#pragma SWIG nowarn=SWIGWARN_PARSE_NESTED_CLASS
%include "std_string.i"

%{
#include "include/snowboy-detect.h"
%}

%include "include/snowboy-detect.h"
