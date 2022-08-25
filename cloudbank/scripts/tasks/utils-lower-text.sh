#!/bin/bash

a=$1

echo "$a" | awk '{print tolower($0)}'