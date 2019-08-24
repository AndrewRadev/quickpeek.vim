![Screenshot](http://i.andrewradev.com/633bb5fa2d8cc713a0cec95845d34b59.jpg)

## Usage

Turn on/off preview popup (commands only defined in quickfix window):

```
:Quickpeek
:QuickpeekStop
:QuickpeekToggle
```

It's recommended to just come up with a mapping for `QuickpeekToggle`, for instance, in `~/.vim/ftplugin/qf.vim`, you can do this:

```
nnoremap <c-p> :QuickpeekToggle<cr>
```

To turn preview popup on automatically, put this in your `.vimrc`:

```
let g:quickpeek_auto = v:true
```

## Requirements

The plugin needs Vim with popup window support (v8.1 with a large patch number), otherwise it'll silently do nothing. If you'd like to check if you have popups, try `echo exists('*popup_create')`.

## Contributing

Pull requests are welcome, but take a look at [CONTRIBUTING.md](https://github.com/AndrewRadev/quickpeek.vim/blob/master/CONTRIBUTING.md) first for some guidelines. Be sure to abide by the [CODE_OF_CONDUCT.md](https://github.com/AndrewRadev/quickpeek.vim/blob/master/CODE_OF_CONDUCT.md) as well.
