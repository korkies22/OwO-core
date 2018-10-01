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
"""
    OwO audio service.

    This handles playback of audio and speech
"""
from owo.configuration import Configuration
from owo.messagebus.client.ws import WebsocketClient
from owo.util import reset_sigint_handler, wait_for_exit_signal, \
    create_daemon, create_echo_function, check_for_signal
from owo.util.log import LOG

import owo.audio.speech as speech
from .audioservice import AudioService


def main():
    """ Main function. Run when file is invoked. """
    reset_sigint_handler()
    check_for_signal("isSpeaking")
    bus = WebsocketClient()  # Connect to the OwO Messagebus
    Configuration.init(bus)
    speech.init(bus)

    LOG.info("Starting Audio Services")
    bus.on('message', create_echo_function('AUDIO', ['owo.audio.service']))
    audio = AudioService(bus)  # Connect audio service instance to message bus
    create_daemon(bus.run_forever)

    wait_for_exit_signal()

    speech.shutdown()
    audio.shutdown()


main()
