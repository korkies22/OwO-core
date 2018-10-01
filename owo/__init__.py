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
from os.path import abspath, dirname, join

from owo.api import Api
from owo.messagebus.message import Message
from owo.skills.context import adds_context, removes_context
from owo.skills.core import OwOSkill, FallbackSkill, \
    intent_handler, intent_file_handler
from owo.skills.intent_service import AdaptIntent

OwO_ROOT_PATH = abspath(join(dirname(__file__), '..'))
