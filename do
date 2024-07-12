#!/bin/bash
set -e

if [ -z "$DOCKER_COMPOSE_COMMAND" ]
then
    DOCKER_COMPOSE_COMMAND="docker compose"
fi

if [ -z "$1" ]
then
    echo "Usage:"
    echo "./do run [command] - run a command"
    exit 1
fi

if [ "$1" == "build" ] || [ "$1" == "b" ]
then
    echo Running: ${DOCKER_COMPOSE_COMMAND} build
    ${DOCKER_COMPOSE_COMMAND} build
    exit 0
fi

if [ "$1" == "up" ] || [ "$1" == "u" ]
then
    echo Running: ${DOCKER_COMPOSE_COMMAND} up -d --remove-orphans
    ${DOCKER_COMPOSE_COMMAND} up -d --remove-orphans
    exit 0
fi

if [ "$1" == "down" ] || [ "$1" == "d" ]
then
    echo Running: ${DOCKER_COMPOSE_COMMAND} down "${@:2}"
    ${DOCKER_COMPOSE_COMMAND} down "${@:2}"
    exit 0
fi

if [ "$1" == "restart" ] || [ "$1" == "rs" ]
then
    echo Running: ${DOCKER_COMPOSE_COMMAND} restart "${@:2}"
    ${DOCKER_COMPOSE_COMMAND} restart "${@:2}"
    exit 0
fi

if [ "$1" == "run" ] || [ "$1" == "r" ]
then
    echo Running: ${DOCKER_COMPOSE_COMMAND} run blade ${@:2}
    ${DOCKER_COMPOSE_COMMAND} run blade "${@:2}"
    exit 0
fi

if [ "$1" == "rake" ] || [ "$1" == "rk" ]
then
    echo Running: ${DOCKER_COMPOSE_COMMAND} run blade rake ${@:2}
    ${DOCKER_COMPOSE_COMMAND} run blade rake "${@:2}"
    exit 0
fi

if [ "$1" == "cs" ] || [ "$1" == "c" ]
then
    echo Running: ${DOCKER_COMPOSE_COMMAND} run blade rake standard "${@:2}"
    ${DOCKER_COMPOSE_COMMAND} run blade rake standard "${@:2}"
    exit 0
fi

if [ "$1" == "test" ] || [ "$1" == "t" ]
then
    echo Running: ${DOCKER_COMPOSE_COMMAND} run blade rake test "${@:2}"
    ${DOCKER_COMPOSE_COMMAND} run blade rake test "${@:2}"
    exit 0
fi

if [ "$1" == "l" ] || [ "$1" == "log" ] || [ "$1" == "logs" ]
then
    echo Running: ${DOCKER_COMPOSE_COMMAND} logs "${@:2}"
    ${DOCKER_COMPOSE_COMMAND} logs "${@:2}"
    exit 0
fi

if [ "$1" == "ps" ]
then
    echo Running: ${DOCKER_COMPOSE_COMMAND} ps "${@:2}"
    ${DOCKER_COMPOSE_COMMAND} ps "${@:2}"
    exit 0
fi

echo Running: ${DOCKER_COMPOSE_COMMAND} "${@:1}"
${DOCKER_COMPOSE_COMMAND} "${@:1}"
