
function! Fib(n)
    if a:n == 0 || a:n == 1
        return a:n
    else
        return Fib(a:n - 1) + Fib(a:n - 2)
    endif
endfunction
let p1 = mps#new_funcref(function("Fib"), [30])


let f = {}
function! f.call(n)
    return Fib(a:n)
endfunction
let p2 = mps#new_dict(f, 'call', [30])


echo p1.join()
echo p2.join()
