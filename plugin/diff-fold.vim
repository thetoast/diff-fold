"-------------------------------------------------------------------------------
" File: ftplugin/diff_fold.vim
" Description: Folding script for Mercurial diffs
"
" Version: 0.4
"
" Author: Ryan Mechelke <rfmechelke AT gmail DOT com>
"
" Installation: Place in your ~/.vim/ftplugin folder
"
" Usage:
"   Pipe various Mercurial diff output to vim and see changesets, files, and
"   hunks folded nicely together.  In addition to providing folding of diff
"   text, diff_fold also provides a navigation pane which you can use to more
"   easily navigate large diffs.
"
"   Some examples:
"       hg in --patch | vim -
"       hg diff | vim -
"       hg diff -r 12 -r 13 | vim -
"       hg export -r 12: | vim -
"       hg log --patch src\somefile.cpp | vim -
"
"   Navigation pane usage:
"       
"       The keybinding <Leader>nav will bring up the navigation pane.  You can
"       use the 'Enter' or 'v' keys to either go to, or view whole changsets
"       or files in the Diff View
"
"       If you don't like the default mapping, you can map a new one as
"       follows:
"           map {newmap} <Plug>DiffFoldNav
"
" changelog:
"   0.4 - (2011/2/10):
"       * added a navigation pane for easier navigating of large diffs
"       * added syntax highlighting for changeset details
"
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

" Fold Text Functions {{{
function! DiffNavFoldText()
    let line = getline(v:foldstart)
    let line = substitute(line, '^-', '+', '')
    let foldtext = line
    let foldtext .= " (". (v:foldend - v:foldstart) . " files) "
    let textlen = len(foldtext)
    let winwidth = winwidth(0)
    return foldtext . repeat(' ', winwidth - textlen)
endfunction
" End Fold Text Functions }}}

" Navigation Pane Functions {{{
function! s:RefreshNavPane()
    normal! ggdG
    normal! I --== Diff Navigator ==--
    normal! o
    normal! o" Press '?' for help
    normal! o

    call diff_fold#{b:diff_style}#nav_refresh()
endfunction

function! s:CreateNavPane()
    let bufnum = bufnr('%')
    let difftype = &filetype
    echo difftype

    leftabove vert new
    set buftype=nofile
    file [Diff Nav]
    set nonu

    let navbuf = bufnr('%')

    let b:diff_buffer=bufnum
    let b:diff_style=difftype
    call setbufvar(bufnum, 'diff_nav_buffer', navbuf)

    let b:help_open=0

    setlocal foldmethod=manual
    setlocal foldtext=DiffNavFoldText()

    setfiletype diffnav

    vert resize 50

    nno <buffer> o za
    nno <buffer> O maggvGzo'a
    nno <buffer> C maggVGzc'a
    nno <buffer> v :call <SID>GoToDiffItem(0)<CR>
    nno <buffer> <CR> :call <SID>GoToDiffItem(1)<CR>
    nno <buffer> <2-LeftMouse> :call <SID>GoToDiffItem(1)<CR>
    nno <buffer> ? :call <SID>ShowHelp()<CR>

    call s:RefreshNavPane()
endfunction

function! s:ShowHelp()
    normal! ma

    if !b:help_open
        normal! 3Gdd
        normal! O"
        normal! o" Key Mappings:
        normal! o"     o            -- Open/Close fold
        normal! o"     O            -- Open all folds
        normal! o"     C            -- Close all folds
        normal! o"     v            -- View item in Diff View
        normal! o"     Enter        -- Go to item in Diff View
        normal! o"     Double Click -- Go to item in Diff View
        normal! o"     ?            -- Open/Close help
        normal! o"
        let b:help_open=1
    else
        normal! 3Gd9j
        normal! O" Press '?' for help
        let b:help_open=0
    endif

    normal! 'a
endfunction

function! s:GoToDiffItem(focus_item)
    " highlight selected item
    match none
    exec 'match DiffNavSelected /\%'.line('.').'l/'

    " get line content
    let line = line('.')

    "" if fold in nav, open
    normal! zo

    " select the line in the diff buffer
    call diff_fold#{b:diff_style}#nav_select(line)

    " switch to diff window
    wincmd l

    " close folds
    setlocal foldlevel=0

    " open all folds at diffline
    normal! zxj[zV]zzO

    " go back to nav view if we need to
    if !a:focus_item
        wincmd h
    endif
endfunction

function! s:DisplayNavPane()
    if !exists('b:diff_nav_buffer')
        call s:CreateNavPane()
    else
        wincmd h
        call s:RefreshNavPane()
    endif
endfunction
" End Navigation Pane Functions }}}

function! s:AddBindings()
    if !hasmapto('<Plug>DisplayNavPane')
        map <unique> <leader>nav <Plug>DiffFoldNav
    endif
    noremap <unique> <Plug>DiffFoldNav :call <SID>DisplayNavPane()<CR>
endfunction

function! s:CheckDiffFold()
    call <SID>AddBindings()
endfunction

au FileType diff,hg,git call <SID>CheckDiffFold()
