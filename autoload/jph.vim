function! jph#main()
		echomsg 'W' = WorkFlag

	"開いているファイル名を取得
	let s:FileName = expand("%")
	"フルパス取得(ファイル名含む)
	let s:FilePath = expand("%:p")
	let WorkFlag = 0
	let RevFlag = 0
	" カレントバッファが workYY.java かどうか確認
	let WorkJavaFileName = 'work\d\{1,2}\.java'
	let RevJavaFileName = 'rev\d\{1,2}\.java'
	if match(s:FileName, WorkJavaFileName) == 0
		let WorkFlag = 1
	elseif match(s:FileName, RevJavaFileName) == 0 
		let RevFlag = 1		
	endif
	" 必要なディレクトリなどを準備する
	if jph#init() == 0
		
		if WorkFlag == 1 || RevFlag == 1
			" javac コマンドを準備
			let JavaCompile = 'javac ' . s:FileName
			" javac コマンドを実行して、出力を変数に格納
			let OutPut = system(JavaCompile)
			" 出力があった＝コンパイルエラー　と判断する
			if  len(OutPut) > 0
				" ターミナルでわざとコンパイルしてエラー文を閲覧できるようにする
				call feedkeys("\<C-w>")
				call feedkeys("j")
				call feedkeys("i" . "\<CR>")
				call feedkeys(JavaCompile . "\<CR>")
				call feedkeys("\<C-\>")
				call feedkeys("\<C-n>" . "\<CR>")
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
				let CopyJavaFileToSRC = 'cp ' . s:FileName . ' src/'
				" workYY.java の デバッグに必要なファイルを失敬するコマンドの準備(len は 0から数えていることに注意)
				if WorkFlag == 1
					let GetJunitSh = 'cp /home/teachers/skeleton/INjava/' . s:FileName[0:len(s:FileName) - 6] . 'test.sh' . ' ./'
				elseif RevFlag == 1
					let GetJunitSh = 'cp /home/teachers/skeleton/INjava/' . s:FileName[0:len(s:FileName) - 5] . 'test.sh' . ' ./'
				endif
				" システムコマンドをそれぞれ実行
				call system(CopyJavaFileToSRC)
				call system(GetJunitSh)
				" デバッグ用のスクリプトファイルを実行するコマンドを準備
				if WorkFlag == 1
					let JunitSh = 'sh ' . s:FileName[0:len(s:FileName) - 6] . 'test.sh'
				elseif RevFlag == 1
					let JunitSh = 'sh ' . s:FileName[0:len(s:FileName) - 5] . 'test.sh'
				endif
				" システムコマンドを実行、デバッグ結果を変数に格納する
				let OutPut = system(JunitSh)
				" 出力が70文字以下なら問題はないだろうという判断を下す
				if len(OutPut) <= 70
					if WorkFlag == 1
						let FindObject = s:FileName[0:len(s:FileName) - 6] . 'test.txt'
						let FindPath = s:FilePath[0:len(s:FilePath) - 12] 
					elseif RevFlag == 1
						let FindObject = s:FileName[0:len(s:FileName) - 5] . 'test.txt'
						let FindPath = s:FilePath[0:len(s:FilePath) - 11] 
					endif
					if findfile(FindObject, ) == FindObject
						echomsg '[ Success ] I think no problems.'
						let CopyJavaFileToCurrentDir = 'cp src/' . s:FileName . ' ' . s:FileName 
						call system(CopyJavaFileToCurrentDir)
						execute 'e!'
						execute 'normal gg'
						execute 'normal dd'
						execute 'w'
						let JavaCompile = 'javac ' . s:FileName
						call feedkeys("\<C-w>")
						call feedkeys("j")
						call feedkeys("i" . "\<CR>")
						call feedkeys(JavaCompile . "\<CR>")
						if WorkFlag == 1
							if delete(s:FileName[0:len(s:FileName) - 6] . 'test.sh') == 0
								echomsg '[ Success ] Deleted the file.'
							endif
						elseif RevFlag == 1
							if delete(s:FileName[0:len(s:FileName) - 5] . 'test.sh') == 0
								echomsg '[ Success ] Deleted the file.'
							endif
						endif
					endif
				else
					execute 'normal gg'
					execute 'normal dd'
					execute 'w'
					" ターミナルでわざとコンパイルしてエラー文を閲覧できるようにする
					call feedkeys("\<C-w>")
					call feedkeys("j")
					call feedkeys("i" . "\<CR>")
					call feedkeys(JavaCompile . "\<CR>")
					call feedkeys("\<C-\>")
					call feedkeys("\<C-n>" . "\<CR>")
					echohl ErrorMsg
					echomsg '[ Error ] デバッグに失敗しました。'
					echohl None
				endif
			endif
		endif
	endif
