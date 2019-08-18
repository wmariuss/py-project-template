from pathlib import Path

from setuptools import setup


with open(str(Path(".") / "README.md"), "r", encoding="utf-8") as f:
    README = f.read()

setup(
    name='py-project-template',
    version='0.0.1',
    author='Marius Stanca',
    author_email=['me@marius.xyz'],
    url='https://github.com/wmariuss/py-project-template.git',
    license='MIT',
    description='Project description',
    packages=['src'],
    long_description=README,
    long_description_content_type='text/markdown',
    include_package_data=True,
    package_data={'': ['README.md']},
    install_requires=['click==7.0'],
    extras_require={
        'click': ['click>=7.0']},
    classifiers=[
        'Development Status :: 4 - Beta',
        'Environment :: Console',
        'Environment :: Other Environment',
        'Intended Audience :: End Users',
        'Intended Audience :: Information Technology',
        'License :: OSI Approved :: MIT License',
        'Operating System :: OS Independent',
        'Programming Language :: Python :: 3 :: Only',
        'Topic :: Software Development :: Build Tools',
    ],
    entry_points='''
        [console_scripts]
        py-project-template=src.main:cli
    '''
)
