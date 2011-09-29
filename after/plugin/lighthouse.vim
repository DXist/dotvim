" Lighthouse plugin is going to help to work with several projects in the same
" time
" Author: Rinat Shigapov <rinatshigapov@gmail.com>
"
if exists('g:loaded_lighthouse')
  finish
endif
let g:loaded_lighthouse = 1

if !exists("g:projects")
	let g:projects = []
endif

function! lighthouse#statusline()
	if empty(&buftype)
		call s:InitProject()
		if !empty(b:current_project)
			return 'Project: ' . b:current_project
		endif
	endif
	return ''
endfunction

function! lighthouse#commandt_filesearch(...)
	if exists("a:1")
		let l:path = s:ProjectPath(a:1)
	else
		let l:path = s:ProjectPath()
	endif
	exec ":CommandT " . l:path
endfunction

function! lighthouse#ack_grep(...)
	if exists("a:1")
		let l:path = s:ProjectPath(a:1)
	else
		let l:path = s:ProjectPath()
	endif
	let l:pattern = input("Ack: ")
	if !empty(l:pattern)
		exec ":Ack! " . l:pattern . " " . l:path
	else
		echo
	endif
endfunction

function! lighthouse#getdjangoapp()
	return expand('%:p:h:t')
endfunction

function! lighthouse#closeproject(name)
  let l:NBuffers = bufnr('$')     " Get the number of the last buffer.
  let l:i = 0                     " Set the buffer index to zero.

  while(l:i <= l:NBuffers)
	let l:i = l:i + 1
	let l:fileName = fnamemodify(bufname(l:i), ':p')
	if s:ProjectNameOf(l:fileName) == a:name && filereadable(l:fileName)
	  silent! exec 'bd '.l:i
	endif
  endwhile
endfunction

function! s:Completion(ArgLead, CmdLine, CursorPos)
	let l:projects = []
	for prj in g:projects
		if prj[0] =~ a:ArgLead
			call add(l:projects, prj[0])
		endif
	endfor
	return sort(l:projects)
endfunction

function! s:SetCurrentProject(project)
	let b:project_type = ''
	let b:current_project = a:project
endfunction

function! s:InitProject()
	let name = s:ProjectNameOf(expand('%:p:h'))

	if name != ''
		call s:SwitchToProject(name)
	else
		call s:SetCurrentProject('')
	endif
endfunction

function! s:SwitchToProject(name)
	let l:project_path = s:ProjectPath(a:name)
	if !empty(l:project_path)
		call s:SetCurrentProject(a:name)
		call s:LoadProjectConfig(l:project_path)
		if exists("b:cd_subdir")
			let l:cd_to = fnamemodify(l:project_path, ':p') . b:cd_subdir
		else
			let l:cd_to = l:project_path
		endif
		call s:SwitchPath(l:cd_to)
		if b:project_type == 'django'
			call s:SetDjangoApp()
		endif
	endif
endfunction

function! s:SwitchPath(path)
	execute 'cd ' . a:path
endfunction

function! s:LoadProjectConfig(project_path)
	let l:rcfile = fnamemodify(a:project_path, ':p') . '.vimrc'
	if filereadable(l:rcfile)
		exec "source " . l:rcfile
	endif
endfunction

function! s:ProjectNameOf(name)
	if strlen(a:name) == 0
		return s:ProjectNameOf(getcwd())
	endif

	for project in g:projects
		if a:name =~ project[1]
			return project[0]
		endif
	endfor

	return ''
endfunction

function! s:ProjectPath(...)
	if exists("a:1")
		let l:project_name = a:1
	elseif exists("b:current_project")
		let l:project_name = b:current_project
	else
		return ''
	endif
	for project in g:projects
		if l:project_name == project[0] && isdirectory(project[1])
			return project[1]
		endif
	endfor

	return ''
endfunction

command! -nargs=? -complete=customlist,s:Completion LightHouseSearch :call lighthouse#commandt_filesearch('<args>')
command! -nargs=? -complete=customlist,s:Completion LightHouseGrep :call lighthouse#ack_grep('<args>')
command! -nargs=? -complete=customlist,s:Completion LightHouseClose :call lighthouse#closeproject('<args>')


if !hasmapto(':LightHouseSearch<SPACE>')
  silent! nmap <unique> <Leader>ls :LightHouseSearch<SPACE>
endif

if !hasmapto(':LightHouseGrep<SPACE>')
  silent! nmap <unique> <Leader>lg :LightHouseGrep<SPACE>
endif

if !hasmapto(':LightHouseClose<SPACE>')
  silent! nmap <unique> <Leader>lc :LightHouseClose<SPACE>
endif

