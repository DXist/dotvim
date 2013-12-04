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

if !exists("g:lighthouse_search_cmd")
	let g:lighthouse_search_cmd = "CtrlP"
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

function! lighthouse#tablabel(n)
        let label = ''
        let buflist = tabpagebuflist(a:n)

        " Имя файла и номер вкладки -->
		if !empty(gettabvar(a:n, "current_project"))
			let label = gettabvar(a:n, "current_project")
		else
			let label = substitute(bufname(buflist[tabpagewinnr(a:n) - 1]), '.*/', '', '')
		endif

		if label == ''
			let label = '[No Name]'
		endif

		let label .= ' ' . a:n
        " Имя файла и номер вкладки <--

        " Определяем, есть ли во вкладке хотя бы один
        " модифицированный буфер.
        " -->
		for i in range(len(buflist))
			if getbufvar(buflist[i], "&modified")
				let label = '[+] ' . label
				break
			endif
		endfor
        " <--

        return label
endfunction

function! lighthouse#filesearch(...)
	if exists("a:1")
		let l:path = s:ProjectPath(a:1)
		call s:SwitchToProjectTab(a:1)
	else
		let l:path = s:ProjectPath()
	endif
	exec ":" . g:lighthouse_search_cmd . " " . l:path
endfunction

function! lighthouse#ack_grep(...)
	if exists("a:1")
		let l:path = s:ProjectPath(a:1)
		call s:SwitchToProjectTab(a:1)
	else
		let l:path = s:ProjectPath()
	endif
	let l:pattern = input("Ack: ")
	if !empty(l:pattern)
		let l:cmd = ":Ack! " . l:pattern
		if empty(l:path)
			let l:cmd = l:cmd . " " . l:path
		endif
		exec l:cmd
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
	if !empty(a:project)
		let b:current_project = a:project
		if !exists("t:current_project")
			let t:current_project = a:project
		endif
	else
		if exists("b:current_project")
			unlet b:current_project
		endif
		if exists("t:current_project")
			unlet t:current_project
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

" get tab number by project name
function! s:ProjectTabNr(project)
	let l:ntabs = tabpagenr('$')
	for n in range(1, l:ntabs)
		if gettabvar(n, "current_project") == a:project
			return n
		endif
	endfor
	return 0
endfunction

function! s:SwitchToProjectTab(project)
	let l:n = s:ProjectTabNr(a:project)
	if l:n
		exec ":tabn " . l:n
	else
		if exists("t:current_project")
			:tabnew
			call s:SetCurrentProject(a:project)
		endif
	endif
endfunction

function! s:BufferToProjectTab()
	let l:current_project = getbufvar(bufname('%'), "current_project")
	if !empty(l:current_project)
		call s:SwitchToProjectTab(l:current_project)
	endif
endfunction

function! s:ArrangeByProjects()
	:bufdo call s:BufferToProjectTab()
endfunction

" Задаем собственные функции для назначения имен заголовкам табов -->
function lighthouse#tabline()
	let tabline = ''

	" Формируем tabline для каждой вкладки -->
		for i in range(tabpagenr('$'))
			" Подсвечиваем заголовок выбранной в данный момент вкладки.
			if i + 1 == tabpagenr()
				let tabline .= '%#TabLineSel#'
			else
				let tabline .= '%#TabLine#'
			endif

			" Устанавливаем номер вкладки
			let tabline .= '%' . (i + 1) . 'T'

			" Получаем имя вкладки
			let tabline .= ' %{lighthouse#tablabel(' . (i + 1) . ')} |'
		endfor
	" Формируем tabline для каждой вкладки <--

	" Заполняем лишнее пространство
	let tabline .= '%#TabLineFill#%T'

	" Выровненная по правому краю кнопка закрытия вкладки
	if tabpagenr('$') > 1
		let tabline .= '%=%#TabLine#%999XX'
	endif

	return tabline
endfunction

function lighthouse#guitablabel()
	return '%{lighthouse#tablabel(' . tabpagenr() . ')}'
endfunction

" set tabline=%!lighthouse#tabline()
" set guitablabel=%!lighthouse#guitablabel()

command! -nargs=? -complete=customlist,s:Completion LightHouseSearch :call lighthouse#filesearch('<args>')
command! -nargs=? -complete=customlist,s:Completion LightHouseGrep :call lighthouse#ack_grep('<args>')
command! -nargs=? -complete=customlist,s:Completion LightHouseClose :call lighthouse#closeproject('<args>')
command! LightHouseArrange :call s:ArrangeByProjects()


if !hasmapto(':LightHouseSearch<SPACE>')
	silent! nmap <unique> <Leader>ls :LightHouseSearch<SPACE>
endif

if !hasmapto(':LightHouseGrep<SPACE>')
	silent! nmap <unique> <Leader>lg :LightHouseGrep<SPACE>
endif

if !hasmapto(':LightHouseClose<SPACE>')
	silent! nmap <unique> <Leader>lc :LightHouseClose<SPACE>
endif

if !hasmapto(':LightHouseArrange')
	silent! nmap <unique> <Leader>la :LightHouseArrange<CR>
endif
