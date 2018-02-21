import os
import sys
from setuptools import setup, find_packages
from distutils.command.build import build
from distutils.dir_util import copy_tree
from subprocess import call


py_dir = 'Python' if sys.version_info[0] < 3 else 'Python3'

class SnowboyBuild(build):

    def run(self):

        cmd = ['make']
        swig_dir = os.path.join('swig', py_dir)
        def compile():
            call(cmd, cwd=swig_dir)

        self.execute(compile, [], 'Compiling snowboy...')

        # copy generated .so to build folder
        self.mkpath(self.build_lib)
        snowboy_build_lib = os.path.join(self.build_lib, 'snowboy')
        self.mkpath(snowboy_build_lib)
        target_file = os.path.join(swig_dir, '_snowboydetect.so')
        if not self.dry_run:
            self.copy_file(target_file,
                           snowboy_build_lib)

            # copy resources too since it is a symlink
            resources_dir = 'resources'
            resources_dir_on_build = os.path.join(snowboy_build_lib,
                                                  'resources')
            copy_tree(resources_dir, resources_dir_on_build)

        build.run(self)


setup(
    name='snowboy',
    version='1.3.0',
    description='Snowboy is a customizable hotword detection engine',
    maintainer='KITT.AI',
    maintainer_email='snowboy@kitt.ai',
    license='Apache-2.0',
    url='https://snowboy.kitt.ai',
    packages=find_packages(os.path.join('examples', py_dir)),
    package_dir={'snowboy': os.path.join('examples', py_dir)},
    py_modules=['snowboy.snowboydecoder', 'snowboy.snowboydetect'],
    package_data={'snowboy': ['resources/*']},
    zip_safe=False,
    long_description="",
    classifiers=[],
    install_requires=[
        'PyAudio',
    ],
    cmdclass={
        'build': SnowboyBuild
    }
)
