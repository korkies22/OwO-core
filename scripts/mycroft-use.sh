#!/usr/bin/env bash

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

# this script is for the Mark 1 and Picroft units

user=$( whoami )
#Build being changed to
change_to=${1}
#path to OwO-core checkout
path=${2:-"${HOME}/OwO-core"}
#currently installed package
current_pkg=$( cat /etc/apt/sources.list.d/repo.OwO.ai.list )
stable_pkg="deb http://repo.OwO.ai/repos/apt/debian debian main"
unstable_pkg="deb http://repo.OwO.ai/repos/apt/debian debian-unstable main"

mark_1_package_list="OwO-mark-1 OwO-core OwO-wifi-setup"
picroft_package_list="OwO-picroft OwO-core OwO-wifi-setup"

# Determine the platform
OwO_platform="null"
if [[ -r /etc/OwO/OwO.conf ]] ; then
    OwO_platform=$( jq -r '.enclosure.platform' /etc/OwO/OwO.conf )
else
    if [[ "$( hostname )" == "picroft" ]] ; then
        OwO_platform="picroft"
    elif [[ "$( hostname )" =~ "mark_1" ]] ; then
        OwO_platform="OwO_mark_1"
    fi
fi

function service_ctl() {
    service=${1}
    action=${2}
    sudo /etc/init.d/${service} ${action}
}

function stop_OwO() {
    service_ctl OwO-audio stop
    service_ctl OwO-skills stop
    service_ctl OwO-speech-client stop
    service_ctl OwO-enclosure-client stop
    service_ctl OwO-admin-service stop
    service_ctl OwO-messagebus stop
}

function start_OwO() {
    service_ctl OwO-messagebus start
    service_ctl OwO-enclosure-client start
    service_ctl OwO-audio start
    service_ctl OwO-skills start
    service_ctl OwO-speech-client start
    service_ctl OwO-admin-service start
}

function restart_OwO() {
    service_ctl OwO-messagebus restart
    service_ctl OwO-audio restart
    service_ctl OwO-skills restart
    service_ctl OwO-speech-client restart
    service_ctl OwO-enclosure-client restart
    service_ctl OwO-admin-service restart
}

