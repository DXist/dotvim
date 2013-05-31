let g:projects = []
call add(projects, ['vim', expand('~/.vim')])

function! s:projects_from_path(path, prefix)
	let l:projects = []
	for s:project_path in split(glob(a:path . '/*'))
		call add(projects, [a:prefix . fnamemodify(s:project_path, ':t'), s:project_path])
	endfor
	return l:projects
endfunction

" call extend(projects, s:projects_from_path('~/workspace', ''))
" call extend(projects, s:projects_from_path('~/envs', 'env_'))
