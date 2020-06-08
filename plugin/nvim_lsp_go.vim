if exists('g:nvim_lsp_go')
  finish
endif
let g:nvim_lsp_go = 1

lua << EOF
vim.lsp_go = require'nvim_lsp_go'
EOF
