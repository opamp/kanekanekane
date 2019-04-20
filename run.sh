#!/bin/bash

# run.sh is a simple script to run this app for development
# 1. preparation
#     1. $ ros install t-sin/ros-tap
#     2. $ ros tap tap kanekanekane.asd
# 2. run this script
#     1. $ ./run.sh

APP_ENV=development clackup --server :woo --port 5000 app.lisp
