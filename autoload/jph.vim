function! jph#init()

	let Java19DirPath = $HOME . '/kadai/java19/lec\d\{1,2}'
	let WorkingDirPath = s:FilePath[0:41]
	if match(WorkingDirPath, Java19DirPath) == 0
		if isdirectory('src') == 0
			call mkdir('src')
		endif
		if isdirectory('junit') == 0
			call mkdir('junit')
			let GetDebugOnlyJavaFile = 'cp /home/teachers/skeleton/INjava/' . s:FileName[0:4] . '*test.java' . ' junit/'
			call system(GetDebugOnlyJavaFile)
			if v:shell_error != 0
				echohl ErrorMsg
				echo '[ Error ] ' . s:FileName[0:4] . '*test.javaの取得に失敗しました'
				echohl None
			endif
		endif
	else
		echohl ErrorMsg
		echomsg '[ Error ] ~/kadai/java19/lecXX 以外の場所では使用できません'
		echohl None
		return 1
	endif
endfunction

function! jph#main()

	"開いているファイル名を取得
	let s:FileName = expand("%")
	"フルパス取得(ファイル名含む)
	let s:FilePath = expand("%:p")

	" 必要なディレクトリなどを準備する
	if jph#init() == 0

		" カレントバッファが workYY.java かどうか確認
		let WorkJavaFileName = 'work\d\{1,2}\.java'
		if match(s:FileName, WorkJavaFileName) == 0
			" javac コマンドを準備
			let JavaCompile = 'javac ' . s:FileName[0:10]
			" javac コマンドを実行して、出力を変数に格納
			let OutPut = system(JavaCompile)
			" 出力があった＝コンパイルエラー　と判断する
			if  len(OutPut) > 0
				" ターミナルでわざとコンパイルしてエラー文を閲覧できるようにする
				call feedkeys("\<C-w>")
				call feedkeys("j")
				call feedkeys("i" . "\<CR>")
				call feedkeys(JavaCompile . "\<CR>")
			else
				" 先頭の行に飛ぶ
				execute 'normal gg'
				" package src; がなければ
				if search('package src;') == 0
					" 先頭に package src; を追記
					call append(0, "package src;")
					execute 'w'
				endif
				" workYY.java を srcディレクトリへコピーするコマンドを準備
				let CopyJavaFileToSRC = 'cp ' . s:FileName[0:10] . ' src/'
				" workYY.java の デバッグに必要なファイルを失敬するコマンドの準備
				let GetJunitSh = 'cp /home/teachers/skeleton/INjava/' . s:FileName[0:5] . 'test.sh' . ' ./'
				" システムコマンドをそれぞれ実行
				call system(CopyJavaFileToSRC)
				call system(GetJunitSh)
				" デバッグ用のスクリプトファイルを実行するコマンドを準備
				let JunitSh = 'sh ' . s:FileName[0:5] . 'test.sh'
				" システムコマンドを実行、デバッグ結果を変数に格納する
				let OutPut = system(JunitSh)
				" 出力が70文字以下なら問題はないだろうという判断を下す
				if len(OutPut) <= 70
					let FindObject = s:FileName[0:5] . 'test.txt'
					if findfile(FindObject, s:FilePath[0:42]) == FindObject
						echomsg '[ Success ] I think no problems.'
						let CopyJavaFileToCurrentDir = 'cp src/' . s:FileName[0:10] . ' ' . s:FileName[0:10] 
						call system(CopyJavaFileToCurrentDir)
						execute 'e!'
						execute 'normal gg'
						execute 'normal dd'
						execute 'w'
						let JavaCompile = 'javac ' . s:FileName[0:10]
						call feedkeys("\<C-w>")
						call feedkeys("j")
						call feedkeys("i" . "\<CR>")
						call feedkeys(JavaCompile . "\<CR>")
						if delete(s:FileName[0:5] . 'test.sh') == 0
							echomsg '[ Success ] Deleted the file.'
						endif
					endif
				endif
			endif
		endif
	endif
endfunction

function! jph#initialCodeInsert()

	" 新規ファイルの場合バッファしか存在せずファイル容量の確認ができないので保存して誤作動をさける。
	execute 'w'

	if getfsize(s:FilePath) == 0
		let ClassName = 'class ' . s:FileName[0:5] . ' {'
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
	endif
endfunction
