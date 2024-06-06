function! vem_tabline#pins#Init() abort
	let t:vem_tabline_pins = []
	return 1
endfunction

function! vem_tabline#pins#pin(bufn) abort
	let t:vem_tabline_pins = t:vem_tabline_pins+[a:bufn]
endfunction

function! vem_tabline#pins#unpin(bufn) abort
	let id = index(t:vem_tabline_pins, a:bufn)
	call remove(t:vem_tabline_pins, id)
endfunction

function! vem_tabline#pins#toggle(nr) abort
	let bufn = a:nr ? a:nr : bufnr('%')
	if vem_tabline#pins#is_pinned(bufn)
		call vem_tabline#pins#unpin(bufn)
	else
		call vem_tabline#pins#pin(bufn)
	endif
	call g:vem_tabline#tabline.refresh()
endfunction

function! vem_tabline#pins#toggle_all(pin) abort
	if a:pin
		let t:vem_tabline_pins = t:vem_tabline_buffers
	else
		let t:vem_tabline_pins = []
	endif
	call g:vem_tabline#tabline.refresh()
endfunction

function! vem_tabline#pins#is_pinned(bufn) abort
	if index(t:vem_tabline_pins, a:bufn) == -1
		return 0
	else
		return 1
	endif
endfunction
