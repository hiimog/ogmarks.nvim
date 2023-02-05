# ogmarks.nvim
Opinionated bookmark plugin for neovim.

# Why OG?
Because names are hard and braning is good.

# Installation
- Make sure you have sqlite3 installed

## Manual
```bash
# install sqlite library
luarocks install lsqlite3

# install helpful lua library
luarocks install penlight

# clone project with the other plugins
git clone https://github.com/hiimog/ogmarks.nvim.git ~/.config/nvim/plugins/

# add ogmarks to your runtime path
echo "set rtp^=~/.config/nvim/plugins/ogmarks.nvim" >> ~/.vimrc
```

## Packer
```lua
use {"hiimog/ogmarks.nvim", 
    tag="alpha.0.1", 
    rocks = {
        "lsqlite3",
        "penlight"
    }
}
```

# Running Tests
- note we are using a fork of `plenary.nvim` until [this](https://github.com/nvim-lua/plenary.nvim/pull/455) PR is merged
## Using Docker
- after the first build, the tests will run very quickly
```bash
# at project root
docker build -f tests/Dockerfile . -t ogmarks:test
docker run --rm ogmarks:test
```
- if you need to check logs or the test db files you can use the following
```bash
docker ps -a
# note the container id
docker commit $CONTAINER_ID ogmarks:testdbg

docker run -it ogmarks:testdbg /bin/bash
```

## Manually
```bash
# at project root
nvim -u tests/minimum_init.vim -c "PlenaryBustedDirectory tests/specs { minimal_init = 'tests/minimum_init.vim', sequential=true }"
```