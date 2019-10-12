if exists('g:loaded_jph')
	finish
endif
let g:loaded_jph = 1

let s:save_cpo = &cpo
set cpo&vim

if g:window_setting == 1
	autocmd VimEnter * execute 'syntax on'
	autocmd VimEnter * execute 'sp'
	autocmd VimEnter * execute 'terminal'
	autocmd VimEnter * call feedkeys("\<C-w>", "n")
	autocmd VimEnter * call feedkeys("l", "n")
	autocmd VimEnter * call feedkeys("\<C-w>", "n")
	autocmd VimEnter * call feedkeys("x", "n")
endif

command! Jph call jph#main()

let &cpo = s:save_cpo
unlet s:save_cpo
