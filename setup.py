import os
import sys
from setuptools import setup, find_packages, Extension
from distutils.command.build import build


py_dir = 'Python' if sys.version_info[0] < 3 else 'Python3'

ext_modules = [
    Extension(
        '_snowboydetect',
        ['swig/{}/snowboy-detect-swig.i'.format(py_dir)],
        swig_opts=['-c++'],
        include_dirs=['.'],
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
    packages=find_packages(os.path.join('examples', py_dir)),
    package_dir={'snowboy': os.path.join('examples', py_dir, 'snowboy')},
    py_modules=['snowboy.snowboydecoder', 'snowboy.snowboydetect'],
    package_data={'snowboy': ['resources/*']},
    zip_safe=False,
    long_description="",
    classifiers=[],
    install_requires=[
        'PyAudio',
    ],
)
