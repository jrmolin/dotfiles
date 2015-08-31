" add some functions for handling restructured text
" Modified:     2015 july 22
" Maintainer:   jonathan molinatto
" License:      OSI approved MIT license

if exists("g:loaded_rstfuncs")
    finish
endif
let g:loaded_rstfuncs = 1

" noremap is a bit misleading here if you are unused to vim mapping.
" in fact, there is remapping, but only of script locally defined remaps, in 
" this case <SID>TogBG. The <script> argument modifies the noremap scope in 
" this regard (and the noremenu below).
nnoremap <buffer> <leader>= yypVr=
nnoremap <buffer> <leader>- yypVr-

echom "we've loaded a module"
