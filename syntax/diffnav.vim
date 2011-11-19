syn match DiffNavTitle "--== Diff Navigator ==--"
syn match DiffNavTreePart "^-" nextgroup=DiffNavCsetLabel
syn match DiffNavTreePart "^ |- " nextgroup=DiffNavFilename
syn keyword DiffNavCsetLabel changeset nextgroup=DiffNavCset
syn match DiffNavCset ".*" contained
syn match DiffNavFilename ".*" contained
syn match Comment '^".*'

highlight DiffNavTitle guifg=lightblue gui=bold
highlight DiffNavTreePart guifg=darkgrey gui=bold
highlight DiffNavCsetLabel guifg=lightblue
highlight DiffNavCset guifg=cyan
highlight DiffNavFilename guifg=lightcyan
highlight DiffNavSelected guibg=darkgrey gui=bold
