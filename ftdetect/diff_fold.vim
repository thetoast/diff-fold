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

au BufRead,StdinReadPost * call <SID>diff_filetype_check()

if exists("s:run_once")
    finish
endif
let s:run_once = 1

function s:diff_hg_filetype_check(start)
    if getline(a:start) =~ '^comparing with.*'
        if getline(a:start + 1) =~ '^searching for changes$'
            if getline(a:start + 2) =~ '^changeset.*'
                setfiletype hg
                return 1
            endif
        endif
    endif

    if getline(a:start) =~ '^changeset.*'
        setfiletype hg
        return 1
    endif

    if getline(a:start) =~ '# HG changeset.*'
        setfiletype hg
        return 1
    endif

endfunction

function s:diff_filetype_check()
    " check one more time to see if filetype has been done
    if did_filetype()
        return
    endif

    " sometimes the first line is blank
    let start = 1
    if getline(start) =~ '^$'
        let start = start + 1
    endif

    " check for mercurial output
    if s:diff_hg_filetype_check(start)
        return
    endif

    " check for darcs output
    "if s:diff_darcs_filetype_check(start)
    "    return
    "endif

    " this last one checks for standard unified diff
    if getline(a:start) =~ '^diff.*'
        setfiletype diff
    endif
endfunction
