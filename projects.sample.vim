let g:projects = []
call add(projects, ['vim', expand('~/.vim')])

function! s:projects_from_path(path, prefix)
	let l:projects = []
	for s:project_path in reverse(split(glob(a:path . '/*')))
		if isdirectory(s:project_path)
			call add(projects, [a:prefix . fnamemodify(s:project_path, ':t'), s:project_path])
		endif
	endfor
	return l:projects
endfunction

" call extend(projects, s:projects_from_path('~/workspace', ''))
" call extend(projects, s:projects_from_path('~/envs', 'env_'))
" call extend(projects, s:projects_from_path('~/goworkspace/src/github.com', 'go_'))
