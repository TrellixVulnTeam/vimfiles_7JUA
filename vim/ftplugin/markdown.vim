" Jyd
if exists('b:did_markdown_vim')
"  finish
endif

let b:did_markdown_vim = 1

" hi link mkdLineBreak  CursorLineNr
hi link mkdLineBreak Underlined

setlocal foldlevel=1
set textwidth=120

"Markdown preview
function! PreviewMarkdown()
  execute ":silent !open -a \"Typora.app\" \"%:p\""
  execute ":redraw!"
endfunction

" Preview markdown as mindmap
function! PreviewMindmap()
  let b:job = jobstart("markmap -w " . expand("%:p"), { "detach": 1})
endfunction

" Customizing surround 
let g:surround_{char2nr("*")} = "**\r**"
let g:surround_{char2nr("I")} = "_\r_"
let g:surround_{char2nr('c')}="```\r```"
let g:surround_{char2nr('C')}="```\1lang:\1\r```"

nmap <buffer> <LocalLeader>r :update<cr>:call PreviewMarkdown()<cr>
nmap <buffer> <LocalLeader>m :update<cr>:call PreviewMindmap()<cr>

"Key Mapings
if has("mac")
  nmap <buffer> <LocalLeader>r :update<cr>:call PreviewMarkdown()<cr>
endif

nmap <buffer> <space><space> ysiw`

nmap <buffer> <LocalLeader>p :call mdip#MarkdownClipboardImage()<CR>
nmap <buffer> <LocalLeader>tf :TableFormat<cr>

nmap <buffer> <LocalLeader>1 :call setline('.', substitute(getline('.'), '^#* *', '# ', ''))<cr>
nmap <buffer> <LocalLeader>2 :call setline('.', substitute(getline('.'), '^#* *', '## ', ''))<cr>
nmap <buffer> <LocalLeader>3 :call setline('.', substitute(getline('.'), '^#* *', '### ', ''))<cr>
nmap <buffer> <LocalLeader>4 :call setline('.', substitute(getline('.'), '^#* *', '#### ', ''))<cr>
nmap <buffer> <LocalLeader>5 :call setline('.', substitute(getline('.'), '^#* *', '##### ', ''))<cr>
nmap <buffer> <LocalLeader>6 :call setline('.', substitute(getline('.'), '^#* *', '###### ', ''))<cr>
nmap <buffer> <LocalLeader>i :call setline('.', substitute(getline('.'), '\v!\[(.*)\]\((.*)\)', '<img alt="\1" src="\2" style="zoom:0.5" />', ''))<cr>

function! AddLineBreak() range
    let m = visualmode()
    if m ==# 'v'
        echo 'character-wise visual'
    elseif m == 'V'
        for line in range(a:firstline, a:lastline)
          call setline(line, substitute(getline(line), ' *$', '  ', ''))
        endfor
    elseif m == "\<C-V>"
        echo 'block-wise visual'
    endif
endfunction

command! -nargs=0 -range=% Mbr :<line1>,<line2>call AddLineBreak()

function! ToUnorderList() range
  let m = visualmode()
  if m ==# 'V'
    for line in range(a:firstline, a:lastline)
      call setline(line, '+ ' . getline(line))
    endfor
  endif
endfunction

command! -nargs=0 -range=% Ml :<line1>,<line2>call ToUnorderList()

function! ToOrderList() range
  let m = visualmode()
  if m ==# 'V'
    let i = 1
    for line in range(a:firstline, a:lastline)
      call setline(line, i . '. ' . getline(line))
      let i+=1
    endfor
  endif
endfunction

command! -nargs=0 -range=% Mol :<line1>,<line2>call ToOrderList()

function! s:clearLineBreak() range
  let m = visualmode()
  if m ==# 'V'
    for line in range(a:firstline, a:lastline)
      call setline(line, substitute(getline(line), ' *$', '', ''))
    endfor
  endif
endfunction

command! -nargs=0 -range=% Mnobr :<line1>,<line2>call s:clearLineBreak()

function! PubDoc(...)
  let args = join(a:000, " ")
  echo system('pubdoc ' . args . " ". expand('%') )
endfunction

command! -buffer -nargs=* PubDoc call PubDoc(<q-args>)
