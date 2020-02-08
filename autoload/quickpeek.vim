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
  " let b:quickpeek_popup  = -1

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
    call s:ClosePopup(p)
  endfor
  let g:quickpeek_popups = []
endfunction

function! s:HidePopup()
  if exists('b:quickpeek_popup')
    call s:ClosePopup(b:quickpeek_popup)
    unlet b:quickpeek_popup
  endif
  unlet! b:quickpeek_line
endfunction

function! s:MaybeShowPopup()
  if line('.') == get(b:, 'quickpeek_line', -1)
    return
  endif

  if exists('*timer_start') && !has('nvim')
    " Show the popup on the next tick, otherwise filetype detection doesn't
    " get triggered.
    "
    " Disabled for neovim since s:WinExecuteAll seems to execute stuff
    " inbetween window switches.
    "
    call timer_start(1, {-> s:ShowPopup()})
  else
    " No timers available (or we're on neovim), let's just show the popup
    " immediately.
    call s:ShowPopup()
  endif
endfunction

function! s:ShowPopup()
  if exists('b:quickpeek_popup')
    call s:ClosePopup(b:quickpeek_popup)
  endif

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

  if qf_entry.bufnr <= 0
    " no buffer for this entry, nothing to preview
    return
  endif

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
    call s:ClosePopup(b:quickpeek_popup)
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

  let b:quickpeek_popup = s:CreatePopup(qf_entry.bufnr, options)

  let commands = []
  for setting in g:quickpeek_window_settings
    call add(commands, 'setlocal '.setting)
  endfor
  call add(commands, 'normal! zR')
  call add(commands, 'normal! '.cursorline.'Gzz')
  call s:WinExecuteAll(b:quickpeek_popup, commands)

  call add(g:quickpeek_popups, b:quickpeek_popup)
endfunction

function! s:CreatePopup(bufnr, options)
  if exists('*popup_create')
    return popup_create(a:bufnr, a:options)
  elseif exists('*nvim_open_win')
    return nvim_open_win(a:bufnr, 0, {
          \ 'relative':  'win',
          \ 'focusable': 0,
          \ 'height':    a:options.maxheight,
          \ 'width':     a:options.maxwidth + 3,
          \ 'col':       a:options.col,
          \ 'row':       -(a:options.maxheight + 1),
          \ })
  endif
endfunction

function! s:ClosePopup(popup)
  if exists('*popup_close')
    call popup_close(a:popup)
  elseif exists('*nvim_win_close')
    if nvim_win_is_valid(a:popup)
      call nvim_win_close(a:popup, 1)
    endif
  endif
endfunction

function! s:WinExecuteAll(window, commands)
  if exists('*win_execute')
    for command in a:commands
      call win_execute(a:window, command)
    endfor
  elseif exists('*nvim_set_current_win')
    if !nvim_win_is_valid(a:window)
      return
    endif

    let current_win = nvim_get_current_win()

    try
      call nvim_set_current_win(a:window)

      for command in a:commands
        exe command
      endfor
    finally
      call nvim_set_current_win(current_win)
    endtry
  endif
endfunction
