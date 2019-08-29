if !exists('*popup_create')
  " Then this version of Vim doesn't support popups
  finish
endif

command! -buffer Quickpeek       call quickpeek#Start()
command! -buffer QuickpeekStop   call quickpeek#Stop()
command! -buffer QuickpeekToggle call quickpeek#Toggle()

if g:quickpeek_auto
  silent call quickpeek#Start()
endif
