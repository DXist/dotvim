" based on https://github.com/vinhtiensinh/personal_vim/blob/master/plugin/lighthouse.vim
if !exists("g:projects")
  let g:projects = []
endif

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
  "if IsNERDTreeWindowOpen()
  "  exec ":NERDTreeToggle"
  "  exec ":NERDTree " . getcwd()
  "else
  "  let g:NERDTree_need_update = 1
  "endif
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


