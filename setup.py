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
        self.mkpath(os.path.join(self.build_lib, 'snowboy'))
        target_file = 'swig/Python/_snowboydetect.so'
        if not self.dry_run:
            self.copy_file(target_file,
                           os.path.join(self.build_lib, 'snowboy'))

        build.run(self)


setup(
    name='snowboy',
    version='1.2.0',
    description='Snowboy is a customizable hotword detection engine',
    maintainer='KITT.AI',
    maintainer_email='snowboy@kitt.ai',
    license='Apache-2.0',
    url='https://snowboy.kitt.ai',
    packages=find_packages('examples/Python/'),
    package_dir={'snowboy': 'examples/Python/'},
    py_modules=['snowboy.snowboydecoder', 'snowboy.snowboydetect'],
    package_data={'': ['README.md', 'snowboy/resources/common.res']},
    data_files=[('.', ['README.md']),
                ('snowboy/resources', ['resources/common.res'])],
    include_package_data=True,
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
