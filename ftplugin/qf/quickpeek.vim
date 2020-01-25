if !exists('*popup_create') && !exists('*nvim_open_win')
  " Then this version of Vim doesn't support popups
  finish
endif

command! -buffer Quickpeek       call quickpeek#Start()
command! -buffer QuickpeekStop   call quickpeek#Stop()
command! -buffer QuickpeekToggle call quickpeek#Toggle()

if g:quickpeek_auto
  silent call quickpeek#Start()
endif
