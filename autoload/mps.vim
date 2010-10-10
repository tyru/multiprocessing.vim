" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}


" Interface {{{

function! mps#new(F, args, ...) "{{{
    let o = deepcopy(s:multiprocessing)
    let o.__func = a:F
    let o.__args = a:args
    if a:0
        let o.__dict = a:1
    endif
    return  o
endfunction "}}}

" }}}

" Implementation {{{
let s:multiprocessing = {}

" Spawn vim server.
function! s:multiprocessing.spawn(vim_option_arguments) "{{{
    " TODO
endfunction "}}}

function! s:multiprocessing.start() "{{{
    " TODO
endfunction "}}}

function! s:multiprocessing.join() "{{{
    " TODO
endfunction "}}}

" }}}

" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
