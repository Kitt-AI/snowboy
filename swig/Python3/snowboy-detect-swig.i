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

// below is Python 3 support, however,
// adding it will generate wrong .so file
// for Fedora 25 on ARMv7. So be sure to 
// comment them when you compile for 
// Fedora 25 on ARMv7.
%begin %{
#define SWIG_PYTHON_STRICT_BYTE_CHAR
%}
