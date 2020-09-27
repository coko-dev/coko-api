#!/bin/bash

bundle exec reek -c .reek.yml app config db --single-line --no-color
exit $?
