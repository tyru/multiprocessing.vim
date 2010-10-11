" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}


if !exists('g:mps_vim_path')
    let g:mps_vim_path = 'vim'
endif


let s:current_max_session_id = 0
let s:current_max_server_id = 0



function! mps#new_funcref(F, args) "{{{
    let o = deepcopy(s:multiprocessing)

    redir => output
    silent function a:F
    redir END

    let o.__func_body = s:get_func_body_from_output(output)
    let o.__args = a:args
    let o.__session_id = s:create_session_id()

    return o
endfunction "}}}

function! mps#new_dict(dict, key, args) "{{{
    let o = deepcopy(s:multiprocessing)

    redir => output
    silent function a:dict[a:key]
    redir END

    let o.__func_body = s:get_func_body_from_output(output)
    let o.__args = a:args
    let o.__session_id = s:create_session_id()

    return o
endfunction "}}}

function! s:get_func_body_from_output(output) "{{{
    return join(
    \   map(
    \       split(
    \           matchstr(a:output, '^\s*\zs.\{-}\ze\s*$'),
    \           "\n"
    \       ),
    \       'substitute(v:val, "^\\d\\+", "", "")'
    \   ),
    \   "\n"
    \)
endfunction "}}}

function! s:create_session_id() "{{{
    " FIXME: Overflow
    let _ = s:current_max_session_id
    let s:current_max_session_id += 1
    return _
endfunction "}}}

function! s:create_server_name() "{{{
    " FIXME: Overflow
    " FIXME: Check if server already exists
    let _ = s:current_max_server_id
    let s:current_max_server_id += 1
    return 'mpsserver' . _
endfunction "}}}


function! s:spawn_error(msg) "{{{
    return 'mps: spawn error: ' . a:msg
endfunction "}}}



let s:multiprocessing = {
\   '__has_spawned': 0,
\   '__has_started': 0,
\}

" Spawn vim server.
function! s:multiprocessing.spawn_server() "{{{
    if self.__has_spawned
        return
    endif

    let self.__servername = s:create_server_name()
    call system(
    \   g:mps_vim_path
    \   . ' -u NONE -i NONE'
    \   . ' --servername ' . self.__servername
    \   . ' -E -s'
    \)

    let success = 0
    if v:shell_error != success
        let msg = "could not spawn '" . g:mps_vim_path . "'."
        throw s:spawn_error(msg)
    endif

    let self.__has_spawned = 1
endfunction "}}}

" Kill vim server.
function! s:multiprocessing.kill_server() "{{{
    if !self.__has_spawned
        return
    endif

    " XXX: If server is not in normal mode?
    call self.send_string(':<C-u>qall!<CR>')

    let self.__has_spawned = 0
endfunction "}}}

" Send string to vim server.
function! s:multiprocessing.send_string(str) "{{{
    if !self.__has_spawned
        return
    endif
    call remote_send(
    \   self.__servername,
    \   a:str,
    \   's:multiprocessing_result_' . self.__session_id
    \)
endfunction "}}}

" Start processing.
function! s:multiprocessing.start() "{{{
    if self.__has_started
        return
    endif

    " Set "self.__servername".
    call self.spawn_server()

    " TODO: escape
    let str = join([
    \   'function! Dummy(...)',
    \   self.__func_body,
    \   'endfunction',
    \], "\n")
    call self.send_string(str)

    let self.__has_started = 1
endfunction "}}}

" Read the result.
function! s:multiprocessing.join() "{{{
    try
        call self.start()
        return remote_read(
        \   s:multiprocessing_result_{self.__session_id}
        \)
    finally
        call self.kill_server()
    endtry
endfunction "}}}

" }}}


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
