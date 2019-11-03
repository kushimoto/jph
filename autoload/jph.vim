" 変数リスト
" s:CurrentFName -> Current File Name ... neovimで開いているファイルの名前
" s:CurrentFPath -> Current File Path ... neovimで開いているファイルのフルパス

function! jph#main()

	" 現在編集中のファイルの名前を変数に代入
	let s:CurrentFName = expand("%")

	" 現在編集中のファイルのフルパスを変数に代入（ファイル名を含む）
	let s:CurrentFPath = expand("%:p")

	" WorkYY.java RevYY.java を区別するためのフラグ変数
	let WorkFlag = 0
	let RevFlag = 0

	" 課題ファイルを確認するための簡易的な正規表現の代入
	let WorkJavaFName = 'work..\.java'
	let RevJavaFName = 'rev..\.java'

	" カレントファイルが WorkXX.java なら
	if match(s:CurrentFName, WorkJavaFName) == 0
		" WorkFlag に 1 をたてる
		let WorkFlag = 1
	" カレントファイルが RevXX.java なら
	elseif match(s:CurrentFName, RevJavaFName) == 0  
		" RevFlag に 1 をたてる
		let RevFlag = 1		
	endif

	" junit/ src/ を準備し、各種ファイルのコピーを行う。成功すれば中の処理に入る
	if jph#init() == 0
		" 課題ファイルが編集中であることが確認できれば中の処理を実行する
		if WorkFlag == 1 || RevFlag == 1
			" javac コマンドを準備
			let JavaCompile = 'javac ' . s:CurrentFName
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
				" workYY.java or revYY.java を srcディレクトリへコピーするコマンドを準備
				let CopyJavaFileToSRC = 'cp ' . s:CurrentFName . ' src/'
				" workYY.java or revYY.java の デバッグに必要なファイルを失敬するコマンドの準備(len は 0から数えていることに注意)
				let GetJunitSh = 'cp /home/teachers/skeleton/INjava/' . s:CurrentFName[0:len(s:CurrentFName) - 6] . 'test.sh' . ' ./'
				" システムコマンドをそれぞれ実行
				call system(CopyJavaFileToSRC)
				call system(GetJunitSh)
				" デバッグ用のスクリプトファイルを実行するコマンドを準備
				let JunitSh = 'sh ' . s:CurrentFName[0:len(s:CurrentFName) - 6] . 'test.sh'
				" システムコマンドを実行、デバッグ結果を変数に格納する
				let OutPut = system(JunitSh)
				" 出力が70文字以下なら問題はないだろうという判断を下す
				if len(OutPut) <= 70
					" 検索対象のファイル名を変数に代入（検索対象のファイルはデバッグの結果が書かれたファイル）
					let FindObject = s:CurrentFName[0:len(s:CurrentFName) - 6] . 'test.txt'
					if WorkFlag == 1
						" 検索対象のファイルが置かれているはずのパスを変数に代入
						let FindPath = s:CurrentFPath[0:len(s:CurrentFPath) - 12] 
					elseif RevFlag == 1
						" 検索対象のファイルが置かれているはずのパスを変数に代入
						let FindPath = s:CurrentFPath[0:len(s:CurrentFPath) - 11] 
					endif
					" 検索対象のファイルを検索
					if findfile(FindObject, FindPath) == FindObject
						echomsg '[ Success ] Debug is no problem.'
						" デバッグの完了したソースファイルを src/ にコピーするためのコマンドを準備
						let CopyJavaFileToCurrentDir = 'cp src/' . s:CurrentFName . ' ' . s:CurrentFName
						call system(CopyJavaFileToCurrentDir)
						execute 'e!'
						execute 'normal gg'
						execute 'normal dd'
						execute 'w'
						" デバッグ完了後のファイルをコンパイルするコマンドを準備する
						let JavaCompile = 'javac ' . s:CurrentFName
						call feedkeys("\<C-w>")
						call feedkeys("j")
						call feedkeys("i" . "\<CR>")
						call feedkeys(JavaCompile . "\<CR>")
						" デバッグに用いたスクリプトファイルを削除
						if delete(s:CurrentFName[0:len(s:CurrentFName) - 6] . 'test.sh') == 0
							echomsg '[ Success ] Deleting script file for debug is done.'
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
					echomsg '[ Error ] Debug failed.'
					echohl None
				endif
			endif
		endif
	endif
endfunction

function! jph#init()

	"開いているファイル名を取得
	let s:CurrentFName = expand("%")
	"フルパス取得(ファイル名含む)
	let s:CurrentFPath = expand("%:p")
	" 復習問題と課題を区別するためのフラグ
	let WorkFlag = 0
	let RevFlag = 0
	" カレントバッファが workYY.java or revYY.java かどうか確認
	let WorkJavaFName = 'work..\.java'
	let RevJavaFName = 'rev..\.java'
	if match(s:CurrentFName, WorkJavaFName) == 0
		let WorkFlag = 1
	elseif match(s:CurrentFName, RevJavaFName) == 0 
		let RevFlag = 1		
	endif
	
	if WorkFlag == 1
		let WorkingDirPath = s:CurrentFPath[0:len(s:CurrentFPath) - 13]
	elseif RevFlag == 1
		let WorkingDirPath = s:CurrentFPath[0:len(s:CurrentFPath) - 12]
	endif

	let Java19DirPath = $HOME . '/kadai/java19/lec..'

	if match(WorkingDirPath, Java19DirPath) == 0
		if isdirectory('src') == 0
			call mkdir('src')
		endif
		if isdirectory('junit') == 0
			call mkdir('junit')
		endif
		let GetDebugOnlyJavaFile = 'cp /home/teachers/skeleton/INjava/' . s:CurrentFName[0:len(s:CurrentFName) - 6] . 'test.java' . ' junit/'
		call system(GetDebugOnlyJavaFile)
		if v:shell_error != 0
			echohl ErrorMsg
			echo "[ Error ] Get '" . s:CurrentFName[0:len(s:CurrentFName) - 6] . "test.java' failed."
			echohl None
		endif

	else
		echohl ErrorMsg
		echomsg "[ Error ] Current directory must be '~/kadai/java19/lecXX'."
		echohl None
		return 1
	endif
endfunction

function! jph#initialCodeInsert()

	"開いているファイル名を取得
	let s:CurrentFName = expand("%")
	"フルパス取得(ファイル名含む)
	let s:CurrentFPath = expand("%:p")

	" 新規ファイルの場合バッファしか存在せずファイル容量の確認ができないので保存して誤作動をさける。
	execute 'w'

	if getfsize(s:CurrentFPath) == 0
		let ClassName = 'class ' . s:CurrentFName[0:len(s:CurrentFName) - 6] . ' {'
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
