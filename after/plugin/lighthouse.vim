" inspired by https://github.com/vinhtiensinh/personal_vim/blob/master/plugin/lighthouse.vim
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
		let l:path = s:ProjectSearchPathOf(a:1)
		if !empty(l:path)
			exec ":CommandT " . l:path
		else
			echo "Project " . a:1 . " not found"
		endif
		return
	endif
	if exists("b:search_path")
		exec ":CommandT " . b:search_path
	else
		:CommandT
	endif
endfunction

function! lighthouse#ack_grep(...)
	if exists("b:search_path")
		let l:path = b:search_path
	else
		let l:path = ""
	endif

	if exists("a:1")
		let l:path = s:ProjectSearchPathOf(a:1)
		if empty(l:path)
			echo "Project " . a:1 . " not found"
			return
		endif
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
	let project_path = s:ProjectPathOf(a:name)
	if !empty(project_path)
		call s:SetCurrentProject(a:name)
		call s:SwitchPath(project_path)
		call s:LoadProjectConfig()
		if b:project_type == 'django'
			call s:SetDjangoApp()
		endif
	endif
endfunction

function! s:SwitchPath(path)
	execute 'cd ' . a:path
endfunction

function! s:LoadProjectConfig(...)
	let l:project_path = ''
	if exists("a:1")
		let l:project_path = fnamemodify(a:1, ':p')
	endif

	if filereadable(l:project_path . '.vimrc')
		exec "source " . l:project_path . ".vimrc"
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

function! s:ProjectPathOf(name)
	for project in g:projects
		if a:name == project[0] && isdirectory(project[1])
			return project[1]
		endif
	endfor

	return ''
endfunction

function! s:ProjectSearchPathOf(name)
	let l:project_path = s:ProjectPathOf(a:name)
	let b:search_path = ''
	call s:LoadProjectConfig(l:project_path)
	if exists("b:search_path")
		if fnamemodify(b:search_path, ':.') != b:search_path
			"absolute b:search_path
			return b:search_path
		endif
	endif

	if !empty(l:project_path)
		return fnamemodify(l:project_path, ':p') . b:search_path
	endif

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

