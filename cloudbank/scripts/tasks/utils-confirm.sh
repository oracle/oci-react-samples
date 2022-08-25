#!/bin/bash

echo ""
read -r -p  "Please confirm that the entered values are correct. Proceed with inputs? [y/N] " response
response=$(echo "$response" | awk '{print tolower($0)}')
echo ""

if [[ "$response" =~ ^(yes|y)$ ]]; then
    exit 1
else
    exit 0
fi;