"-------------------------------------------------------------------------------
" File: ftdetect/diff_fold.vim
" Description: Filetype detection script for mercurial output
"
" Version: 0.3
"
" Author: Ryan Mechelke <rfmechelke AT gmail DOT com>
"
" Installation: Place in your ~/.vim/ftdetect folder
"
"-------------------------------------------------------------------------------

if did_filetype()
    finish
endif

au BufEnter * call <SID>diff_filetype_check()

if exists("s:run_once")
    finish
endif
let s:run_once = 1

function s:diff_filetype_check()

    " check one more time to see if filetype has been done
    if did_filetype()
        finish
    endif

    " detect for mercurial output
    if getline(1) =~ '^changeset.*'
        setfiletype diff
    endif
    if getline(1) =~ '# HG changeset.*'
        setfiletype diff
    endif
endfunction