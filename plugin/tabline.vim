"TODO 
"debounce

if exists('g:tabline_loaded')
    finish
endif
let g:tabline_loaded = 1
let t:windowbuffers = []
let g:tabnames = {}

function! tabline#sum(list, func)
    let l:out = 0
    for l:item in a:list
        let l:out += a:func(l:item)
    endfor
    return l:out
endfunction

function! tabline#maxwidth(list, tabwidth, curwidth)
    let l:length = len(a:list)
    if l:length <= 1
        return 0
    endif
    let l:maxwidth = float2nr((&columns - a:tabwidth - a:curwidth) / (l:length - 1))
    let Lessthanmax = {val -> l:maxwidth - strdisplaywidth(val.label)}
    let l:extra = map(copy(a:list), {i, val -> Lessthanmax(val) >= 0 ? Lessthanmax(val) : 0})
    return l:maxwidth + float2nr(tabline#sum(l:extra, {item -> item}) / (l:length - 1))
endfunction

function! tabline#createstring(list, maxwidth)
    return join(map(a:list, {index, val -> printf("%%#TabLine%s#%%%s(%s%%) ",
        \ strtrans(v:val.hilite), val.hilite ==# "Current" ? '' : '.' . strtrans(a:maxwidth), strtrans(v:val.label)
    \ )}),'')
endfunction

function! tabline#createlist(range, current, curlabelfunc, labelfunc, activefunc)
    return map(a:range, {index, val -> a:current == val ?
        \ { 'label': a:curlabelfunc(val), 'hilite': 'Current' } :
        \ { 'label': a:labelfunc(val), 'hilite' : a:activefunc(val) ? 'Active' : 'Hidden' }
    \ })
endfunction

function! tabline#bufname(buf)
    let l:name = fnamemodify(expand(bufname(a:buf)), ':t')
    return l:name !=# '' ? l:name : '[No Name] '
endfunction

function! tabline#render()
    let TabName = {val -> index(keys(g:tabnames), strtrans(val)) > -1 ? ' ' . g:tabnames[val] : ' ' . strtrans(val)}
    let l:bufferlist = tabline#createlist(
        \ copy(t:windowbuffers),
        \ winbufnr(0),
        \ {val -> tabline#bufname(val)},
        \ {val -> tabline#bufname(val)},
        \ {val -> bufwinnr(val) > 0})
    let l:tablist = tabline#createlist(
        \ range(1,tabpagenr('$')),
        \ tabpagenr(),
        \ {val -> TabName(val)},
        \ {val -> TabName(val)},
        \ {-> 0})
    let l:maxwidth = tabline#maxwidth(
        \ l:bufferlist,
        \ tabline#sum(l:tablist, {item -> strdisplaywidth(item.label)}),
        \ strdisplaywidth(tabline#bufname(winbufnr(0))))
    let l:out = ' ' . tabline#createstring(l:bufferlist, l:maxwidth) . '%=' . tabline#createstring(l:tablist, &columns) . ' '
    return l:out
endfunction

function! tabline#init()
    let t:windowbuffers = range(1, bufnr('$'))
    set tabline=%!tabline#render()
endfunction

function! tabline#addbuffer(buf)
    if count(t:windowbuffers, a:buf) == 0
        let t:windowbuffers += [a:buf]
    endif
endfunction

function! tabline#jumptobuffer(dir)
    let l:next = index(t:windowbuffers, bufnr('%')) + len(t:windowbuffers) + a:dir
    if len(t:windowbuffers) > 0
        let l:bufnum = t:windowbuffers[l:next % len(t:windowbuffers)]
        exe ':buffer' . strtrans(l:bufnum)
    endif
endfunction

function! tabline#renamecurtab(tabname)
    let g:tabnames[strtrans(tabpagenr())] = a:tabname
	redrawtabline
endfunction

function! tabline#deletebuffer(buffer)
    let t:windowbuffers = filter(t:windowbuffers, {index, val -> val !=# a:buffer})
endfunction

augroup TabLine
    autocmd!
    autocmd VimEnter * call tabline#init()
    autocmd TabNew * let t:windowbuffers = [str2nr(expand('<abuf>'))]
    autocmd BufEnter * call tabline#addbuffer(str2nr(expand('<abuf>')))
    autocmd BufDelete,BufWipeout * call tabline#deletebuffer(str2nr(expand('<abuf>')))
augroup END

command! TablineNextBuffer :call tabline#jumptobuffer(1)
command! TablinePrevBuffer :call tabline#jumptobuffer(-1)
command! TablineDeleBuffer :call tabline#deletebuffer(bufnr('%'))
command! -nargs=1 TablineRenameTab :call tabline#renamecurtab(<args>)

set showtabline=2

hi default link TabLineCurrent TabLineSel
hi default link TabLineActive  PmenuSel
hi default link TabLineHidden  TabLine
