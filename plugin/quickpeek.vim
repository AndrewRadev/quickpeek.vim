if exists('g:loaded_quickpeek') || &cp
  finish
endif

let g:loaded_quickpeek = '0.0.1' " version number
let s:keepcpo = &cpo
set cpo&vim

if !exists('g:quickpeek_auto')
  let g:quickpeek_auto = v:true
endif

let g:quickpeek_popups = []

let &cpo = s:keepcpo
unlet s:keepcpo
