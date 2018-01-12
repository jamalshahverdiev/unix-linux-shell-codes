#!/usr/bin/env bash

ping 213.172.86.194 | perl -nle 'print scalar(localtime), " ", $_'
