[![GitHub version](https://badge.fury.io/gh/andrewradev%2Fquickpeek.vim.svg)](https://badge.fury.io/gh/andrewradev%2Fquickpeek.vim)

![Screenshot](http://i.andrewradev.com/6804b403afed3e709d33b6c15c01c3f8.png)

## Usage

Turn on/off preview popup (commands only defined in quickfix window):

``` vim
:Quickpeek
:QuickpeekStop
:QuickpeekToggle
```

It's recommended to create a mapping for `QuickpeekToggle`, for instance, in `~/.vim/ftplugin/qf.vim`, you can do this:

``` vim
nnoremap <buffer> <c-p> :QuickpeekToggle<cr>
```

To turn preview popup on automatically, put this in your `.vimrc`:

``` vim
let g:quickpeek_auto = v:true
```

Note that auto mode is currently experimental and results in some weird issues for me sometimes. If you end up with popups hanging around, you can close all of them with `:call popup_close()`.

You can customize the popup that shows up using the `g:quickpeek_popup_options` variable. See the help docs for more details.

## Requirements

The plugin needs Vim with popup window support (v8.1 with a large patch number), otherwise it'll silently do nothing. If you'd like to check if you have popups, try:

``` vim
:echo exists('*popup_create')
```

If you get the value of "1", that means you have popup support.

## Related Work

- The [quickr-preview](https://github.com/ronakg/quickr-preview.vim) plugin provides previews of quickfix items in customizable buffers.
- The [quickui](https://github.com/skywind3000/vim-quickui#preview-quickfix) plugin has a preview popup as well, although it comes with a lot of other functionality.

## Contributing

Pull requests are welcome, but take a look at [CONTRIBUTING.md](https://github.com/AndrewRadev/quickpeek.vim/blob/master/CONTRIBUTING.md) first for some guidelines. Be sure to abide by the [CODE_OF_CONDUCT.md](https://github.com/AndrewRadev/quickpeek.vim/blob/master/CODE_OF_CONDUCT.md) as well.
