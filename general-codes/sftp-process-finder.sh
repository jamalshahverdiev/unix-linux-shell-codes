#!/usr/local/bin/bash

# This line will find SFTP pid

ps -ax | grep '[s]shd:.*@notty' | grep -v ^root
