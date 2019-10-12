if exists('g:loaded_jph')
	finish
endif
let g:loaded_jph = 1

let s:save_cpo = &cpo
set cpo&vim

autocmd FileType $HOME/kadai/java19/*/*.java :call jph#initialCodeInsert()
command! Jph call jph#main()

let &cpo = s:save_cpo
unlet s:save_cpo
