# Test and Debug
`alias t="sudo docker build -f ./tests.Dockerfile . -t test:dev && sudo docker run --rm test:dev"`
`alias dbg="sudo docker build -f ./tests.Dockerfile . -t test:dev && sudo docker run --rm -it test:dev /bin/bash"`
`alias local='rm -rf ~/.config/nvim/rplugin/node/ogmarks.nvim && yarn test:build && nvim -c "UpdateRemotePlugins | q!" && nvim'`