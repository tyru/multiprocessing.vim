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

    let o.__func_lines = s:get_func_lines_from_output(output)
    let o.__args = a:args
    let o.__session_id = s:create_session_id()
    let o.__client_name = v:servername

    return o
endfunction "}}}

function! mps#new_dict(dict, key, args) "{{{
    let o = deepcopy(s:multiprocessing)

    let save_list = &l:list
    setlocal nolist
    try
        redir => output
        silent function a:dict[a:key]
        redir END
    finally
        let &l:list = save_list
    endtry

    let o.__func_lines = s:get_func_lines_from_output(output)
    let o.__args = a:args
    let o.__session_id = s:create_session_id()
    let o.__client_name = v:servername

    return o
endfunction "}}}

function! s:get_func_lines_from_output(output) "{{{
    return map(
    \   split(
    \       matchstr(a:output, '^\s*\zs.\{-}\ze\s*$'),
    \       "\n"
    \   )[1:-2],
    \   'substitute(v:val, "^\\d\\+", "", "")'
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

function! s:mpsserver_error(msg) "{{{
    return 'mps: mpsserver error: ' . a:msg
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
    let mpsserver_path = globpath(&rtp, 'autoload/mps/__mpsserver__.vim')
    if mpsserver_path == ''
        throw s:mpsserver_error('__mpsserver__.vim is not found.')
    endif
    let mpsserver_path = split(mpsserver_path, '\n')[0]

    let options = {
    \   '&shell': &shell,
    \   '&shellcmdflag': &shellcmdflag,
    \}
    " let options = {
    " \   '&shell': &shell,
    " \   '&shellcmdflag': &shellcmdflag,
    " \   '&shellxquote': &shellxquote,
    " \   '&shellredir': &shellredir,
    " \}
    setlocal shell=/bin/sh shellcmdflag=-c
    " setlocal shellxquote= shellredir=>%s\ 2>&1

    try
        Decho 'spawing server...'
        execute 'silent !'
        \   . g:mps_vim_path
        \   . ' -u NONE -i NONE'
        \   . ' --servername ' . self.__servername
        \   . ' -S "' . mpsserver_path . '"'
        \   . ' -c "call MpsServerRun('
        \       . string(self.__func_lines)
        \   . ')"'
        \   . ' -e -s &'
    finally
        for [k, v] in items(options)
            call setbufvar('%', k, v)
        endfor
    endtry

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

    " TODO

    let self.__has_spawned = 0
endfunction "}}}

" Start processing.
function! s:multiprocessing.start() "{{{
    if self.__has_started
        return
    endif

    " Set "self.__servername".
    call self.spawn_server()


    let self.__has_started = 1
endfunction "}}}

" Read the result.
function! s:multiprocessing.join() "{{{
    Decho 'starting process...'
    call self.start()
    Decho 'checking the result...:' . self.__client_name . ' => ' . self.__servername
    return remote_expr(self.__servername, 'call("F", '.string(self.__args).')')
endfunction "}}}

" }}}


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
