function! jph#main()
	"開いているファイル名を取得
	let FileName = expand("%")
	"フルパス取得(ファイル名含む)
	let FilePath = expand("%:p")

	" 新規ファイルの場合バッファしか存在しないので保存して誤作動をさける。
	execute 'w'

	if getfsize(FilePath) == 0
		let ClassName = 'class ' . FileName[0:5] . ' {'
		call append(0, 'import java.io.*;')
		call append(2, ClassName)
		call append(3, '	public static void main (String[] args) throws IOException')
		call append(4, '        {')
		call append(5, '')
		call append(6, '')
		call append(7, '')
		call append(8, '        }')
		call append(9, '}')
		execute 'w'
	else
		" ~/kadai/java19/lecXX ディレクトリで実行されているかを確認
		if FilePath[0:39] == '/home/students/e1n18030/kadai/java19/lec'
			if isdirectory('src') == 0
				call mkdir('src')
			endif
			if isdirectory('junit') == 0
				call mkdir('junit')
				let GetDebugOnlyJavaFile = 'cp /home/teachers/skeleton/INjava/' . FileName[0:4] . '*test.java' . ' junit/'
				call system(GetDebugOnlyJavaFile)
				if v:shell_error != 0
					echo '[ Error ] ' . FileName[0:4] . '*test.javaの取得に失敗しました'
				endif
			endif
		endif

		" カレントバッファを簡易確認
		if FileName[0:3] == 'work'
			let JavaCompile = 'javac ' . FileName[0:10]
			let OutPut = system(JavaCompile)
			if  len(OutPut) > 0
				call feedkeys("\<C-w>")
				call feedkeys("j")
				call feedkeys("i" . "\<CR>")
				call feedkeys(JavaCompile . "\<CR>")
			else
				execute 'normal gg'
				if search('package src;') == 0
					" 先頭に package src; を追記
					call append(0, "package src;")
					execute 'w'
				endif
				let CopyJavaFileToSRC = 'cp ' . FileName[0:10] . ' src/'
				let GetJunitSh = 'cp /home/teachers/skeleton/INjava/' . FileName[0:5] . 'test.sh' . ' ./'
				call system(CopyJavaFileToSRC)
				call system(GetJunitSh)
				let JunitSh = 'sh ' . FileName[0:5] . 'test.sh'
				let OutPut = system(JunitSh)
				if len(OutPut) <= 70
					let FindObject = FileName[0:5] . 'test.txt'
					if findfile(FindObject, FilePath[0:42]) == FindObject
						echomsg '[ Success ] I think no problems.'
						let CopyJavaFileToCurrentDir = 'cp src/' . FileName[0:10] . ' ' . FileName[0:10] 
						call system(CopyJavaFileToCurrentDir)
						execute 'e!'
						execute 'normal gg'
						execute 'normal dd'
						execute 'w'
						let JavaCompile = 'javac ' . FileName[0:10]
						call feedkeys("\<C-w>")
						call feedkeys("j")
						call feedkeys("i" . "\<CR>")
						call feedkeys(JavaCompile . "\<CR>")
						if delete(FileName[0:5] . 'test.sh') == 0
							echomsg '[ Success ] Deleted the file.'
						endif
					endif
				endif
			endif
		endif
	endif
endfunction
