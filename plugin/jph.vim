if exists('g:loaded_jph')
	finish
endif
let g:loaded_jph = 1

let s:save_cpo = &cpo
set cpo&vim

if jph#init() == 0
	autocmd FileType $HOME/kadai/java19/*/*.java :call jph#initialCodeInsert()
endif
command! Jph call jph#main()

let &cpo = s:save_cpo
unlet s:save_cpo
