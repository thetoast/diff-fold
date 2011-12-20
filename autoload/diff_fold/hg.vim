function! diff_fold#hg#set_syntax()
    setlocal foldmethod=syntax
    syn region hgChangeset start=/^changeset:.*$/ skip=/^\ndiff/ end=/^$/  keepend transparent fold 

    syn match hgChangesetDetails "^changeset:.*" contained
    syn match hgChangesetDetails "^user:.*" contained
    syn match hgChangesetDetails "^date:.*" contained
    syn match hgChangesetDetails "^summary:.*" contained
    syn match hgChangesetDetails "^tag:.*" contained
    syn match hgChangesetDetails "^parent:.*" contained
    syn match hgChangesetDetails "^branch:.*" contained

    highlight link hgChangesetDetails Comment
endfunction

function! diff_fold#hg#nav_refresh()
    for line in getbufline(b:diff_buffer, 1, '$')
        if line =~ "^changeset:.*"
            let b:has_csets=1
            normal! o
            let cset = substitute(line, 'changeset:\s\+', 'changeset ', '')
            exec "normal! o- " . cset
        elseif line =~ "^diff.*"
            let filename = substitute(line, '^diff.*a/\(.*\) b/.*$', '\1', '')
            exec "normal! o |- " . filename
        endif
    endfor
    try
        silent g/^- changeset/.,/^$/-1 fold
    catch /E16/
    endtry
    normal! G
    call search('^- changeset', 'b')
    .,$ fold
    call search('^- changeset')
endfunction

function! diff_fold#hg#nav_select(line_num)
    let line = getline(a:line_num)

    " if we're finding a changeset
    if line =~ "^[-+] changeset .*"

        " highlight the selected line
        exec 'match DiffNavSelected /\%'.line('.').'l/'

        " extract the changeset name
        let cset = substitute(line, '^[-+] changeset \(.*\)$', '\1', '')

        " go find the changeset
        wincmd l
        call search(cset, '')
        wincmd h

    " if we're finding a filename within a changeset
    elseif line =~ "^ |- .*"

        " highlight the selected line
        exec 'match DiffNavSelected /\%'.line('.').'l/'

        " get the selected file
        let file = substitute(line, '^ |- \(.*\)$', '\1', '')

        " get the changeset name if we need
        if exists('b:has_csets')
            normal! ma
            while !exists('cset')
                normal! k
                let line = getline('.')
                if line =~ "^[-+] changeset .*"
                    let cset = substitute(line, '^[-+] changeset \(.*\)$', '\1', '')
                endif
            endwhile
            normal! 'a
        endif

        " go find the file
        wincmd l
        setlocal foldlevel=0

        " start by finding changeset if needed
        if exists('cset')
            normal gg
            call search(cset, '')
        endif

        " now find action file
        call search("^diff.*" . file, '')
        wincmd h

    endif

endfunction
