" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}


function! MpsServerRun(func_lines) "{{{
    " TODO: Treat dict function
    execute join([
    \   'function! F()'
    \] + a:func_lines + [
    \   'endfunction'
    \], "\n")

    while 1
        sleep 1
    endwhile
endfunction "}}}


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
