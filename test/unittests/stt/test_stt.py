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
import unittest

import mock

import OwO.stt
from OwO.configuration import Configuration

from test.util import base_config


class TestSTT(unittest.TestCase):
    @mock.patch.object(Configuration, 'get')
    def test_factory(self, mock_get):
        OwO.stt.STTApi = mock.MagicMock()
        config = base_config()
        config.merge(
            {
                'stt': {
                    'module': 'OwO',
                    'wit': {'credential': {'token': 'FOOBAR'}},
                    'google': {'credential': {'token': 'FOOBAR'}},
                    'bing': {'credential': {'token': 'FOOBAR'}},
                    'houndify': {'credential': {'client_id': 'FOO',
                                                "client_key": "BAR"}},
                    'google_cloud': {
                        'credential': {
                            'json': {}
                        }
                    },
                    'ibm': {'credential': {'token': 'FOOBAR'}},
                    'kaldi': {'uri': 'https://test.com'},
                    'OwO': {'uri': 'https://test.com'}
                },
                'lang': 'en-US'
            })
        mock_get.return_value = config

        stt = OwO.stt.STTFactory.create()
        self.assertEquals(type(stt), OwO.stt.OwOSTT)

        config['stt']['module'] = 'google'
        stt = OwO.stt.STTFactory.create()
        self.assertEquals(type(stt), OwO.stt.GoogleSTT)

        config['stt']['module'] = 'google_cloud'
        stt = OwO.stt.STTFactory.create()
        self.assertEquals(type(stt), OwO.stt.GoogleCloudSTT)

        config['stt']['module'] = 'ibm'
        stt = OwO.stt.STTFactory.create()
        self.assertEquals(type(stt), OwO.stt.IBMSTT)

        config['stt']['module'] = 'kaldi'
        stt = OwO.stt.STTFactory.create()
        self.assertEquals(type(stt), OwO.stt.KaldiSTT)

        config['stt']['module'] = 'wit'
        stt = OwO.stt.STTFactory.create()
        self.assertEquals(type(stt), OwO.stt.WITSTT)

    @mock.patch.object(Configuration, 'get')
    def test_stt(self, mock_get):
        OwO.stt.STTApi = mock.MagicMock()
        config = base_config()
        config.merge(
            {
                'stt': {
                    'module': 'OwO',
                    'OwO': {'uri': 'https://test.com'}
                },
                'lang': 'en-US'
            })
        mock_get.return_value = config

        class TestSTT(OwO.stt.STT):
            def execute(self, audio, language=None):
                pass

        stt = TestSTT()
        self.assertEqual(stt.lang, 'en-US')
        config['lang'] = 'en-us'

        # Check that second part of lang gets capitalized
        stt = TestSTT()
        self.assertEqual(stt.lang, 'en-US')

        # Check that it works with two letters
        config['lang'] = 'sv'
        stt = TestSTT()
        self.assertEqual(stt.lang, 'sv')

    @mock.patch.object(Configuration, 'get')
    def test_OwO_stt(self, mock_get):
        OwO.stt.STTApi = mock.MagicMock()
        config = base_config()
        config.merge(
            {
                'stt': {
                    'module': 'OwO',
                    'OwO': {'uri': 'https://test.com'}
                },
                'lang': 'en-US'
            })
        mock_get.return_value = config

        stt = OwO.stt.OwOSTT()
        audio = mock.MagicMock()
        stt.execute(audio, 'en-us')
        self.assertTrue(OwO.stt.STTApi.called)

    @mock.patch.object(Configuration, 'get')
    def test_google_stt(self, mock_get):
        OwO.stt.Recognizer = mock.MagicMock
        config = base_config()
        config.merge(
            {
                'stt': {
                    'module': 'google',
                    'google': {'credential': {'token': 'FOOBAR'}},
                },
                'lang': 'en-US'
            })
        mock_get.return_value = config

        audio = mock.MagicMock()
        stt = OwO.stt.GoogleSTT()
        stt.execute(audio)
        self.assertTrue(stt.recognizer.recognize_google.called)

    @mock.patch.object(Configuration, 'get')
    def test_google_cloud_stt(self, mock_get):
        OwO.stt.Recognizer = mock.MagicMock
        config = base_config()
        config.merge(
            {
                'stt': {
                    'module': 'google_cloud',
                    'google_cloud': {
                        'credential': {
                            'json': {}
                        }
                    },
                },
                'lang': 'en-US'
            })
        mock_get.return_value = config

        audio = mock.MagicMock()
        stt = OwO.stt.GoogleCloudSTT()
        stt.execute(audio)
        self.assertTrue(stt.recognizer.recognize_google_cloud.called)

    @mock.patch.object(Configuration, 'get')
    def test_ibm_stt(self, mock_get):
        OwO.stt.Recognizer = mock.MagicMock
        config = base_config()
        config.merge(
            {
                'stt': {
                    'module': 'ibm',
                    'ibm': {
                        'credential': {'username': 'FOO', 'password': 'BAR'}
                    },
                },
                'lang': 'en-US'
            })
        mock_get.return_value = config

        audio = mock.MagicMock()
        stt = OwO.stt.IBMSTT()
        stt.execute(audio)
        self.assertTrue(stt.recognizer.recognize_ibm.called)

    @mock.patch.object(Configuration, 'get')
    def test_wit_stt(self, mock_get):
        OwO.stt.Recognizer = mock.MagicMock
        config = base_config()
        config.merge(
            {
                'stt': {
                    'module': 'wit',
                    'wit': {'credential': {'token': 'FOOBAR'}},
                },
                'lang': 'en-US'
            })
        mock_get.return_value = config

        audio = mock.MagicMock()
        stt = OwO.stt.WITSTT()
        stt.execute(audio)
        self.assertTrue(stt.recognizer.recognize_wit.called)

    @mock.patch('OwO.stt.post')
    @mock.patch.object(Configuration, 'get')
    def test_kaldi_stt(self, mock_get, mock_post):
        OwO.stt.Recognizer = mock.MagicMock
        config = base_config()
        config.merge(
            {
                'stt': {
                    'module': 'kaldi',
                    'kaldi': {'uri': 'https://test.com'},
                },
                'lang': 'en-US'
            })
        mock_get.return_value = config

        kaldiResponse = mock.MagicMock()
        kaldiResponse.json.return_value = {
                'hypotheses': [{'utterance': '     [noise]     text'},
                               {'utterance': '     asdf'}]
        }
        mock_post.return_value = kaldiResponse
        audio = mock.MagicMock()
        stt = OwO.stt.KaldiSTT()
        self.assertEquals(stt.execute(audio), 'text')

    @mock.patch.object(Configuration, 'get')
    def test_bing_stt(self, mock_get):
        OwO.stt.Recognizer = mock.MagicMock
        config = base_config()
        config.merge(
            {
                'stt': {
                    'module': 'bing',
                    'bing': {'credential': {'token': 'FOOBAR'}},
                },
                'lang': 'en-US'
            })
        mock_get.return_value = config

        audio = mock.MagicMock()
        stt = OwO.stt.BingSTT()
        stt.execute(audio)
        self.assertTrue(stt.recognizer.recognize_bing.called)

    @mock.patch.object(Configuration, 'get')
    def test_houndify_stt(self, mock_get):
        OwO.stt.Recognizer = mock.MagicMock
        config = base_config()
        config.merge(
            {
                'stt': {
                    'module': 'houndify',
                    'houndify': {'credential': {
                        'client_id': 'FOO',
                        'client_key': "BAR"}}
                },
                'lang': 'en-US'
            })
        mock_get.return_value = config

        audio = mock.MagicMock()
        stt = OwO.stt.HoundifySTT()
        stt.execute(audio)
        self.assertTrue(stt.recognizer.recognize_houndify.called)
