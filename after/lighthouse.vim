" Lightning fast switch between projects
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
		if !exists("b:current_project")
			call s:InitProject()
		endif
		if exists("b:current_project") && !empty(b:current_project)
			return 'Project: ' . b:current_project
		endif
	endif
	return ''
endfunction


function! lighthouse#filesearch(...)
	if exists("a:1") && a:1 != ''
		call s:SetCurrentProject(a:1)
		let l:path = s:ProjectPath(a:1)
		call s:SwitchPath(l:path)
		exec ":" . "CtrlP"
	else
		echo 'Filesearch is skipped'
	endif
endfunction

function! lighthouse#grep(...)
	if exists("a:1") && a:1 != ''
		call s:SetCurrentProject(a:1)
		let l:path = s:ProjectPath(a:1)
		call s:SwitchPath(l:path)
	exec ":" . "Unite grep:."
	else
		echo 'Grep is skipped'
	endif
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
	return l:projects
endfunction

function! s:SetCurrentProject(project)
	if !empty(a:project)
		let b:current_project = a:project
	else
		if exists("b:current_project")
			unlet b:current_project
		endif
	endif
endfunction

function! s:InitProject()
	let l:name = s:ProjectNameOf(expand('%:p'))

	if l:name != ''
		call s:SwitchToProject(l:name)
	else
		call s:SetCurrentProject('')
	endif
endfunction

function! s:SwitchToProject(name)
	let l:project_path = s:ProjectPath(a:name)
	if !empty(l:project_path)
		call s:SetCurrentProject(a:name)
		call s:LoadProjectConfig(l:project_path)
		if exists("b:cd_to")
			if b:cd_to[0] == '/' || b:cd_to[0] == '~'
				"absolute path
				let l:cd_to = b:cd_to
			else
				"relative path
				let l:cd_to = fnamemodify(l:project_path, ':p') . b:cd_to
			endif
		else
			let l:cd_to = l:project_path
		endif
		call s:SwitchPath(l:cd_to)
		let b:ctrlp_working_path_mode = 0
	endif
endfunction

function! s:SwitchPath(path)
	execute 'lcd ' . a:path
endfunction

function! s:LoadProjectConfig(project_path)
	let l:rcfile = fnamemodify(a:project_path, ':p') . '.vimrc'
	if filereadable(l:rcfile)
		exec "source " . l:rcfile
	endif
endfunction

function! s:ProjectNameOf(name)
	if strlen(a:name) == 0
		let l:name = expand('%:p')
	else
		let l:name = a:name
	endif

	for project in g:projects
		if l:name =~ project[1]
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


command! -nargs=? -complete=customlist,s:Completion LightHouseSearch :call lighthouse#filesearch('<args>')
command! -nargs=? -complete=customlist,s:Completion LightHouseGrep :call lighthouse#grep('<args>')
command! -nargs=? -complete=customlist,s:Completion LightHouseClose :call lighthouse#closeproject('<args>')
command! LightHouseArrange :call s:ArrangeByProjects()


" if !hasmapto(':LightHouseSearch<SPACE>')
" 	silent! nmap <unique> <Leader>ls :LightHouseSearch<SPACE>
" endif

" if !hasmapto(':LightHouseGrep<SPACE>')
" 	silent! nmap <unique> <Leader>lg :LightHouseGrep<SPACE>
" endif

" if !hasmapto(':LightHouseClose<SPACE>')
" 	silent! nmap <unique> <Leader>lc :LightHouseClose<SPACE>
" endif
