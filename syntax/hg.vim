syn include @diff syntax/diff.vim

setlocal foldmethod=syntax

syn region hgChangesetFold start=/^changeset:.*$/ skip=/^\ndiff/ end=/^$/  keepend transparent fold contains=hgChangesetDetails,@diff

syn match hgChangesetDetails "^changeset:.*" contained
syn match hgChangesetDetails "^user:.*" contained
syn match hgChangesetDetails "^date:.*" contained
syn match hgChangesetDetails "^summary:.*" contained
syn match hgChangesetDetails "^tag:.*" contained
syn match hgChangesetDetails "^parent:.*" contained
syn match hgChangesetDetails "^branch:.*" contained
syn match hgChangesetDetails "^bookmark:.*" contained

highlight link hgChangesetDetails Comment

function DiffFoldText()
    let foldtext = "+" . v:folddashes . " "
    let line = getline(v:foldstart)

    if line =~ "^changeset.*"
        let foldtext .= substitute(line, "\:   ", " ", "")
    elseif line =~ "^# HG changeset.*"
        let foldtext .= "changeset "
        let node = getline(v:foldstart + 3)
        let foldtext .= substitute(node, "\# Node ID ", "", "")
    elseif line =~ "^diff.*"
        if (line =~ "diff -r")
            let matches = matchlist(line, 'diff -r [a-z0-9]\+ \(.*\)$')
            let foldtext .= matches[1]
        else
            let matches = matchlist(line, 'a/\(.*\) b/')
            let foldtext .= matches[1]
        endif
    else
        let foldtext .= line
    endif

    let foldtext .= " (" . (v:foldend - v:foldstart) . " lines)\t"

    return foldtext
endfunction
setlocal foldtext=DiffFoldText()
