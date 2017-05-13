import os
from sys import platform
from setuptools import setup, find_packages
from setuptools.command.install import install
from distutils.command.build import build
from subprocess import call
from multiprocessing import cpu_count


class SnowboyBuild(build):

    def run(self):

        cmd = ['make']

        def compile():
            call(cmd, cwd='swig/Python')

        self.execute(compile, [], 'Compiling snowboy')

        # copy generated .so to build folder
        self.mkpath(self.build_lib)
        target_file = os.path.join('swig/Python/_snowboydetect.so')
        if not self.dry_run:
            self.copy_file(target_file, self.build_lib)

        build.run(self)


setup(
    name='snowboy',
    version='0.1',
    description='',
    maintainer='',
    maintainer_email='',
    license='',
    url='',
    packages=find_packages('examples/Python/'),
    package_dir={'snowboy': 'examples/Python/'},
    py_modules=['snowboy.snowboydecoder', 'snowboy.snowboydetect'],
    include_package_data=True,
    long_description="",
    classifiers=[],
    install_requires=[
        'PyAudio',
    ],
    cmdclass={
        'build': SnowboyBuild
    }
)
