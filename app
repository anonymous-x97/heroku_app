#!/bin/bash
# Copyright (C) 2021 MyGpack

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


# error precaution.
set -e

WORK_DIR="app"
mkdir -p $WORK_DIR

disp () {
    echo "-----> $*"
}

indent () {
    sed -u 's/^/       /'
}

_done () {
    echo -e "Done\n" | indent
}

get_branch () {
    local branch
    if [[ $PREF_BRANCH ]]
    then
        branch=$(echo $PREF_BRANCH | xargs)
    else
        branch=alpha
    fi
    echo "/archive/refs/heads/$branch.zip"
}

get_ziplink () {
    local regex
    regex='(https?)://github.com/.+/.+'
    if [[ $UPSTREAM_REPO =~ $regex ]]
    then 
        echo "${UPSTREAM_REPO}$(get_branch)"
    else
        echo "$(echo "aHR0cHM6Ly9naXRodWIuY29tL2NvZGUtcmdiL1VTRVJHRS1Y" | base64 -d)$(get_branch)"
    fi
}

_setup_repo () {
    local zippath
    zippath="$WORK_DIR/temp.zip"
    disp "Fetching Update from Upstream Repo"
    wget -qq $(get_ziplink) -O "$zippath"
    _done
    disp "Unpacking Data"
    unzip -qq "$zippath" -d "$WORK_DIR"
    _done
    disp "Cleaning"
    rm -rf "$zippath"
    _done
}

_startbot () {
    local bot_dir
    bot_dir=$(cd $WORK_DIR && ls) && mv "$WORK_DIR/$bot_dir" "apps"
    rm -rf $WORK_DIR
    cd "apps"
    git init > /dev/null 2>&1
    echo -e ">><< --- >><<  Starting [X]  >><< --- >><<\n" | indent
    pip install -q -r requirements*
    bash run
}

begin_x () {
    _setup_repo
    _startbot
}

begin_x