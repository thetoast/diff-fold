"-------------------------------------------------------------------------------
" File: diff.vim
" Description: Folding script for Mercurial diffs
"
" Version: 0.1
"
" Author: Ryan Mechelke <rfmechelke AT gmail DOT com>
"
" Installation: Place in your ~/.vim/ftplugin folder
"
" Usage:
"   Pipe various Mercurial diff output to vim and see changesets, files, and
"   hunks folded nicely together.
"
"   Some examples:
"       hg in --patch | vim - -c "setlocal ft=diff"
"       hg diff | gvim -
"       hg diff -r 12 -r 13 | vim -
"
" Issues:
"   * Doesn't work with 'hg export' yet
"   * Hasn't really been tested with much beyond above use cases
"
"-------------------------------------------------------------------------------

" get number of lines
exec "normal G"
let last_line=line('.')
exec "normal gg"

" fold all hunks
try
    g/^@@/.,/\(\nchangeset\|^diff\|^@@\)/-1 fold
catch /E16/
endtry
exec "normal G"
call search('^@@', 'b')
exec ".," . last_line . "fold"

" fold file diffs
try
    g/^diff/.,/\(\nchangeset\|^diff\)/-1 fold
catch /E16/
endtry
exec "normal G"
call search('^diff', 'b')
exec ".," . last_line . "fold"

" fold changesets (if any)
if search('^changeset', '')
    try
        g/^changeset/.,/\nchangeset/-1 fold
    catch /E16/
    endtry
    exec "normal G"
    call search('^changeset', 'b')
    exec ".," . last_line . "fold"
endif

noh

" make the foldtext more friendly
function! MyDiffFoldText()
    let foldtext = "+" . v:folddashes . " "
    let line = getline(v:foldstart)

    if line =~ "^changeset.*"
        let foldtext .= substitute(line, "\:   ", " ", "")
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
set foldtext=MyDiffFoldText()
