"-------------------------------------------------------------------------------
" File: ftplugin/diff_fold.vim
" Description: Folding script for Mercurial diffs
"
" Version: 0.3.1
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
"       hg in --patch | vim -
"       hg diff | vim -
"       hg diff -r 12 -r 13 | vim -
"       hg export -r 12: | vim -
"       hg log --patch src\somefile.cpp | vim -
"
" changelog:
"   0.3.1 - (2011/1/11):
"       * fixed a bug with folding the 'hg export' style changesets
"       * made the global commands silent
"       * added better foldtext for 'hg export' style changesets
"
"   0.3 - (2011/1/6):
"       * added an ftdetect script so that mercurial output is automatically
"         detected.  "setlocal ft=diff" is no longer needed.
"       * added support for folding changsets which are output from the export
"         command.
"       * handling some additional errors which pop up when script is run
"
"   0.2 - (2010/10/1):
"       * changed all "exec normal" calls to "normal!"
"       * checking for existence of final hunks/diffs/changesets to avoid
"         double-folding
"       * foldtext now being set with "setlocal"
"
"   0.1 - (2010/9/30):
"       * Initial upload to vimscripts and bitbucket
"
" Thanks:
"   Ingo for the 0.2 patch!
"
"-------------------------------------------------------------------------------

if exists("b:did_ftplugin")
    finish
endif
let b:did_ftplugin = 1

" get number of lines
normal! G
let last_line=line('.')
normal! gg

" fold all hunks
try
    silent g/^@@/.,/\(^# HG changeset\|\nchangeset\|^diff\|^@@\)/-1 fold
catch /E16/
endtry
normal! G
if search('^@@', 'b')
    exec ".," . last_line . "fold"
endif

" fold file diffs
try
    silent g/^diff/.,/\(^# HG changeset\|\nchangeset\|^diff\)/-1 fold
catch /E16/
endtry
normal! G
if search('^diff', 'b')
    exec ".," . last_line . "fold"
endif

" fold changesets (if any)
if exists('b:diff_style') && (b:diff_style == "hg")
    try
        silent g/^\(changeset\|# HG changeset\)/.,/\(\nchangeset\|^# HG changeset\)/-1 fold
    catch /E16/
    catch /E486/
    endtry
    normal! G
    if search('^\(changeset\|^# HG changeset\)', 'b')
        exec ".," . last_line . "fold"
    endif
endif

noh

" make the foldtext more friendly
function! MyDiffFoldText()
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
setlocal foldtext=MyDiffFoldText()
