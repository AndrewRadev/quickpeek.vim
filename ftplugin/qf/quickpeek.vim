if !exists('*popup_create')
  " Then this version of Vim doesn't support popups
  finish
endif

command! -buffer Quickpeek       call s:Start()
command! -buffer QuickpeekStop   call s:Stop()
command! -buffer QuickpeekToggle call s:Toggle()

function! s:Toggle()
  if get(b:, 'quickpeek_active', v:false)
    call s:Stop()
  else
    call s:Start()
  endif
endfunction

function! s:Start()
  let b:quickpeek_active = v:true
  let b:quickpeek_popup  = -1

  exe "augroup quickpeek_popup_".bufnr('%')
    autocmd!
    autocmd CursorMoved <buffer> call s:ShowPopup()
    autocmd WinLeave    <buffer> call s:HidePopup()
    autocmd WinEnter    <buffer> call s:ShowPopup()

    autocmd FileType * if &ft != 'qf' | call s:ClearAllPopups() | endif
  augroup END

  call s:ShowPopup()
endfunction

function s:ClearAllPopups()
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

function! s:Stop()
  call s:HidePopup()

  exe "augroup quickpeek_popup_".bufnr('%')
    autocmd!
  augroup END

  let b:quickpeek_active = v:false
endfunction

function! s:ShowPopup()
  if line('.') == get(b:, 'quickpeek_line', -1)
    return
  endif

  let file_name = s:GetCommandOutput(':file')
  if stridx(file_name, '"[Quickfix List]"') == 0
    let qf_list = getqflist()
  elseif stridx(file_name, '"[Location List]"') == 0
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
  let b:quickpeek_popup = popup_create(qf_entry.bufnr, {
        \ 'maxheight': 7,
        \ 'minwidth':  wininfo.width - 3,
        \ 'maxwidth':  wininfo.width - 3,
        \ 'pos':       'botleft',
        \ 'col':       wininfo.wincol,
        \ 'line':      wininfo.winrow - 2,
        \ 'firstline': max([qf_entry.lnum - 3, 0]),
        \ 'border':    [],
        \ 'title':     "Quickpeek"
        \ })
  call add(g:quickpeek_popups, b:quickpeek_popup)
endfunction

function! s:GetCommandOutput(command)
  redir => output
  exe a:command
  redir END

  " Trim whitespace:
  let output = substitute(output, '^\_s\+', '', '')
  let output = substitute(output, '\_s\+$', '', '')

  return output
endfunction

if g:quickpeek_auto
  silent call s:Start()
endif
