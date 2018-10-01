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
import time

from OwO.util.signal import check_for_signal, create_signal


def is_speaking():
    """Determine if Text to Speech is occurring

    Returns:
        bool: True while still speaking
    """
    return check_for_signal("isSpeaking", -1)


def wait_while_speaking():
    """Pause as long as Text to Speech is still happening

    Pause while Text to Speech is still happening.  This always pauses
    briefly to ensure that any preceeding request to speak has time to
    begin.
    """
    time.sleep(0.3)  # Wait briefly in for any queued speech to begin
    while is_speaking():
        time.sleep(0.1)


def stop_speaking():
    # TODO: Less hacky approach to this once Audio Manager is implemented
    # Skills should only be able to stop speech they've initiated
    from OwO.messagebus.send import send
    create_signal('stoppingTTS')
    send('OwO.audio.speech.stop')

    # Block until stopped
    while check_for_signal("isSpeaking", -1):
        time.sleep(0.25)

    # This consumes the signal
    check_for_signal('stoppingTTS')
