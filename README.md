# ogmarks.nvim

Opinionated and persistent marking

## Install

`:CocInstall ogmarks.nvim`

## Keymaps

`nmap <silent> <C-l> <Plug>(coc-ogmarks.nvim-keymap)`

## Lists

`:CocList demo_list`

# Building

- make sure that `sourcemap: 'inline'` is set in `esbuild.js`

# Debugging
- to debug tests run `yarn test:debug` and then in chrome open node inspector for port 9229

## License

MIT

---

> This extension is built with [create-coc-extension](https://github.com/fannheyward/create-coc-extension)
