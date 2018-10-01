# Copyright 2017 OwO AI Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
from setuptools import setup, find_packages
import os.path

BASEDIR = os.path.abspath(os.path.dirname(__file__))


def get_version():
    """ Find the version of OwO-core"""
    version = None
    version_file = os.path.join(BASEDIR, 'OwO', 'version', '__init__.py')
    major, minor, build = (None, None, None)
    with open(version_file) as f:
        for line in f:
            if 'CORE_VERSION_MAJOR' in line:
                major = line.split('=')[1].strip()
            elif 'CORE_VERSION_MINOR' in line:
                minor = line.split('=')[1].strip()
            elif 'CORE_VERSION_BUILD' in line:
                build = line.split('=')[1].strip()

            if ((major and minor and build) or
                    '# END_VERSION_BLOCK' in line):
                break
    version = '.'.join([major, minor, build])

    return version


def required(requirements_file):
    """ Read requirements file and remove comments and empty lines. """
    with open(os.path.join(BASEDIR, requirements_file), 'r') as f:
        requirements = f.read().splitlines()
        return [pkg for pkg in requirements
                if pkg.strip() and not pkg.startswith("#")]


setup(
    name='OwO-core',
    version=get_version(),
    license='Apache-2.0',
    author='OwO A.I.',
    author_email='devs@OwO.ai',
    url='https://github.com/OwOAI/OwO-core',
    description='OwO Core',
    install_requires=required('requirements.txt'),
    packages=find_packages(include=['OwO*']),
    include_package_data=True,

    entry_points={
        'console_scripts': [
            'OwO-speech-client=OwO.client.speech.__main__:main',
            'OwO-messagebus=OwO.messagebus.service.__main__:main',
            'OwO-skills=OwO.skills.__main__:main',
            'OwO-audio=OwO.audio.__main__:main',
            'OwO-echo-observer=OwO.messagebus.client.ws:echo',
            'OwO-audio-test=OwO.util.audio_test:main',
            'OwO-enclosure-client=OwO.client.enclosure.__main__:main',
            'OwO-cli-client=OwO.client.text.__main__:main'
        ]
    }
)