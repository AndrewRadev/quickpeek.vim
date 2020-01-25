if exists('g:loaded_quickpeek') || &cp
  finish
endif

let g:loaded_quickpeek = '0.0.1' " version number
let s:keepcpo = &cpo
set cpo&vim

if !exists('*popup_create')
  " Then this version of Vim doesn't support popups
  finish
endif

if !exists('g:quickpeek_auto')
  let g:quickpeek_auto = v:false
endif

if !exists('g:quickpeek_popup_options')
  let g:quickpeek_popup_options = {}
endif

if !exists('g:quickpeek_window_settings')
  let g:quickpeek_window_settings = ['cursorline', 'number', 'relativenumber']
endif

let g:quickpeek_popups = []

let &cpo = s:keepcpo
unlet s:keepcpo
