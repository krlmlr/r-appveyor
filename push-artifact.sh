#!/bin/sh

echo $1
echo $1 | sed 's-/-\\-g'
appveyor PushArtifact $(echo $1 | sed 's-/-\\-g')
