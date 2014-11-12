if exists("*unite#custom#profile")
	" configure unite
	call unite#custom#profile('default', 'context', {
	\   'prompt': '» ',
	\   'start_insert': 1,
	\   'update_time': 200,
	\   'direction': 'botright',
	\ })

	call unite#custom#source('file_rec/async','sorters','sorter_rank')

	call unite#custom#source('file,file/new,file_rec,file_rec/async',
	\ 'matchers', ['matcher_hide_hidden_files', 'converter_relative_word', 'matcher_fuzzy'])

	call unite#filters#sorter_default#use(['sorter_rank'])
endif
