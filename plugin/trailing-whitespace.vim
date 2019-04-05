if exists('loaded_trailing_whitespace_plugin') | finish | endif
let loaded_trailing_whitespace_plugin = 1

if !exists('g:extra_whitespace_ignored_filetypes')
    let g:extra_whitespace_ignored_filetypes = []
endif
if !exists('g:extra_whitespace_ignored_file_patterns')
  let g:extra_whitespace_ignored_file_patterns = []
endif

function! s:has_filetype(filetype)
  return index(split(&filetype, '\.'), a:filetype) != -1
endfunction

function! ShouldMatchWhitespace()
  if has_key(b:, 'auto_fix_whitespace')
    return b:auto_fix_whitespace
  endif
  for ft in g:extra_whitespace_ignored_filetypes
    if s:has_filetype(ft)
      return 0
    endif
  endfor
  for pat in g:extra_whitespace_ignored_file_patterns
    if @% =~ pat
      return 0
    endif
  endfor
  return 1
endfunction

" Highlight EOL whitespace, http://vim.wikia.com/wiki/Highlight_unwanted_spaces
highlight default ExtraWhitespace ctermbg=grey guibg=grey
autocmd ColorScheme * highlight default ExtraWhitespace ctermbg=grey guibg=grey
autocmd BufRead,BufNew * if ShouldMatchWhitespace() | match ExtraWhitespace /\\\@<![\u3000[:space:]]\+$/ | else | match ExtraWhitespace /^^/ | endif

" The above flashes annoyingly while typing, be calmer in insert mode
autocmd InsertLeave * if ShouldMatchWhitespace() | match ExtraWhitespace /\\\@<![\u3000[:space:]]\+$/ | endif
autocmd InsertEnter * if ShouldMatchWhitespace() | match ExtraWhitespace /\\\@<![\u3000[:space:]]\+\%#\@<!$/ | endif

function! s:FixWhitespace(line1,line2)
    let l:save_cursor = getpos(".")
    silent! execute ':' . a:line1 . ',' . a:line2 . 's/\\\@<!\s\+$//'
    call setpos('.', l:save_cursor)
endfunction

" Run :FixWhitespace to remove end of line white space
command! -range=% FixWhitespace call <SID>FixWhitespace(<line1>,<line2>)