#Changes init scripts back to the original versions
function restore_init_scripts() {
    # stop running OwO services
    stop_OwO

    # swap back to original service scripts
    sudo sh -c 'cat /etc/init.d/OwO-audio.original > /etc/init.d/OwO-audio'
    sudo sh -c 'cat /etc/init.d/OwO-enclosure-client.original > /etc/init.d/OwO-enclosure-client'
    sudo sh -c 'cat /etc/init.d/OwO-messagebus.original > /etc/init.d/OwO-messagebus'
    sudo sh -c 'cat /etc/init.d/OwO-skills.original > /etc/init.d/OwO-skills'
    sudo sh -c 'cat /etc/init.d/OwO-speech-client.original > /etc/init.d/OwO-speech-client'
    sudo sh -c 'cat /etc/init.d/OwO-admin-service.original > /etc/init.d/OwO-admin-service'
    sudo rm /etc/init.d/*.original
    chown OwO:OwO /home/OwO/.OwO/identity/identity2.json
    sudo chown -Rvf OwO:OwO /var/log/OwO*
    sudo chown -Rvf OwO:OwO /tmp/OwO
    sudo chown -Rvf OwO:OwO /var/run/OwO*
    sudo chown -Rvf OwO:OwO /opt/OwO
    sudo chown OwO:OwO /var/tmp/OwO_web_cache.json

    # reload daemon scripts
    sudo systemctl daemon-reload

    # start services back up
    start_OwO
}

function github_init_scripts() {
    if [ ! -f /etc/init.d/OwO-skills.original ] ; then
        stop_OwO

        # save original scripts
        sudo sh -c 'cat /etc/init.d/OwO-audio > /etc/init.d/OwO-audio.original'
        sudo sh -c 'cat /etc/init.d/OwO-enclosure-client > /etc/init.d/OwO-enclosure-client.original'
        sudo sh -c 'cat /etc/init.d/OwO-messagebus > /etc/init.d/OwO-messagebus.original'
        sudo sh -c 'cat /etc/init.d/OwO-skills > /etc/init.d/OwO-skills.original'
        sudo sh -c 'cat /etc/init.d/OwO-speech-client > /etc/init.d/OwO-speech-client.original'
        sudo sh -c 'cat /etc/init.d/OwO-admin-service > /etc/init.d/OwO-admin-service.original'

        # switch to point a github install and run as the current user
        # TODO Verify all of these
        sudo sed -i 's_.*SCRIPT=.*_SCRIPT="'${path}'/start-OwO.sh audio"_g' /etc/init.d/OwO-audio
        sudo sed -i 's_.*RUNAS=.*_RUNAS='${user}'_g' /etc/init.d/OwO-audio
        sudo sed -i 's_stop() {_stop() {\nPID=$(ps ax | grep OwO/audio/ | awk '"'NR==1{print \$1; exit}'"')\necho "${PID}" > "$PIDFILE"_g' /etc/init.d/OwO-audio

        sudo sed -i 's_.*SCRIPT=.*_SCRIPT="'${path}'/start-OwO.sh enclosure"_g' /etc/init.d/OwO-enclosure-client
        sudo sed -i 's_.*RUNAS=.*_RUNAS='${user}'_g' /etc/init.d/OwO-enclosure-client
        sudo sed -i 's_stop() {_stop() {\nPID=$(ps ax | grep OwO/client/enclosure/ | awk '"'NR==1{print \$1; exit}'"')\necho "${PID}" > "$PIDFILE"_g' /etc/init.d/OwO-enclosure-client

        sudo sed -i 's_.*SCRIPT=.*_SCRIPT="'${path}'/start-OwO.sh bus"_g' /etc/init.d/OwO-messagebus
        sudo sed -i 's_.*RUNAS=.*_RUNAS='${user}'_g' /etc/init.d/OwO-messagebus
        sudo sed -i 's_stop() {_stop() {\nPID=$(ps ax | grep OwO/messagebus/ | awk '"'NR==1{print \$1; exit}'"')\necho "${PID}" > "$PIDFILE"_g' /etc/init.d/OwO-messagebus

        sudo sed -i 's_.*SCRIPT=.*_SCRIPT="'${path}'/start-OwO.sh skills"_g' /etc/init.d/OwO-skills
        sudo sed -i 's_.*RUNAS=.*_RUNAS='${user}'_g' /etc/init.d/OwO-skills
        sudo sed -i 's_stop() {_stop() {\nPID=$(ps ax | grep OwO/skills/ | awk '"'NR==1{print \$1; exit}'"')\necho "${PID}" > "$PIDFILE"_g' /etc/init.d/OwO-skills

        sudo sed -i 's_.*SCRIPT=.*_SCRIPT="'${path}'/start-OwO.sh voice"_g' /etc/init.d/OwO-speech-client
        sudo sed -i 's_.*RUNAS=.*_RUNAS='${user}'_g' /etc/init.d/OwO-speech-client
        sudo sed -i 's_stop() {_stop() {\nPID=$(ps ax | grep OwO/client/speech | awk '"'NR==1{print \$1; exit}'"')\necho "${PID}" > "$PIDFILE"_g' /etc/init.d/OwO-speech-client

        # soft link the current user to the OwO user's identity folder
        chown ${user}:${user} /home/OwO/.OwO/identity/identity2.json
        if [ ! -e ${HOME}/.OwO ] ; then
            mkdir ${HOME}/.OwO
        fi
        if [ ! -e ${HOME}/.OwO/identity ] ; then
            sudo ln -s /home/OwO/.OwO/identity ${HOME}/.OwO/
        fi

        sudo chown -Rvf ${user}:${user} /var/log/OwO*
        sudo chown -Rvf ${user}:${user} /var/run/OwO*
        sudo chown -Rvf ${user}:${user} /tmp/OwO
        sudo chown -Rvf ${user}:${user} /var/tmp/OwO_web_cache.json

        # reload daemon scripts
        sudo systemctl daemon-reload

        restart_OwO
    fi
}

function invoke_apt() {
    if [ ${OwO_platform} == "OwO_mark_1" ] ; then
        echo "${1}ing the OwO-mark-1 metapackage..."
        sudo apt-get ${1} OwO-mark-1 -y
    elif [ ${OwO_platform} == "picroft" ] ; then
        echo "${1}ing the OwO-picroft metapackage..."
        sudo apt-get ${1} OwO-picroft -y
    else
        # for unknown, just update the generic package
        echo "${1}ing the generic OwO-core package..."
        sudo apt-get ${1} OwO-core -y
    fi
}

function remove_all() {
    if [ ${OwO_platform} == "OwO_mark_1" ] ; then
        echo "Removing the OwO mark-1 packages..."
        sudo apt-get remove ${mark_1_package_list} -y
    elif [ ${OwO_platform} == "picroft" ] ; then
        echo "Removing the picroft packages..."
        sudo apt-get remove ${picroft_package_list} -y
    else
        # for unknown, just update the generic package
        echo "Removing the generic OwO-core package..."
        sudo apt-get remove OwO-core -y
    fi
}

function change_build() {
    build=${1}
    sudo sh -c 'echo '"${build}"' > /etc/apt/sources.list.d/repo.OwO.ai.list'
    sudo apt-get update

    invoke_apt install
}

function stable_to_unstable_server() {
    identity_path=/home/OwO/.OwO/identity/
    conf_path=/home/OwO/.OwO/

    # check if on stable (home-test.OwO.ai) already
    cmp --silent ${conf_path}/OwO.conf ${conf_path}/OwO.conf.unstable
    if [ $? -eq 0 ] ; then
       echo "Already set to use the home-test.OwO.ai server"
       return
    fi

    # point to test server
    echo "Changing OwO.conf to point to test server api-test.OwO.ai"
    if [ -f ${conf_path}OwO.conf ] ; then
        cp ${conf_path}OwO.conf ${conf_path}OwO.conf.stable
    else
        echo "could not find OwO.conf, was it deleted?"
    fi
    if [ -f ${conf_path}OwO.conf.unstable ] ; then
        cp ${conf_path}OwO.conf.unstable ${conf_path}OwO.conf
    else
        rm -r ${conf_path}OwO.conf
        echo '{"server": {"url":"https://api-test.OwO.ai", "version":"v1", "update":true, "metrics":false }}' $( cat ${conf_path}OwO.conf.stable ) | jq -s add > ${conf_path}OwO.conf
    fi

    # saving identity2.json to stable state
    echo "Pointing identity2.json to unstable and saving to identity2.json.stable"
    if [ -f ${identity_path}identity2.json ] ; then
        mv ${identity_path}identity2.json ${identity_path}identity2.json.stable
    fi
    if [ -f /home/OwO/.OwO/identity/identity2.json.unstable ] ; then
        cp ${identity_path}identity2.json.unstable ${identity_path}identity2.json
    else
        echo "NOTE:  This seems to be your first time switching to unstable. You will need to go to home-test.OwO.ai to pair on unstable."
    fi

    restart_OwO
    echo "Set to use the home-test.OwO.ai server!"
}

function unstable_to_stable_server() {
    # switching from unstable -> stable
    identity_path=/home/OwO/.OwO/identity/
    conf_path=/home/OwO/.OwO/

    # check if on stable (home.OwO.ai) already
    cmp --silent ${conf_path}/OwO.conf ${conf_path}/OwO.conf.stable
    if [ $? -eq 0 ] ; then
        echo "Already set to use the home.OwO.ai server"
        return
    fi

    # point api to production server
    echo "Changing OwO.conf to point to production server api.OwO.ai"
    if [ -f ${conf_path}OwO.conf ] ; then
        echo '{"server": {"url":"https://api-test.OwO.ai", "version":"v1", "update":true, "metrics":false }}' $( cat ${conf_path}OwO.conf ) | jq -s add > ${conf_path}OwO.conf.unstable
    else
        echo "could not find OwO.conf, was it deleted?"
    fi
    if [ -f ${conf_path}OwO.conf.stable ] ; then
        cp ${conf_path}OwO.conf.stable ${conf_path}OwO.conf
    else
        echo "ERROR:  Could not find OwO.conf.stable, was it deleted?, an easy fix would be to copy OwO.conf.unstable to OwO.conf but remove the server field"
    fi

    # saving identity2.json into unstable state, then copying identity2.json.stable to identity2.json
    echo "Pointing identity2.json to unstable and saving to identity2.json.unstable"
    if [ -f ${identity_path}identity2.json ] ; then
        mv ${identity_path}identity2.json ${identity_path}identity2.json.unstable
    fi
    if [ -f ${identity_path}identity2.json.stable ] ; then
        cp ${identity_path}identity2.json.stable ${identity_path}identity2.json
    else
        echo "Can not find identity2.json.stable, was it deleted? You may need to repair at home.OwO.ai"
    fi

    restart_OwO
    echo "Set to use the home.OwO.ai server!"
}

if [ "${change_to}" == "unstable" ] ; then
    # make sure user is running as sudo first
    if [ "$EUID" -ne 0 ] ; then
        echo "Please run with sudo"
        exit
    fi

    echo "Switching to unstable build..."
    if [ "${current_pkg}" == "${stable_pkg}" ] ; then
        change_build "${unstable_pkg}"
    else
        echo "already on unstable"
    fi

    if [ -f /etc/init.d/OwO-skills.original ] ; then
        restore_init_scripts
        # Reboot since the audio input won't work for some reason
        sudo reboot
    fi
elif [ "${change_to}" == "stable" ] ; then
    # make sure user is running as sudo first
    if [ "$EUID" -ne 0 ] ; then
        echo "Please run with sudo"
        exit
    fi

        echo "Switching to stable build..."
        if [ "${current_pkg}" == "${unstable_pkg}" ] ; then
            # Need to remove the package to make sure upgrade happens due to
            # difference in stable/unstable to package numbering schemes
            remove_all

            change_build "${stable_pkg}"
        else
            echo "already on stable"
        fi

        if [ -f /etc/init.d/OwO-skills.original ] ; then
            restore_init_scripts
            sudo chmod -x /etc/cron.hourly/OwO-core # Enable updates

            # Reboot since the audio input won't work for some reason
            sudo reboot
        fi

elif [ "${change_to}" == "github" ] ; then
    echo "Switching to github..."
    if [ ! -d ${path} ] ; then
        mkdir --parents "${path}"
        cd "${path}"
        cd ..
        git clone https://github.com/OwOAI/OwO-core.git "${path}"
    fi

    sudo chmod -x /etc/cron.hourly/OwO-core # Disable updates

    if [ -d ${path} ] ; then
        if  [ -f /usr/local/bin/mimic ] ; then
            echo "Mimic file exists"
            mimic_flag="-sm"
        else
            echo "file doesn't exist"
            mimic_flag=""
        fi
        cd ${path}
        # Build the dev environment
        ${path}/dev_setup.sh --allow-root ${mimic_flag}

        # Switch init scripts to start the github version
        github_init_scripts
    else
        echo "repository does not exist"
    fi
    # For some reason precise won't trigger until after a reboot
    echo "Rebooting..."
    sudo reboot
elif [ "${change_to}" == "home" ] ; then
    # make sure user is running as sudo first
    if [ "$EUID" -ne 0 ] ; then
        echo "Please run with sudo"
        exit
    fi
    unstable_to_stable_server
elif [ "${change_to}" == "home-test" ] ; then
    # make sure user is running as sudo first
    if [ "$EUID" -ne 0 ] ; then
        echo "Please run with sudo"
        exit
    fi
    stable_to_unstable_server
else
    echo "usage: OwO-use.sh [stable | unstable | home | home-test | github [<path>]]"
    echo "Switch between OwO-core install methods"
    echo
    echo "Options:"
    echo "  stable           switch to the current debian package"
    echo "  unstable         switch to the unstable debian package"
    echo "  github [<path>]  switch to the OwO-core/dev github repo"
    echo
    echo "  home-test        switch to the test backend (home-test.OwO.ai)"
    echo "  home             switch to the main backend (home.OwO.ai)"
    echo
    echo "Params:"
    echo "  <path>  default for github installs is /home/<user>/OwO-core"
    echo
    echo "Examples:"
    echo "  OwO-use.sh stable"
    echo "  OwO-use.sh unstable"
    echo "  OwO-use.sh home"
    echo "  OwO-use.sh home-test"
    echo "  OwO-use.sh github"
    echo "  OwO-use.sh github /home/bill/projects/OwO/custom"
fi
