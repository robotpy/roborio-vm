#!/bin/bash

echo "Resetting RobotRIO VM image back to initial state..."

read -r -p "Are you sure? [y/N] " response
case $response in
    [yY][eE][sS]|[yY]) 
        qemu-img snapshot -a initial roborio.img
        echo "RoboRIO VM image restored to initial state"
        ;;
    *)
        do_something_else
        ;;
esac
