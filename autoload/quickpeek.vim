function! quickpeek#Toggle()
  if get(b:, 'quickpeek_active', v:false)
    call quickpeek#Stop()
  else
    call quickpeek#Start()
  endif
endfunction

function! quickpeek#Start()
  if get(b:, 'quickpeek_active', 0)
    return
  endif

  let b:quickpeek_active = v:true
  let b:quickpeek_popup  = -1

  exe "augroup quickpeek_popup_".bufnr('%')
    autocmd!
    autocmd CursorMoved <buffer> call s:MaybeShowPopup()
    autocmd WinLeave    <buffer> call s:HidePopup()
    autocmd WinEnter    <buffer> call s:MaybeShowPopup()

    autocmd FileType * if &ft != 'qf' | call s:ClearAllPopups() | endif
  augroup END

  call s:ShowPopup()
endfunction

function! quickpeek#Stop()
  call s:HidePopup()

  exe "augroup quickpeek_popup_".bufnr('%')
    autocmd!
  augroup END

  let b:quickpeek_active = v:false
endfunction

function! s:ClearAllPopups()
  for p in g:quickpeek_popups
    call popup_close(p)
  endfor
  let g:quickpeek_popups = []
endfunction

function! s:HidePopup()
  if exists('b:quickpeek_popup')
    call popup_close(b:quickpeek_popup)
    unlet b:quickpeek_popup
  endif
  unlet! b:quickpeek_line
endfunction

function! s:MaybeShowPopup()
  if line('.') == get(b:, 'quickpeek_line', -1)
    return
  endif

  if exists('*timer_start')
    " Show the popup on the next tick, otherwise filetype detection doesn't
    " get triggered.
    call timer_start(1, {-> s:ShowPopup()})
  else
    " No timers available, let's just show the popup immediately.
    call s:ShowPopup()
  endif
endfunction

function! s:ShowPopup()
  let wi = getwininfo(win_getid())[0]
  if wi.quickfix
    let qf_list = getqflist()
  elseif wi.loclist
    let qf_list = getloclist(0)
  else
    let qf_list = []
  endif

  if len(qf_list) == 0
    return
  endif

  let b:quickpeek_line = line('.')
  let qf_entry = qf_list[line('.') - 1]

  let wininfo = {}
  for item in getwininfo()
    if item.winnr == winnr()
      let wininfo = item
      break
    endif
  endfor
  if wininfo == {}
    return
  endif

  if exists('b:quickpeek_popup')
    call popup_close(b:quickpeek_popup)
  endif

  let maxheight  = get(g:quickpeek_popup_options, 'maxheight', 7)
  let cursorline = qf_entry.lnum

  let options = {
        \ 'pos':    'botleft',
        \ 'border': [],
        \ 'title':  "Quickpeek"
        \ }
  call extend(options, g:quickpeek_popup_options)
  call extend(options, {
        \ 'maxheight': maxheight,
        \ 'minwidth':  wininfo.width - 3,
        \ 'maxwidth':  wininfo.width - 3,
        \ 'col':       wininfo.wincol,
        \ 'line':      wininfo.winrow - 2,
        \ })

  silent let b:quickpeek_popup = popup_create(qf_entry.bufnr, options)

  call win_execute(b:quickpeek_popup, 'setlocal cursorline')
  call win_execute(b:quickpeek_popup, 'normal! '.cursorline.'Gzz')

  call add(g:quickpeek_popups, b:quickpeek_popup)
endfunction
