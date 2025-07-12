let s:timer_id = -1

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

    autocmd BufEnter * if &buftype != 'quickfix' | call s:ClearAllPopups() | endif
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
    " Show the popup after a timeout, otherwise filetype detection doesn't get
    " triggered. The timeout is debounced to avoid issues with fast scrolling.
    if s:timer_id > 0
      call timer_stop(s:timer_id)
    endif

    let s:timer_id = timer_start(g:quickpeek_delay, {-> s:ShowPopup()})
  else
    " No timers available, let's just show the popup immediately.
    call s:ShowPopup()
  endif
endfunction

function! s:ShowPopup()
  let s:timer_id = -1

  if exists('b:quickpeek_popup')
    call popup_close(b:quickpeek_popup)
  endif

  let wininfo = getwininfo(win_getid())[0]
  if wininfo.loclist
    let qf_list = getloclist(0)
  elseif wininfo.quickfix
    let qf_list = getqflist()
  else
    let qf_list = []
  endif

  if len(qf_list) == 0
    return
  endif

  let b:quickpeek_line = line('.')
  let qf_entry = qf_list[line('.') - 1]

  if qf_entry.bufnr <= 0
    " no buffer for this entry, nothing to preview
    return
  endif

  let maxheight = get(g:quickpeek_popup_options, 'maxheight', 7)
  let title = $' {qf_entry.bufnr->bufname()->fnamemodify(':~:.')} '
  let options = {
        \ 'pos':    'botleft',
        \ 'border': [],
        \ 'title':  title,
        \ 'filter': function('s:PopupFilter')
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

  for setting in g:quickpeek_window_settings
    call win_execute(b:quickpeek_popup, 'setlocal '.setting)
  endfor
  if qf_entry.lnum > 0
    call win_execute(b:quickpeek_popup, 'normal! '.qf_entry.lnum.'Gzz')
  endif

  call add(g:quickpeek_popups, b:quickpeek_popup)
endfunction

function! s:PopupFilter(winid, key)
  if !empty('g:quickpeek_popup_scroll_up_key') && a:key == g:quickpeek_popup_scroll_up_key
    call win_execute(a:winid, "normal! \<c-y>")
    return v:true
  elseif !empty('g:quickpeek_popup_scroll_down_key') && a:key == g:quickpeek_popup_scroll_down_key
    call win_execute(a:winid, "normal! \<c-e>")
    return v:true
  endif
  return v:false
endfunction
