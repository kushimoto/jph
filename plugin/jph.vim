if exists('g:loaded_jph')
	finish
endif
let g:loaded_jph = 1

command! jph call jph#main()
