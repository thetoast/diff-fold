
syn match HgChangesetDetails "^changeset:.*"
syn match HgChangesetDetails "^user:.*"
syn match HgChangesetDetails "^date:.*"
syn match HgChangesetDetails "^summary:.*"
syn match HgChangesetDetails "^tag:.*"
syn match HgChangesetDetails "^parent:.*"
syn match HgChangesetDetails "^branch:.*"

highlight link HgChangesetDetails Comment
