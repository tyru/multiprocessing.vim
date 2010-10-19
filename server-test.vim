
" Make local scope.
function! s:run()
    let path = globpath(&rtp, 'autoload/mps/__mpsserver__.vim')
    if path == ''
        echoerr 'autoload/mps/__mpsserver__.vim is not found.'
        finish
    endif

    " XXX: it works also with s:fib ?
    " let fib = {}
    " function! fib.call(n)
    "     if a:n == 0 || a:n == 1
    "         return a:n
    "     else
    "         return Fib(a:n - 1) + Fib(a:n - 2)
    "     endif
    " endfunction
    " let ps = mps#new_dict(fib, 'call', [30])
    let ps = {
    \   '__func_lines': ['return "dummy"'],
    \   '__args': [],
    \   '__client_name': v:servername,
    \}

    let server_name = 'hoge'
    " execute
    " \   '!vim -u NONE -i NONE --servername ' . server_name
    " \   "-c 'source ".path."' -c 'call MpsServerRun(".string(ps).")' -e -s &"
    " execute
    " \   '!vim -u NONE -i NONE --servername ' . server_name
    " \   '-c "sleep 5" -e -s &'

    " sleep while... and check it.
    sleep 1
    echo serverlist()

    " XXX: Oh it's wrong!
    " Receive the result.
    " function! s:remote_reply()
    "     echo server2client(expand('<amatch>'), 'received, thanks!')
    "     let g:result = expand('<afile>')
    "     echom 'the result is ' . string(g:result) . '.'
    " endfunction
    " autocmd RemoteReply * call s:remote_reply()

    echom 's:run() ... done.'
endfunction
call s:run()
