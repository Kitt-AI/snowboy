package snowboydetect

/*
#cgo CXXFLAGS: -std=c++11 -D_GLIBCXX_USE_CXX11_ABI=0 
#cgo linux,amd64 LDFLAGS: -L${SRCDIR}/../../lib/ubuntu64 -lsnowboy-detect -lcblas
#cgo linux,arm   LDFLAGS: -L${SRCDIR}/../../lib/rpi -lsnowboy-detect -lcblas
#cgo darwin      LDFLAGS: -L${SRCDIR}/../../lib/osx -lsnowboy-detect -lcblas
 */
import "C"
