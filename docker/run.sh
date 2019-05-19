#!/bin/sh

APP_ENV=production clackup --server :woo --address 0.0.0.0 --port 8080 app.lisp
