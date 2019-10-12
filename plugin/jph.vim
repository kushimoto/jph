if exists('g:loaded_jph')
	finish
endif
let g:loaded_jph = 1

let s:save_cpo = &cpo
set cpo&vim

autocmd FileType work\d{1,2}\.java :call initialCodeInsert()
command! Jph call jph#main()

let &cpo = s:save_cpo
unlet s:save_cpo
