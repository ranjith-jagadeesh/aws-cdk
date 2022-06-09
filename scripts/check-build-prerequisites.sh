#!/bin/bash
set -euo pipefail

scriptdir=$(cd $(dirname $0) && pwd)

# Testing with this to simulate different installed apps:
# docker run -it -v ~/Source/aws-cdk:/var/cdk ubuntu bash

# Note: Don't use \d in regex, it doesn't work on Macs without GNU tools installed
# Use [0-9] instead

die() { echo "$*" 1>&2 ; exit 1; }
wrong_version() { echo "Found $app version $app_v. Install $app >= $app_min" 1>&2; exit 1; }

check_which() {
    local app=$1
    local min=$2

    echo -e "Checking if $app is installed... \c"

    w=$(which ${app}) || w=""

    if [ -z "$w" ] || [ "$w" == "$app not found" ]
    then
        die "Missing dependency: $app. Install $app >= $min"
    else
        echo "Ok"
    fi
}

app=""
app_min=""
app_v=""

# [Node.js >= 14.15.0]
app="node"
app_min="v14.15.0"
check_which $app $app_min
app_v=$(node -p 'process.version')

# Check for version 10.*.* - 29.*.*
echo -e "Checking node version... \c"
if [ $(node -p "const [major, minor, _patch] = process.version.slice(1).split('.').map((v) => parseInt(v, 10)); major > 14 || (major === 14 && minor >= 15)") = 'true' ]
then
    echo "Ok (${app_v})"
else
    echo "Not >= ${app_min}"
    wrong_version
fi

# [Yarn >= 1.19.1, < 1.30]
app="yarn"
app_min="1.19.1"
check_which $app $app_min
app_v=$(${app} --version)
echo -e "Checking yarn version... \c"
if [ $(echo $app_v | grep -c -E "1\.(19|2[0-9])\.[0-9]+") -eq 1 ]
then
    echo "Ok"
else
    wrong_version
fi

# [Docker >= 19.03]
app="docker"
app_min="19.03.0"
check_which $app $app_min

# Make sure docker is running
echo -e "Checking if docker is running... \c"
docker_running=$(docker ps)
if [ $? -eq 0 ]
then
    echo "Ok"
else
    die "Docker is not running"
fi

# [.NET == 3.1.x, == 5.x]
app="dotnet"
app_min="3.1.0"
check_which $app $app_min
app_v=$(${app} --list-sdks)
echo -e "Checking dotnet version... \c"
if [ $(echo $app_v | grep -c -E "(3\.1\.[0-9]+|5\.[0-9]+\.[0-9]+|6\.[0-9]+\.[0-9]+)") -eq 1 ]
then
    echo "Ok"
else
    wrong_version
fi

# [Python >= 3.6.5, < 4.0]
app="python3"
app_min="3.6.5"
check_which $app $app_min
app_v=$(${app} --version)
echo -e "Checking python3 version... \c"
if [ $(echo $app_v | grep -c -E "3\.([6-9]|1[0-9])\.[0-9]+") -eq 1 ]
then
    echo "Ok"
else
    wrong_version
fi
