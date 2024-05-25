function! vem_tabline#order#Init() abort
  return 1
endfunction

function! ByPath(a, b)
  let path_a = fnamemodify(bufname(a:a), ':h')
  let path_b = fnamemodify(bufname(a:b), ':h')
  if path_a == path_b
      let name_a = fnamemodify(bufname(a:a), ':t:r')
      let name_b = fnamemodify(bufname(a:b), ':t:r')
      return name_a > name_b ? 1 : name_a < name_b ? -1 : 0
  else
      return path_a > path_b ? 1 : path_a < path_b ? -1 : 0
  endif
endfunction

function! ByName(a, b)
  let name_a = fnamemodify(bufname(a:a), ':t:r')
  let name_b = fnamemodify(bufname(a:b), ':t:r')
  return name_a > name_b ? 1 : name_a < name_b ? -1 : 0
endfunction

function! ByType(a, b)
  let name_a = fnamemodify(bufname(a:a), ':e')
  let name_b = fnamemodify(bufname(a:b), ':e')
  return name_a > name_b ? 1 : name_a < name_b ? -1 : 0
endfunction

function! vem_tabline#order#ByTime(o)
  let t:vem_tabline_buffers = sort(t:vem_tabline_buffers)
  if a:o == '>'
      let t:vem_tabline_buffers = reverse(t:vem_tabline_buffers)
  endif
  call g:vem_tabline#tabline.refresh()
endfunction

function! vem_tabline#order#By(c, o)
  let t:vem_tabline_buffers = sort(t:vem_tabline_buffers, a:c)
  if a:o == '>'
      let t:vem_tabline_buffers = reverse(t:vem_tabline_buffers)
  endif
  call g:vem_tabline#tabline.refresh()
endfunction
