#!/bin/bash
cd ~/Engineering/repos/dev-bootstrap || exit 1
git pull origin main

export GHORG_ORG=Docpier-Labs
export GHORG_CLONE_TYPE=ssh
export GHORG_OUTPUT_DIR=~/Engineering/repos

ghorg pull $GHORG_ORG
