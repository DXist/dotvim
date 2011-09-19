" based on https://github.com/vinhtiensinh/personal_vim/blob/master/plugin/lighthouse.vim
if !exists("g:projects")
  let g:projects = []
endif

"autocmd VimEnter * call SwitchToProject()

"autocmd BufEnter,BufWinEnter,WinEnter * call RemoveMiniBufDuplicateWindow() | call CloseAllIfOnlyBufExplorerLeft()
"autocmd BufEnter * syntax on
autocmd BufEnter * call SwitchToProject()

function! CloseAllIfOnlyBufExplorerLeft()
  if winnr('$') == 1 && (IsBufExplorerOpen() || IsNERDTreeWindowOpen())
    exec "qa"
  endif
endfunction

function! GetCurrentProject()
  if !exists('g:current_project')
    let g:current_project = getcwd()
  endif
  return g:current_project
endfunction

function! SetCurrentProject(project)
  let g:current_project = a:project
endfunction

function! SwitchToProject()
  let name = ProjectNameOf(expand('%:p:h'))

  if name != ''
    call SwitchToProjectCmd(name)
  else
	let current_dir = fnamemodify(getcwd(), ':p')
    let project_name = fnamemodify(current_dir, ':p:~')
    call add(g:projects, [project_name, current_dir])
  endif
endfunction

function! SwitchToProjectCmd(name)

  let project_path = ProjectPathOf(a:name)
  if project_path != ''
    call SetCurrentProject(a:name)
    call SwitchPath(project_path)
  endif
endfunction

function! SwitchPath(path)
  execute 'cd ' . a:path
  if IsNERDTreeWindowOpen()
    exec ":NERDTreeToggle"
    exec ":NERDTree " . getcwd()
  else
    let g:NERDTree_need_update = 1
  endif
endfunction

function! SwitchToPath()

  let path = input("Path: ", '', 'file')
  if path == ''
    return
  endif
  call SwitchToProjectCmd(ProjectNameOf(fnamemodify(path, ':p')))

endfunction

function! ProjectNameOf(name)
  if strlen(a:name) == 0
    return ProjectNameOf(getcwd())
  endif

  for project in g:projects
    if a:name =~ project[1]
      return project[0]
    endif
  endfor

  return ''
endfunction

function! ProjectPathOf(name)
  for project in g:projects
    if a:name == project[0] && isdirectory(project[1])
      return project[1]
    endif
  endfor

  return a:name
endfunction

function! IsInProject(name)
  if ProjectNameOf(fnamemodify(a:name, ':p')) !~ '\~' && ProjectNameOf(fnamemodify(a:name, ':p')) !~ '\/'
    return 1
  endif
  return 0
endfunction

function! FolderNameOf(name)
  let folder = fnamemodify(fnamemodify(a:name, ":h"), ":t")
  if folder !~ '\.'
    let folder = '..'.folder
  endif

  return folder
endfunction

function! PathOf(name)
  let project_name = ProjectNameOf(a:name)
  if project_name != ''
    return project_name
  else
    return substitute(fnamemodify(a:name, ":h"), $HOME, "~", "")
  endif
endfunction

function! GotoBuffer(index)

  let winNum = FindWindow('-MiniBufExplorer-')
  exec l:winNum.' wincmd w'

  if getline(a:index) =~ '\[.*\]'
    let project_name = getline(a:index)
    let project_name = substitute(project_name, '^\s*x\[', '', '')
    let project_name = substitute(project_name, '\].*', '', '')

    call SwitchToProjectCmd(project_name)
    exec 'wincmd p'
  else
    call feedkeys(a:index . "G")
    call feedkeys("\<CR>")
  endif
  call RemoveMiniBufDuplicateWindow()
endfunction

function! PreviousBuffer()
  if IsBufExplorerOpen()
    let buf_file = expand('%:t')

    let winNum = FindWindow('-MiniBufExplorer-')
    exec l:winNum.' wincmd w'
    let last_line = getpos('$')[1]

    let current = 1
    while (current <= last_line)
      if getline(current) =~ buf_file.'\*'
        break
      else
        let current = current + 1
      endif
    endwhile

    while(1)
      if current == 1
        let current = last_line
      else
        let current = current - 1
      endif

      if getline(current) !~ '\[.*\]'
        call GotoBuffer(current)
        return
      endif
    endwhile
  endif

  if IsNERDTreeWindowOpen()
    let winNum = FindWindow(t:NERDTreeBufName)
    exec l:winNum.' wincmd w'
    call feedkeys("k\<CR>")
  endif
endfunction

