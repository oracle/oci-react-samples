#!/bin/bash

read -r -p  "Proceed with inputs (please confirm that the entered values are correct)? [y/N]" response
response=$(echo "$response" | awk '{print tolower($0)}')
echo ""

if [[ "$response" =~ ^(yes|y)$ ]]; then
    exit 1
else
    exit 0
fi;