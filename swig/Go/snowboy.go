package snowboydetect

/*
#cgo CXXFLAGS: -std=c++11 -D_GLIBCXX_USE_CXX11_ABI=0 
#cgo linux,amd64 LDFLAGS: -lcblas -L${SRCDIR}/../../lib/ubuntu64 -lsnowboy-detect
#cgo linux,arm   LDFLAGS: -lcblas -L${SRCDIR}/../../lib/rpi -lsnowboy-detect
#cgo darwin      LDFLAGS: -lcblas -L${SRCDIR}/../../lib/osx -lsnowboy-detect
 */
import "C"