function! NextBuffer()
  if IsBufExplorerOpen()
    let buf_file = expand('%:t')

    let winNum = FindWindow('-MiniBufExplorer-')
    exec l:winNum.' wincmd w'

    let current = 1
    let last_line = getpos('$')[1]

    while(current <= last_line)
      if getline(current) =~ buf_file.'\*'
        break
      else
        let current = current + 1
      endif
    endwhile

    while(1)
      if current == last_line
        let current = 1
      else
        let current = current + 1
      endif

      if getline(current) !~ '\[.*\]'
        call GotoBuffer(current)
        return
      endif
    endwhile
  endif

  if IsNERDTreeWindowOpen()
    let winNum = FindWindow(t:NERDTreeBufName)
    exec l:winNum.' wincmd w'
    call feedkeys("j\<CR>")
  endif
endfunction

function! IsBufExplorerOpen()
  return FindWindow('-MiniBufExplorer-') != -1
endfunction

function! IsNERDTreeWindowOpen()
    if exists("t:NERDTreeBufName")
        return FindWindow(t:NERDTreeBufName) != -1
    else
        return 0
    endif
endfunction

function! FindWindow(bufName)
    " Try to find an existing window that contains
    " our buffer.
    let bufNum = bufnr(a:bufName)
    if bufNum != -1
        let winNum = bufwinnr(l:bufNum)
    else
        let winNum = -1
    endif

    return winNum
endfunction

let inumber = 1

while inumber < 100
  execute "map  " . inumber . "<Space> " . ":call GotoBuffer(" . inumber . ")<CR>"
  execute "map  " . inumber . "<S-Space> " . ":split<CR>".inumber."<Space>"
  execute "map  " . inumber . "<S-CR> " . ":vsplit<CR>".inumber."<Space>"
  execute "map  " . inumber . "<Tab> " . ":tabnew<CR>".inumber."<Space>"

  execute "map  " . inumber . "W " . ":call CloseProjectWithNumber(".inumber.")<CR>"

  let inumber = inumber + 1
endwhile

function! CloseProjectWithNumber(linenumber)
  let projectline = getbufline(bufnr('-MiniBufExplorer-'), a:linenumber)[0]
  let project = substitute(projectline, '[\[\]]', '', 'g')

  call CloseProject(project)
endfunction

function! RemoveMiniBufDuplicateWindow()

  if IsBufExplorerOpen() && IsNERDTreeWindowOpen()
    exec ":CMiniBufExplorer"
    return
  endif

  let l:NBuffers = bufnr('$')     " Get the number of the last buffer.
  let l:i = 0                     " Set the buffer index to zero.
  let l:miniBufOpened = 0
  while(l:i <= l:NBuffers)
    let l:i = l:i + 1
    let l:BufName = bufname(l:i)
    if l:BufName == '-MiniBufExplorer-' && bufwinnr(l:i) != -1
      if l:miniBufOpened
        execute 'bw '.l:i
      else
        let l:miniBufOpened = 1
      end
    endif
  endwhile
endfunction

function! ToggleBetweenNERDTreeAndBufExplorer()

  if IsBufExplorerOpen()
    exec ":CMiniBufExplorer"

    if !IsNERDTreeWindowOpen()
      if exists("g:NERDTree_need_update") && g:NERDTree_need_update
        exec ":NERDTree " . getcwd()
        let g:NERDTree_need_update = 0
      else
        exec ":NERDTreeToggle"
      end
    endif
  else
    if IsNERDTreeWindowOpen()
      exec ":NERDTreeToggle"
      exec ":MiniBufExplorer"
    else
      exec ":NERDTreeToggle"
    endif
  endif

  exec "wincmd p"
endfunction

function! CloseProject(name)
  let l:NBuffers = bufnr('$')     " Get the number of the last buffer.
  let l:i = 0                     " Set the buffer index to zero.

  while(l:i <= l:NBuffers)
    let l:i = l:i + 1
    let l:fileName = fnamemodify(bufname(l:i), ':p')
    if ProjectNameOf(l:fileName) == a:name && filereadable(l:fileName)
      silent! exec 'bd '.l:i
    endif
  endwhile
endfunction

function! ToggleFoldProject(name)
  if ProjectClosed(a:name)
    call UnFoldProject(a:name)
  else
    call FoldProject(a:name)
  endif
endfunction

function! UnFoldProject(name)
  let tabClosed = GetFoldedProjects()
  tabClosed[a:name] = 0
endfunction

function! FoldProject(name)
  let tabClosed = GetFoldedProjects()
  let tabClosed[a:name] = 1
endfunction

function! GetFoldedProjects()
  if !exists('t:MinibufClosedProjects')
    let t:MinibufFoldedProjects = {}
  endif
  return t:MinibufFoldedProjects
endfunction

function! CloseNERDTreeAndBufExplorer()
    if IsNERDTreeWindowOpen()
      exec ":NERDTreeToggle"
    endif

    if IsBufExplorerOpen()
      exec ":TMiniBufExplorer"
    endif
    return
endfunction
