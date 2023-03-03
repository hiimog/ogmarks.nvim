#!/bin/bash

set -e

yarn config:build 
mkdir -p ~/.config/nvim/rplugin/node/ogmarks.nvim
yarn tsc -p ./config/tsconfig.json
cp ./package.json ./dist/ 
cp -r ./dist/* ~/.config/nvim/rplugin/node/ogmarks.nvim/
nvim -c "UpdateRemotePlugins | q!"