#!/bin/sh

appveyor PushArtifact $(echo $1 | sed 's-/-\\-g')
