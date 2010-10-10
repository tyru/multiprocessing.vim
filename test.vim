
function! s:fib(n)
    if a:n == 0 || a:n == 1
        return a:n
    else
        return s:fib(a:n - 1) + s:fib(a:n - 2)
    endif
endfunction
let p1 = mps#new(s:fib, [30])


let f = {}
function! f.call(n)
    return s:fib(a:n)
endfunction
let p2 = mps#new(f.call, [30], f)


echo p1.join()
echo p2.join()