endfunction

function! jph#init()
	"開いているファイル名を取得
	let s:FileName = expand("%")
	"フルパス取得(ファイル名含む)
	let s:FilePath = expand("%:p")
	let WorkFlag = 0
	let RevFlag = 0
	" カレントバッファが workYY.java かどうか確認
	let WorkJavaFileName = 'work\d\{1,2}\.java'
	let RevJavaFileName = 'rev\d\{1,2}\.java'

	if match(s:FileName, WorkJavaFileName) == 0
		let WorkFlag = 1
	elseif match(s:FileName, RevJavaFileName) == 0 
		let RevFlag = 1		
	endif
	
	let Java19DirPath = $HOME . '/kadai/java19/lec\d\{1,2}'
	let WorkingDirPath = 'path'
	if WorkFlag == 1
		let WorkingDirPath = s:FilePath[0:len(s:FilePath) - 13]
	elseif RevFlag == 1
		let WorkingDirPath = s:FilePath[0:len(s:FilePath) - 12]
	endif

	if match(WorkingDirPath, Java19DirPath) == 0
		if isdirectory('src') == 0
			call mkdir('src')
		endif
		if isdirectory('junit') == 0
			call mkdir('junit')
		if WorkFlag == 1
			let GetDebugOnlyJavaFile = 'cp /home/teachers/skeleton/INjava/' . s:FileName[0:4] . '*test.java' . ' junit/'
		elseif RevFlag == 1
			let GetDebugOnlyJavaFile = 'cp /home/teachers/skeleton/INjava/' . s:FileName[0:3] . '*test.java' . ' junit/'
		endif
			call system(GetDebugOnlyJavaFile)
			if v:shell_error != 0
				echohl ErrorMsg
				if WorkFlag == 1
					echo '[ Error ] ' . s:FileName[0:4] . '*test.javaの取得に失敗しました'
				elseif RevFlag == 1
					echo '[ Error ] ' . s:FileName[0:3] . '*test.javaの取得に失敗しました'
				endif
				echohl None
			endif
		endif
	else
		echohl ErrorMsg
		echomsg '[ Error ] ~/kadai/java19/lecXX 以外の場所では使用できません'
		echomsg '[ Error ] 'WorkingDirPath . '不一致' . Java19DirPath 
		echohl None
		return 1
	endif
endfunction

function! jph#initialCodeInsert()

	"開いているファイル名を取得
	let s:FileName = expand("%")
	"フルパス取得(ファイル名含む)
	let s:FilePath = expand("%:p")
	let WorkJavaFileName = 'work\d\{1,2}\.java'
	let RevJavaFileName = 'rev\d\{1,2}\.java'
	let WorkFlag = 0
	let RevFlag = 0		
	if match(s:FileName, WorkJavaFileName) == 0
		let WorkFlag = 1
	elseif match(s:FileName, RevJavaFileName) == 0 
		let RevFlag = 1		
	endif

	" 新規ファイルの場合バッファしか存在せずファイル容量の確認ができないので保存して誤作動をさける。
	execute 'w'

	if getfsize(s:FilePath) == 0
		if WorkFlag == 1
			let ClassName = 'class ' . s:FileName[0:5] . ' {'
		elseif RevFlag == 1
			let ClassName = 'class ' . s:FileName[0:4] . ' {'
		endif
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
