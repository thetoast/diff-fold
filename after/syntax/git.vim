syn region gitCommitFold start=/^commit/ end=/^\ncommit/me=s-1 transparent fold keepend
syn clear diffFileFold

function DiffFoldText()
    let foldtext = "+" . v:folddashes . " "
    let line = getline(v:foldstart)

    if line =~ "^diff.*"
        let matches = matchlist(line, 'a/\(.*\) b/')
        let foldtext .= matches[1]
    else
        let foldtext .= line
    endif

    let foldtext .= " (" . (v:foldend - v:foldstart) . " lines)\t"

    return foldtext
endfunction
setlocal foldtext=DiffFoldText()
