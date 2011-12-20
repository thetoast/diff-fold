set foldmethod=syntax
syn region diffFileFold  start=/^diff/ end=/^diff/me=s-1  keepend transparent fold 
syn region diffHunkFold  start=/^@@/ end=/^@@/me=s-1  keepend transparent fold 
