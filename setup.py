import os
import sys
import ctypes.util
from setuptools import setup, find_packages, Extension
from distutils.command.build import build


PY_DIR = 'Python' if sys.version_info[0] < 3 else 'Python3'
PACKAGES_SEARCH = os.path.join('examples', PY_DIR)
SNOWBOY_PACKAGE_DIR = os.path.join(PACKAGES_SEARCH, 'snowboy')


def get_libsnowboy_folder():
    if sys.platform == 'darwin':
        return 'lib/osx'
    machine = os.uname().machine
    folder = ''
    if machine.startswith('arm'):
        folder = 'rpi'
    elif machine == 'x86_64':
        folder = 'ubuntu64'
    elif machine == 'aarch64':
        folder = 'aarch64-ubuntu1604'
    else:
        raise OSError("Unsupported platform {}".format(machine))
    return os.path.join('lib', folder)


cxx_flags = ['-O3', '-D_GLIBCXX_USE_CXX11_ABI=0']
libraries = ['m', 'dl', 'snowboy-detect']
link_args = []

if sys.platform == 'darwin':
    link_args = ['-framework', 'Accelerate', '-bundle', '-flat_namespace', '-undefined', 'suppress']
else:
    cxx_flags.append('-std=c++0x')
    libraries.extend(['f77blas', 'cblas', 'atlas'])

    if ctypes.util.find_library('lapack_atlas'):
        libraries.append('lapack_atlas')
    else:
        libraries.append('lapack')

ext_modules = [
    Extension(
        '_snowboydetect',
        ['swig/{}/snowboy-detect-swig.i'.format(PY_DIR)],
        swig_opts=['-c++'],
        include_dirs=['.'],
        libraries=libraries,
        extra_compile_args=cxx_flags,
        extra_link_args=link_args,
        library_dirs=[get_libsnowboy_folder()]
    )
]

setup(
    name='snowboy',
    version='1.3.0',
    description='Snowboy is a customizable hotword detection engine',
    maintainer='KITT.AI',
    maintainer_email='snowboy@kitt.ai',
    license='Apache-2.0',
    url='https://snowboy.kitt.ai',
    ext_modules=ext_modules,
    packages=find_packages(PACKAGES_SEARCH),
    package_dir={'snowboy': SNOWBOY_PACKAGE_DIR},
    py_modules=['snowboy.snowboydecoder', 'snowboy.snowboydetect'],
    package_data={'snowboy': ['resources/*', 'resources/models/*']},
    zip_safe=False,
    long_description="",
    classifiers=[],
    install_requires=[
        'PyAudio',
    ],
)
