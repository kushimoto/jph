if exists('g:loaded_jph')
	finish
endif
let g:loaded_jph = 1

command! Jph call jph#main()
