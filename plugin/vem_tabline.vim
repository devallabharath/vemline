" Vem Tabline. Plugin to display buffers and tabs in the tabline.
" Part of vem project
" Maintainer: Andrés Sopeña <asopena@ehmm.org>
" Licence: The MIT License (MIT)

" Sentinel to prevent double execution and ensure a modern version of Vim
if exists('g:loaded_vem_tabline') || v:version < 700
    finish
endif
let g:loaded_vem_tabline = 1

scriptencoding utf-8

" Configuration variables
let g:vem_tabline_show = get(g:, 'vem_tabline_show', 1)
let g:vem_tabline_show_icon = get(g:, 'vem_tabline_show_icon', 1)
let g:vem_tabline_show_number = get(g:, 'vem_tabline_show_number', 'none')
let g:vem_tabline_number_symbol = get(g:, 'vem_tabline_number_symbol', ':')
let g:vem_tabline_multiwindow_mode = get(g:, 'vem_tabline_multiwindow_mode', 0)
let g:vem_tabline_location_symbol = get(g:, 'vem_tabline_location_symbol', '@')
if has('gui_running')
    let g:vem_tabline_left_arrow = get(g:, 'vem_tabline_left_arrow', '◀')
    let g:vem_tabline_right_arrow = get(g:, 'vem_tabline_right_arrow', '▶')
else
    let g:vem_tabline_left_arrow = get(g:, 'vem_tabline_left_arrow', '<')
    let g:vem_tabline_right_arrow = get(g:, 'vem_tabline_right_arrow', '>')
endif
let g:vem_unnamed_buffer_label = get(g:, 'vem_unnamed_buffer_label', '[No Name]')

" Syntax highlighting
highlight default link VemTablineNormal TabLine
highlight default link VemTablineLocation TabLine
highlight default link VemTablineNumber TabLine
highlight default link VemTablineSelected TabLineSel
highlight default link VemTablineLocationSelected TabLineSel
highlight default link VemTablineNumberSelected TabLineSel
highlight default link VemTablineShown TabLine
highlight default link VemTablineLocationShown TabLine
highlight default link VemTablineNumberShown TabLine
highlight default link VemTablinePartialName Tabline
highlight default link VemTablineSeparator TabLineFill
highlight default link VemTablineTabNormal TabLineFill
highlight default link VemTablineTabSelected TabLineSel
highlight default link VemTabline VemTablineNormal

" Functions

call vem_tabline#Init()

" Only call tabline.refresh() if the modified status of the buffer changes
" This function is needed to optimize performance
" TextChanged and TextChangedI are called too frequently to redraw every time
function! s:check_buffer_changes() abort
    let bufnum = bufnr('%')
    let old_modified_flag = getbufvar(bufnum, "vem_tabline_mod_opt")
    if old_modified_flag != &modified
        call g:vem_tabline#tabline.refresh()
        call setbufvar(bufnum, 'vem_tabline_mod_opt', &modified)
    endif
endfunction

" User function to switch buffers
function! VemTablineGo(tagnr) abort
    try
        let buffnr = g:vem_tabline#buffers#section.tagnr_map[a:tagnr . g:vem_tabline_number_symbol]
        exec 'buffer' . buffnr
    catch //
        echoerr "VemTabline: Buffer " . a:tagnr . " does not exist"
    endtry
endfunction

function! GoLastBuffer() abort
    let last = len(g:vem_tabline#buffers#section.buffer_items)
    call VemTablineGo(last)
endfunction

function! BufferCloseSide(dir) abort
    let left = []
    let prompt = " 󰬊 Close All Left?"
    if a:dir == 'right'
        let prompt = "󰬊  Close All Right?"
    endif
    let ans = confirm(prompt, "&No\n&Yes", 1)
    if ans == 2
        for buf in g:vem_tabline#tabline.side_buffers(a:dir)
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

function! BufferCloseAllButCurrent() abort
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

function! BufferCloseAllButCurrentAndPinned() abort
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

function! BufferOrderByTime(o)
    let t:vem_tabline_buffers = sort(t:vem_tabline_buffers)
    if a:o == '>'
        let t:vem_tabline_buffers = reverse(t:vem_tabline_buffers)
    endif
    call g:vem_tabline#tabline.refresh()
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

function! BufferOrderBy(c, o)
    let t:vem_tabline_buffers = sort(t:vem_tabline_buffers, a:c)
    if a:o == '>'
        let t:vem_tabline_buffers = reverse(t:vem_tabline_buffers)
    endif
    call g:vem_tabline#tabline.refresh()
endfunction

" Commands

command! -nargs=1 BufferGo call VemTablineGo("<args>")
command! BufferGoRight call vem_tabline#tabline.select_buffer('right')
command! BufferGoLeft call vem_tabline#tabline.select_buffer('left')
command! BufferGoFirst call VemTablineGo(1)
command! BufferGoLast call GoLastBuffer()
command! BufferMoveRight call vem_tabline#tabline.move_buffer('right')
command! BufferMoveLeft call vem_tabline#tabline.move_buffer('left')
command! BufferMoveStart call vem_tabline#tabline.move_buffer_ends('start')
command! BufferMoveLast call vem_tabline#tabline.move_buffer_ends('last')
command! BufferCloseAllLeft call BufferCloseSide('left')
command! BufferCloseAllRight call BufferCloseSide('right')
command! BufferCloseAllButCurrent call BufferCloseAllButCurrent()
command! BufferCloseAllButCurrentAndPinned call BufferCloseAllButCurrentAndPinned()
command! BufferOrderByTimeAsc call BufferOrderByTime('<')
command! BufferOrderByTimeAsc call BufferOrderByTime('>')
command! BufferOrderByPathAsc call BufferOrderBy('ByPath', '<')
command! BufferOrderByPathDsc call BufferOrderBy('ByPath', '>')
command! BufferOrderByNameAsc call BufferOrderBy('ByName', '<')
command! BufferOrderByNameDsc call BufferOrderBy('ByName', '>')
command! BufferOrderByTypeAsc call BufferOrderBy('ByType', '<')
command! BufferOrderByTypeDsc call BufferOrderBy('ByType', '>')

" Autocommands
augroup VemTabLine
    autocmd!
    autocmd VimEnter,TabEnter,WinEnter * call vem_tabline#tabline.refresh()
    autocmd BufAdd,BufEnter,BufFilePost * call vem_tabline#tabline.refresh()
    autocmd VimResized,CursorHold * call vem_tabline#tabline.refresh()
    autocmd BufUnload * call vem_tabline#tabline.refresh(str2nr(expand('<abuf>')))
    autocmd TextChanged,TextChangedI,BufWritePost * call s:check_buffer_changes()
    autocmd FileType qf call vem_tabline#tabline.refresh()
augroup END

" Options
set guioptions-=e
set tabline=%!vem_tabline#tabline.render()
