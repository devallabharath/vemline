" for closing the buffers

function! vem_tabline#close#Init() abort
  return 1
endfunction

function! Side_buffers(dir) abort
  let sorted_buffers = t:vem_tabline_buffers
  let bufnum = bufnr('%')
  let bufnum_pos = index(sorted_buffers, bufnum)
  let buf_count = len(sorted_buffers)
  if a:dir == 'left'
      let bufs = bufnum_pos == 0 ? [] : sorted_buffers[:bufnum_pos-1]
      return bufs
  else
      let bufs = bufnum_pos == buf_count ? [] : sorted_buffers[bufnum_pos+1:]
      return bufs
  endif
endfunction

function! vem_tabline#close#All() abort
  let left = []
  let curr = bufnr('%')
  let bufs =  g:vem_tabline#tabline.tabline_buffers
  let ans = confirm('!󰬊 Close all buffers?', "&No\n&Yes", 1)
  if ans == 2
      for buf in bufs
          if curr != buf
              try
                  exec 'bd' . buf
              catch /E89:/
                  let left = left + [buf]
              endtry
          endif
      endfor
      if len(left) != 0
          echohl WarningMsg
          echo "Some unsaved files were left..."
          echohl None
      endif
  endif
endfunction

function! vem_tabline#close#Side(dir) abort
  let left = []
  let prompt = " 󰬊 Close All Left?"
  if a:dir == 'right'
      let prompt = "󰬊  Close All Right?"
  endif
  let ans = confirm(prompt, "&No\n&Yes", 1)
  if ans == 2
      for buf in Side_buffers(a:dir)
          try
              exec 'bd' . buf
          catch /E89:/
              let left = left + [buf]
          endtry
      endfor
      if len(left) != 0
          echohl WarningMsg
          echo "Some unsaved files were left..."
          echohl None
      endif
  endif
endfunction

function! vem_tabline#close#Unpinned() abort
  let left = []
  let curr = bufnr('%')
  let bufs =  g:vem_tabline#tabline.tabline_buffers
  let ans = confirm('!󰬊 !󰐃 Close all except Current & Pinned?', "&No\n&Yes", 1)
  if ans == 2
      for buf in bufs
          let pinned = luaeval('require("hbac.state").is_pinned(' . buf . ')')
          if curr != buf && !pinned
              try
                  exec 'bd' . buf
              catch /E89:/
                  let left = left + [buf]
              endtry
          endif
      endfor
      if len(left) != 0
          echohl WarningMsg
          echo "Some unsaved files were left..."
          echohl None
      endif
  endif
endfunction
