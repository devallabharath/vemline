" for closing the buffers

function! vem_tabline#close#Init() abort
  return 1
endfunction

function! CloseBufs(bufs, force) abort
  let cmd = a:force ? 'bd!' : 'bd'
  let left = []
  for buf in a:bufs
    try
      exec cmd . buf
    catch
      let left = left + [buf]
    endtry
  endfor
  return left
endfunction

function! vem_tabline#close#dirty_bufs(bufs) abort
  let msg = "There are unsaved files left..."
  let ans = confirm(msg, "&SaveAndClose\n&ForceClose\n&Leave", 3)
  if ans == 1
    for buf in a:bufs
      execute 'buffer' . buf
      update
      exec 'bd' . buf
    endfor
  elseif ans == 2
    call CloseBufs(a:bufs, 1)
  else
    return
  endif
endfunction

function! vem_tabline#close#All()
  let ans = confirm('!󰬊 Close all buffers?', "&No\n&Yes", 1)
  if !ans || ans == 1
    return
  endif
  let bufs =  t:vem_tabline_buffers
  let id = index(bufs, bufnr('%'))
  call remove(bufs, id)
  let left = CloseBufs(bufs, 0)
  if len(left) != 0
    call vem_tabline#close#dirty_bufs(left)
  endif
endfunction

function! vem_tabline#close#Side(dir)
  let msg = a:dir == 'left' ? " 󰬊 Close All Left?" : "󰬊  Close All Right?"
  let ans = confirm(msg, "&No\n&Yes", 1)
  if !ans || ans == 1
    return
  endif
  let bufs = t:vem_tabline_buffers
  let id = index(bufs, bufnr('%'))
  let bufs = a:dir == 'left' ? bufs[:id-1] : bufs[id+1:]
  let left = CloseBufs(bufs, 0)
  if len(left) != 0
    call vem_tabline#close#dirty_bufs(left)
  endif
endfunction

function! vem_tabline#close#Unpinned()
  let ans = confirm('!󰬊 !󰐃 Close all except Current & Pinned?', "&No\n&Yes", 1)
  if !ans || ans == 1
    return
  endif
  let left = []
  let bufs =  t:vem_tabline_buffers
  let id = index(bufs, bufnr('%'))
  call remove(bufs, id)
  for buf in bufs
    if !vem_tabline#pins#is_pinned(buf)
      let left = left +[buf]
    endif
  endfor
  let left = CloseBufs(left, 0)
  if len(left) != 0
    call vem_tabline#close#dirty_bufs(left)
  endif
endfunction
