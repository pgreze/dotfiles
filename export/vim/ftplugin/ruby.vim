
"""""""""""""""
" RUBY
"""""""""""""""
"F2 pour avoir de l'aide sur ruby

if !exists("Ri")
    function Ri()
	    let b:x = system("ri '" . input("ri: ") . "' > /tmp/ri_output")
	    sp /tmp/ri_output
    endfunction
endif

map <F2> :call Ri()<CR>
set shiftwidth=2
set tabstop=2
set expandtab
set smartindent


