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

from owo.util.signal import check_for_signal, create_signal

def is_speaking():
    """Determina si el TTS funciona.

    Retorna:
        bool: True mientras siga hablando
            """
    return check_for_signal("isSpeaking", -1)


def wait_while_speaking():
    """Pause as long as Text to Speech is still happening"""
    time.sleep(0.3)
    "Wait briefly in for any queued speech to begin"
    while is_speaking():
        time.sleep(0.1)


def stop_speaking():
    # TODO: una implementaciòn menos "hacky" una vez se implemente un audio manager
    # TODO: una vez el usuario deje de hablar se debe, por ux, dar a entender que se encuentra procesando su solicitud.
    # TODO: en moviles hay que crear algun modo de cancelar la solicitud en proceso o reiniciar la grabaciòn.

    # Skills should only be able to stop speech they've initiated
    from owo.messagebus.send import send
    create_signal('stoppingTTS')
    send('owo.audio.speech.stop')

    # Block until stopped
    while check_for_signal("isSpeaking", -1):
        time.sleep(0.25)

    # This consumes the signal
    check_for_signal('stoppingTTS')
