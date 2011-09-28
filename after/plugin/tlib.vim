let g:tlib_keyagents_InputList_s[10] = 'tlib#agent#Down'  " <c-j>
let g:tlib_keyagents_InputList_s[11] = 'tlib#agent#Up'    " <c-k>

if exists("g:loaded_ttags")
	function g:SmartGoToTag()
		let l:constraints = {'name': expand("<cword>")}
		let l:length = len(tlib#tag#Collect(l:constraints, '',
					\ tlib#var#Get('ttags_match_end', 'bg'),
					\ tlib#var#Get('ttags_match_front', 'bg')))
		echo l:length
		if l:length > 7
			exec ":TTagselect name:" . expand("<cword>")
		else
			call feedkeys("g\<c-]>")
		endif
	endfunction
	nmap g] :call g:SmartGoToTag()<CR>
endif
