" Vim syntax file
" Language:		shell (sh) Korn shell (ksh) bash (sh)
" Maintainer:		This runtime file is looking for a new maintainer.
" Previous Maintainers:	Charles E. Campbell
" 		Lennart Schultz <Lennart.Schultz@ecmwf.int>
" Last Change:		2024 Mar 04 by Vim Project {{{1
"		2024 Nov 03 by Aliaksei Budavei <0x000c70 AT gmail DOT com> (improved bracket expressions, #15941)
"		2025 Jan 06 add $PS0 to bashSpecialVariables (#16394)
"		2025 Jan 18 add bash coproc, remove duplicate syn keywords (#16467)
"		2025 Mar 21 update shell capability detection (#16939)
"		2025 Apr 03 command substitution opening paren at EOL (#17026)
"		2025 Apr 10 improve shell detection (#17084)
"		2025 Apr 29 match escaped chars in test operands (#17221)
"		2025 May 06 improve single-quote string matching in parameter expansions
"		2025 May 06 match KornShell compound arrays
"		2025 May 10 improve wildcard character class lists
"		2025 May 21 improve supported KornShell features
"		2025 Jun 16 change how sh_fold_enabled is reset (#17557)
"		2025 Jul 18 properly delete :commands #17785
" }}}
" Version:		208
" Former URL:		http://www.drchip.org/astronaut/vim/index.html#SYNTAX_SH
" For options and settings, please use:      :help ft-sh-syntax
" This file includes many ideas from Eric Brunet (eric.brunet@ens.fr) and heredoc fixes from Felipe Contreras

" quit when a syntax file was already loaded {{{1
if exists("b:current_syntax")
  finish
endif

" Ensure this is set unless we find another shell
let b:is_sh = 1

" If the shell script itself specifies which shell to use, use it
let s:shebang = getline(1)

if s:shebang =~ '^#!.\{-2,}\<ksh\>'
  " The binary is too ambiguous (i.e. '/bin/ksh' or some such).
 let b:is_kornshell = 1
 let b:generic_korn = 1
elseif s:shebang =~ '^#!.\{-2,}\<ksh93u\+\>'
 " ksh93u+ (or 93u-) release (still much too common to encounter)
 let b:is_kornshell = 1
 let b:is_ksh93u = 1
elseif s:shebang =~ '^#!.\{-2,}\<ksh93v\>'
 " ksh93v- alpha or beta
 let b:is_kornshell = 1
 let b:is_ksh93v = 1
elseif s:shebang =~ '^#!.\{-2,}\<ksh93\>'
 " Could be any ksh93 release
 let b:is_kornshell = 1
 let b:is_ksh93 = 1
elseif s:shebang =~ '^#!.\{-2,}\<ksh2020\>'
 let b:is_kornshell = 1
 let b:is_ksh2020 = 1
elseif s:shebang =~ '^#!.\{-2,}\<ksh88\>'
 " The actual AT&T ksh88 and its feature set is assumed.
 let b:is_kornshell = 1
 let b:is_ksh88 = 1
elseif s:shebang =~ '^#!.\{-2,}\<mksh\>'
 " MirBSD Korn Shell
 let b:is_kornshell = 1
 let b:is_mksh = 1
elseif s:shebang =~ '^#!.\{-2,}\<bash\>'
 let b:is_bash      = 1
elseif s:shebang =~ '^#!.\{-2,}\<dash\>'
 let b:is_dash      = 1
" handling /bin/sh with is_kornshell/is_sh {{{1
" b:is_sh will be set when "#! /bin/sh" is found;
" However, it often is just a masquerade by bash (typically Linux)
" or kornshell (typically workstations with Posix "sh").
" So, when the user sets "g:is_kornshell", "g:is_bash",
" "g:is_posix" or "g:is_dash", a b:is_sh is converted into
" b:is_kornshell/b:is_bash/b:is_posix/b:is_dash, respectively.
elseif !exists("b:is_kornshell") && !exists("b:is_bash") && !exists("b:is_posix") && !exists("b:is_dash")
 if exists("g:is_kornshell")
  let b:is_kornshell= 1
  let b:generic_korn = 1
 elseif exists("g:is_bash")
  let b:is_bash= 1
 elseif exists("g:is_dash")
  let b:is_dash= 1
 elseif exists("g:is_posix")
  let b:is_posix= 1
 elseif exists("g:is_sh")
  let b:is_sh= 1
 else
  " user did not specify which shell to use, and
  " the script itself does not specify which shell to use. FYI: /bin/sh is ambiguous.
  " Assuming /bin/sh is executable, and if its a link, find out what it links to.
  let s:shell = ""
  if executable("/bin/sh")
   let s:shell = resolve("/bin/sh")
  elseif executable("/usr/bin/sh")
   let s:shell = resolve("/usr/bin/sh")
  endif
  if s:shell =~ '\<ksh\>'
   " The binary is too ambiguous (i.e. '/bin/ksh' or some such).
   let b:is_kornshell = 1
   let b:generic_korn = 1
  elseif s:shell =~ '\<ksh93u\+\>'
   " ksh93u+ (or 93u-) release (still much too common to encounter)
   let b:is_kornshell = 1
   let b:is_ksh93u = 1
  elseif s:shell =~ '\<ksh93v\>'
   " ksh93v- alpha or beta
   let b:is_kornshell = 1
   let b:is_ksh93v = 1
  elseif s:shell =~ '\<ksh93\>'
   " Could be any ksh93 release
   let b:is_kornshell = 1
   let b:is_ksh93 = 1
  elseif s:shebang =~ '\<ksh2020\>'
   let b:is_kornshell = 1
   let b:is_ksh2020 = 1
  elseif s:shell =~ '\<ksh88\>'
   " The actual AT&T ksh88 and its feature set is assumed.
   let b:is_kornshell = 1
   let b:is_ksh88 = 1
  elseif s:shell =~ '\<mksh\>'
   " MirBSD Korn Shell
   let b:is_kornshell = 1
   let b:is_mksh = 1
  elseif s:shell =~ '\<bash\>'
   let b:is_bash = 1
  elseif s:shell =~ '\<dash\>'
   let b:is_dash = 1
  else
   let b:is_posix = 1
  endif
  unlet s:shell
 endif
endif

unlet s:shebang

" if b:is_dash, set b:is_posix too
if exists("b:is_dash")
 let b:is_posix= 1
endif

if exists("b:is_kornshell") || exists("b:is_bash")
 if exists("b:is_sh")
  unlet b:is_sh
 endif
endif

" set up default g:sh_fold_enabled {{{1
" ================================
if !exists("g:sh_fold_enabled")
 let g:sh_fold_enabled= 0
elseif g:sh_fold_enabled != 0 && !has("folding")
 echomsg "Ignoring g:sh_fold_enabled=".g:sh_fold_enabled."; need to re-compile vim for +fold support"
 let g:sh_fold_enabled= 0
endif
let s:sh_fold_functions= and(g:sh_fold_enabled,1)
let s:sh_fold_heredoc  = and(g:sh_fold_enabled,2)
let s:sh_fold_ifdofor  = and(g:sh_fold_enabled,4)
if g:sh_fold_enabled && &fdm == "manual"
 " Given that	the	user provided g:sh_fold_enabled
 " 	AND	g:sh_fold_enabled is manual (usual default)
 " 	implies	a desire for syntax-based folding
 setl fdm=syntax
endif

" set up the syntax-highlighting for iskeyword
if (v:version == 704 && has("patch-7.4.1142")) || v:version > 704
 if !exists("g:sh_syntax_isk") || (exists("g:sh_syntax_isk") && g:sh_syntax_isk)
  if exists("b:is_bash")
   exe "syn iskeyword ".&iskeyword.",-,:"
  else
   exe "syn iskeyword ".&iskeyword.",-"
  endif
 endif
endif

" Set up folding commands for shell {{{1
" =================================
if exists(":ShFoldFunctions") == 2
  delc ShFoldFunctions
endif
if exists(":ShFoldIfHereDoc") == 2
  delc ShFoldHereDoc
endif
if exists(":ShFoldIfDoFor") == 2
  delc ShFoldIfDoFor
endif
if s:sh_fold_functions
 com! -nargs=* ShFoldFunctions <args> fold
else
 com! -nargs=* ShFoldFunctions <args>
endif
if s:sh_fold_heredoc
 com! -nargs=* ShFoldHereDoc <args> fold
else
 com! -nargs=* ShFoldHereDoc <args>
endif
if s:sh_fold_ifdofor
 com! -nargs=* ShFoldIfDoFor <args> fold
else
 com! -nargs=* ShFoldIfDoFor <args>
endif

" Generate bracket expression items {{{1
" =================================
" Note that the following function can be invoked as many times as necessary
" provided that these constraints hold for the passed dictionary argument:
" - every time a unique group-name value is assigned to the "itemGroup" key;
" - only ONCE either the "extraArgs" key is not entered or it is entered and
"   its value does not have "contained" among other optional arguments (":help
"   :syn-arguments").
fun! s:GenerateBracketExpressionItems(dict) abort
 let itemGroup = a:dict.itemGroup
 let bracketGroup = a:dict.bracketGroup
 let invGroup = itemGroup . 'Inv'
 let skipLeftBracketGroup = itemGroup . 'SkipLeftBracket'
 let skipRightBracketGroup = itemGroup . 'SkipRightBracket'
 let extraArgs = has_key(a:dict, 'extraArgs') ? a:dict.extraArgs : ''

 " Make the leading "[!^]" stand out in a NON-matching expression.
 exec 'syn match ' . invGroup . ' contained "\[\@<=[!^]"'

 " Set up indirections for unbalanced-bracket highlighting.
 exec 'syn region ' . skipRightBracketGroup . ' contained matchgroup=' . bracketGroup . ' start="\[\%([!^]\=\\\=\]\)\@=" matchgroup=shCollSymb end="\[\.[^]]\{-}\][^]]\{-}\.\]" matchgroup=' . itemGroup . ' end="\]" contains=@shBracketExprList,shDoubleQuote,' . invGroup
 exec 'syn region ' . skipLeftBracketGroup . ' contained matchgroup=' . bracketGroup . ' start="\[\%([!^]\=\\\=\]\)\@=" skip="[!^]\=\\\=\]\%(\[[^]]\+\]\|[^]]\)\{-}\%(\[[:.=]\@!\)\@=" matchgroup=' . itemGroup . ' end="\[[:.=]\@!" contains=@shBracketExprList,shDoubleQuote,' . invGroup

 " Look for a general matching expression.
 exec 'syn region ' . itemGroup . ' matchgroup=' . bracketGroup . ' start="\[\S\@=" end="\]" contains=@shBracketExprList,shDoubleQuote ' . extraArgs
 " Look for a general NON-matching expression.
 exec 'syn region ' . itemGroup . ' matchgroup=' . bracketGroup . ' start="\[[!^]\@=" end="\]" contains=@shBracketExprList,shDoubleQuote,' . invGroup . ' ' . extraArgs

 " Accommodate unbalanced brackets in bracket expressions.  The supported
 " syntax for a plain "]" can be: "[]ws]" and "[^]ws]"; or, "[ws[.xs]ys.]zs]"
 " and "[^ws[.xs]ys.]zs]"; see §9.3.5 RE Bracket Expression (in XBD).
 exec 'syn region ' . itemGroup . ' matchgroup=NONE start="\[[!^]\=\\\=\]" matchgroup=' . bracketGroup . ' end="\]" contains=@shBracketExprList,shDoubleQuote,' . skipRightBracketGroup . ' ' . extraArgs
 " Strive to handle "[]...[]" etc.
 exec 'syn region ' . itemGroup . ' matchgroup=NONE start="\[[!^]\=\\\=\]\%(\[[^]]\+\]\|[^]]\)\{-}\[[:.=]\@!" matchgroup=' . bracketGroup . ' end="\]" contains=@shBracketExprList,shDoubleQuote,' . skipLeftBracketGroup . ' ' . extraArgs

 if !exists("g:skip_sh_syntax_inits")
  exec 'hi def link ' . skipLeftBracketGroup . ' ' . itemGroup
  exec 'hi def link ' . skipRightBracketGroup . ' ' . itemGroup
  exec 'hi def link ' . invGroup . ' Underlined'
 endif
endfun

call s:GenerateBracketExpressionItems({'itemGroup': 'shBracketExpr', 'bracketGroup': 'shBracketExprDelim'})

" sh syntax is case sensitive {{{1
syn case match

" Clusters: contains=@... clusters {{{1
"==================================
syn cluster shErrorList	contains=shDoError,shIfError,shInError,shCaseError,shEsacError,shCurlyError,shParenError,shTestError,shOK
if exists("b:is_kornshell") || exists("b:is_bash")
 syn cluster ErrorList add=shDTestError
endif
syn cluster shArithParenList	contains=shArithmetic,shArithParen,shCaseEsac,shComment,shDeref,shDerefVarArray,shDo,shDerefSimple,shEcho,shEscape,shExpr,shNumber,shOperator,shPosnParm,shExSingleQuote,shExDoubleQuote,shHereString,shRedir,shSingleQuote,shDoubleQuote,shStatement,shVariable,shAlias,shTest,shCtrlSeq,shSpecial,shParen,bashSpecialVariables,bashStatement,shIf,shFor,shFunctionKey,shFunctionOne,shFunctionTwo
syn cluster shArithList	contains=@shArithParenList,shParenError
syn cluster shBracketExprList	contains=shCharClassOther,shCharClass,shCollSymb,shEqClass
syn cluster shCaseEsacList	contains=shCaseStart,shCaseLabel,shCase,shCaseBar,shCaseIn,shComment,shDeref,shDerefSimple,shCaseCommandSub,shCaseExSingleQuote,shCaseSingleQuote,shCaseDoubleQuote,shCtrlSeq,@shErrorList,shStringSpecial,shCaseRange
syn cluster shCaseList	contains=@shCommandSubList,shCaseEsac,shColon,shCommandSub,shCommandSubBQ,shSubshare,shValsub,shComment,shDblBrace,shDo,shEcho,shExpr,shFor,shHereDoc,shIf,shHereString,shRedir,shSetList,shSource,shStatement,shVariable,shCtrlSeq
if exists("b:is_kornshell") || exists("b:is_bash")
 syn cluster shCaseList	add=shForPP,shDblParen
endif
syn cluster shCommandSubList	contains=shAlias,shArithmetic,shBracketExpr,shCmdParenRegion,shCommandSub,shComment,shCtrlSeq,shDeref,shDerefSimple,shDoubleQuote,shEcho,shEscape,shExDoubleQuote,shExpr,shExSingleQuote,shHereDoc,shNumber,shOperator,shOption,shPosnParm,shHereString,shRedir,shSingleQuote,shSpecial,shStatement,shSubSh,shTest,shVariable
syn cluster shCurlyList	contains=shNumber,shComma,shDeref,shDerefSimple,shDerefSpecial
" COMBAK: removing shEscape from shDblQuoteList fails ksh04:43 -- Jun 09, 2022: I don't see the problem with ksh04, so am reinstating shEscape
syn cluster shDblQuoteList	contains=shArithmetic,shCommandSub,shCommandSubBQ,shSubshare,shValsub,shDeref,shDerefSimple,shEscape,shPosnParm,shCtrlSeq,shSpecial,shSpecialDQ
syn cluster shDerefList	contains=shDeref,shDerefSimple,shDerefVar,shDerefSpecial,shDerefWordError,shDerefPSR,shDerefPPS
syn cluster shDerefVarList	contains=shDerefOffset,shDerefOp,shDerefVarArray,shDerefOpError
syn cluster shEchoList	contains=shArithmetic,shBracketExpr,shCommandSub,shCommandSubBQ,shDerefVarArray,shSubshare,shValsub,shDeref,shDerefSimple,shEscape,shExSingleQuote,shExDoubleQuote,shSingleQuote,shDoubleQuote,shCtrlSeq,shEchoQuote
syn cluster shExprList1	contains=shBracketExpr,shNumber,shOperator,shExSingleQuote,shExDoubleQuote,shSingleQuote,shDoubleQuote,shExpr,shDblBrace,shDeref,shDerefSimple,shCtrlSeq
syn cluster shExprList2	contains=@shExprList1,@shCaseList,shTest
syn cluster shFunctionList	contains=shBracketExpr,@shCommandSubList,shCaseEsac,shColon,shComment,shDo,shEcho,shExpr,shFor,shHereDoc,shIf,shOption,shHereString,shRedir,shSetList,shSource,shStatement,shVariable,shOperator,shCtrlSeq
if exists("b:is_kornshell") || exists("b:is_bash")
 syn cluster shFunctionList	add=shRepeat,shDblBrace,shDblParen,shForPP
 syn cluster shDerefList	add=shCommandSubList,shEchoDeref
endif
syn cluster shHereBeginList	contains=@shCommandSubList
syn cluster shHereList	contains=shBeginHere,shHerePayload
syn cluster shHereListDQ	contains=shBeginHere,@shDblQuoteList,shHerePayload
syn cluster shIdList	contains=shArithmetic,shCommandSub,shCommandSubBQ,shDerefVarArray,shSubshare,shValsub,shWrapLineOperator,shSetOption,shComment,shDeref,shDerefSimple,shHereString,shNumber,shOperator,shRedir,shExSingleQuote,shExDoubleQuote,shSingleQuote,shDoubleQuote,shExpr,shCtrlSeq,shStringSpecial,shAtExpr
syn cluster shIfList	contains=@shLoopList,shDblBrace,shDblParen,shFunctionKey,shFunctionOne,shFunctionTwo
syn cluster shLoopList	contains=@shCaseList,@shErrorList,shCaseEsac,shConditional,shDblBrace,shExpr,shFor,shIf,shOption,shSet,shTest,shTestOpr,shTouch
if exists("b:is_kornshell") || exists("b:is_bash")
 syn cluster shLoopList	add=shForPP,shDblParen
endif
syn cluster shPPSLeftList	contains=shAlias,shArithmetic,shBracketExpr,shCmdParenRegion,shCommandSub,shSubshare,shValsub,shCtrlSeq,shDeref,shDerefSimple,shDoubleQuote,shEcho,shEscape,shExDoubleQuote,shExpr,shExSingleQuote,shHereDoc,shNumber,shOperator,shOption,shPosnParm,shHereString,shRedir,shSingleQuote,shSpecial,shStatement,shSubSh,shTest,shVariable
syn cluster shPPSRightList	contains=shDeref,shDerefSimple,shEscape,shPosnParm
syn cluster shSubShList	contains=shBracketExpr,@shCommandSubList,shCommandSubBQ,shSubshare,shValsub,shCaseEsac,shColon,shCommandSub,shComment,shDo,shEcho,shExpr,shFor,shIf,shHereString,shRedir,shSetList,shSource,shStatement,shVariable,shCtrlSeq,shOperator
syn cluster shTestList	contains=shArithmetic,shBracketExpr,shCommandSub,shCommandSubBQ,shSubshare,shValsub,shCtrlSeq,shDeref,shDerefSimple,shDoubleQuote,shSpecialDQ,shExDoubleQuote,shExpr,shExSingleQuote,shNumber,shOperator,shSingleQuote,shTest,shTestOpr
syn cluster shNoZSList	contains=shSpecialNoZS
syn cluster shForList	contains=shTestOpr,shNumber,shDerefSimple,shDeref,shCommandSub,shCommandSubBQ,shSubshare,shValsub,shArithmetic

" Echo: {{{1
" ====
" This one is needed INSIDE a CommandSub, so that `echo bla` be correct
if (exists("b:is_kornshell") && !exists("b:is_ksh88"))
 syn region shEcho matchgroup=shStatement start="\<echo\>"  skip="\\$" matchgroup=shEchoDelim end="$" matchgroup=NONE end="[<>;&|()`}]"me=e-1 end="\d[<>]"me=e-2 end="#"me=e-1 end="\ze[ \t\n;]}" contains=@shEchoList skipwhite nextgroup=shQuickComment
 syn region shEcho matchgroup=shStatement start="\<print\>" skip="\\$" matchgroup=shEchoDelim end="$" matchgroup=NONE end="[<>;&|()`}]"me=e-1 end="\d[<>]"me=e-2 end="#"me=e-1 end="\ze[ \t\n;]}" contains=@shEchoList skipwhite nextgroup=shQuickComment
else
 syn region shEcho matchgroup=shStatement start="\<echo\>"  skip="\\$" matchgroup=shEchoDelim end="$" matchgroup=NONE end="[<>;&|()`]"me=e-1 end="\d[<>]"me=e-2 end="#"me=e-1 contains=@shEchoList skipwhite nextgroup=shQuickComment
 syn region shEcho matchgroup=shStatement start="\<print\>" skip="\\$" matchgroup=shEchoDelim end="$" matchgroup=NONE end="[<>;&|()`]"me=e-1 end="\d[<>]"me=e-2 end="#"me=e-1 contains=@shEchoList skipwhite nextgroup=shQuickComment
endif
if exists("b:is_kornshell") || exists("b:is_bash") || exists("b:is_posix")
 syn region shEchoDeref contained matchgroup=shStatement start="\<echo\>"  skip="\\$" matchgroup=shEchoDelim end="$" end="[<>;&|()`}]"me=e-1 end="\d[<>]"me=e-2 end="#"me=e-1 contains=@shEchoList skipwhite nextgroup=shQuickComment
 syn region shEchoDeref contained matchgroup=shStatement start="\<print\>" skip="\\$" matchgroup=shEchoDelim end="$" end="[<>;&|()`}]"me=e-1 end="\d[<>]"me=e-2 end="#"me=e-1 contains=@shEchoList skipwhite nextgroup=shQuickComment
endif
syn match  shEchoQuote contained	'\%(\\\\\)*\\["`'()]'

" This must be after the strings, so that ... \" will be correct
syn region shEmbeddedEcho contained matchgroup=shStatement start="\<print\>" skip="\\$" matchgroup=shEchoDelim end="$" matchgroup=NONE end="[<>;&|`)]"me=e-1 end="\d[<>]"me=e-2 end="\s#"me=e-2 contains=shBracketExpr,shNumber,shExSingleQuote,shSingleQuote,shDeref,shDerefSimple,shSpecialVar,shOperator,shExDoubleQuote,shDoubleQuote,shCtrlSeq

" Alias: {{{1
" =====
if exists("b:is_kornshell") || exists("b:is_bash") || exists("b:is_posix")
 syn match shStatement "\<alias\>"
 syn region shAlias matchgroup=shStatement start="\<alias\>\s\+\(\h[-._[:alnum:]]*\)\@="  skip="\\$" end="\>\|`"
 syn region shAlias matchgroup=shStatement start="\<alias\>\s\+\(\h[-._[:alnum:]]*=\)\@=" skip="\\$" end="="
" syn region shAlias matchgroup=shStatement start="\<alias\>\s\+\(\h[-._[:alnum:]]\+\)\@="  skip="\\$" end="\>\|`"
" syn region shAlias matchgroup=shStatement start="\<alias\>\s\+\(\h[-._[:alnum:]]\+=\)\@=" skip="\\$" end="="

 " Touch: {{{1
 " =====
 syn match shTouch	'\<touch\>[^;#]*'	skipwhite nextgroup=shComment contains=shTouchCmd,shDoubleQuote,shSingleQuote,shDeref,shDerefSimple
 syn match shTouchCmd	'\<touch\>'		contained
endif

" Error Codes: {{{1
" ============
if !exists("g:sh_no_error")
 syn match   shDoError "\<done\>"
 syn match   shIfError "\<fi\>"
 syn match   shInError "\<in\>"
 syn match   shCaseError ";;"
 syn match   shEsacError "\<esac\>"
 syn match   shCurlyError "}"
 syn match   shParenError ")"
 syn match   shOK	'\.\(done\|fi\|in\|esac\)'
 if exists("b:is_kornshell") || exists("b:is_bash")
  syn match     shDTestError "]]"
 endif
 syn match     shTestError "]"
endif

" Options: {{{1
" ====================
syn match   shOption	"\s\zs[-+][-_a-zA-Z#@]\+"
syn match   shOption	"\s\zs--[^ \t$=`'"|);]\+"

" File Redirection Highlighted As Operators: {{{1
"===========================================
syn match      shRedir	"\d\=>\(&[-0-9]\)\="
syn match      shRedir	"\d\=>>-\="
syn match      shRedir	"\d\=<\(&[-0-9]\)\="
syn match      shRedir	"\d<<-\="

" Operators: {{{1
" ==========
syn match   shOperator	"<<\|>>"		contained
syn match   shOperator	"[!&;|]"		contained
syn match   shOperator	"[-=/*+%]\=="		skipwhite nextgroup=shPattern
syn match   shPattern	"\<\S\+\())\)\@="	contained contains=shExSingleQuote,shSingleQuote,shExDoubleQuote,shDoubleQuote,shDeref

" Subshells: {{{1
" ==========
syn region shExpr  transparent matchgroup=shExprRegion  start="{" end="}"		contains=@shExprList2 nextgroup=shSpecialNxt
syn region shSubSh transparent matchgroup=shSubShRegion start="[^(]\zs(" end=")"	contains=@shSubShList nextgroup=shSpecialNxt

" Tests: {{{1
"=======
syn region shExpr	matchgroup=shRange start="\[\s\@=" skip=+\\\\\|\\$\|\[+ end="\]" contains=@shTestList,shSpecial
syn region shTest	transparent matchgroup=shStatement start="\<test\s" skip=+\\\\\|\\$+ matchgroup=NONE end="[;&|]"me=e-1 end="$" contains=@shExprList1
syn region shNoQuote	start='\S'	skip='\%(\\\\\)*\\.'	end='\ze\s' end="\ze['"]"	contained contains=shBracketExpr,shDerefSimple,shDeref,shEscape
syn match  shAstQuote	contained	'\*\ze"'	nextgroup=shString
syn match  shTestOpr	contained	'[^-+/%]\zs=' skipwhite nextgroup=shTestDoubleQuote,shTestSingleQuote,shTestPattern
syn match  shTestOpr	contained	"<=\|>=\|!=\|==\|=\~\|-.\>\|-\(nt\|ot\|ef\|eq\|ne\|lt\|le\|gt\|ge\)\>\|[!<>]"
syn match  shTestPattern	contained	'\w\+'
syn region shTestDoubleQuote	contained	start='\%(\%(\\\\\)*\\\)\@<!"' skip=+\\\\\|\\"+ end='"'	contains=shDeref,shDerefSimple,shDerefSpecial
syn match  shTestSingleQuote	contained	'\\.'	nextgroup=shTestSingleQuote
syn match  shTestSingleQuote	contained	"'[^']*'"
if exists("b:is_kornshell") || exists("b:is_bash")
 syn region  shDblBrace matchgroup=Delimiter start="\[\[\s\@="	skip=+\%(\\\\\)*\\$+ end="\]\]"	contains=@shTestList,shAstQuote,shNoQuote,shComment
 syn region  shDblParen matchgroup=Delimiter start="(("	skip=+\%(\\\\\)*\\$+ end="))"	contains=@shTestList,shComment
endif

" Character Class In Range: {{{1
" =========================
syn match   shCharClassOther	contained	"\[:\w\{-}:\]"
syn match   shCharClass	contained	"\[:\%(alnum\|alpha\|blank\|cntrl\|digit\|graph\|lower\|print\|punct\|space\|upper\|xdigit\):\]"
syn match   shCollSymb	contained	"\[\..\{-}\.\]"
syn match   shEqClass	contained	"\[=.\{-}=\]"

" Loops: do, if, while, until {{{1
" ======
ShFoldIfDoFor syn region shDo	transparent	matchgroup=shConditional start="\<do\>" matchgroup=shConditional end="\<done\>"			contains=@shLoopList
ShFoldIfDoFor syn region shIf	transparent	matchgroup=shConditional start="\<if\_s" matchgroup=shConditional skip=+-fi\>+ end="\<;\_s*then\>" end="\<fi\>"	contains=@shIfList
ShFoldIfDoFor syn region shFor		matchgroup=shLoop start="\<for\ze\_s\s*\%(((\)\@!" end="\<in\>" end="\<do\>"me=e-2			contains=@shLoopList,shDblParen skipwhite nextgroup=shCurlyIn
if exists("b:is_kornshell") || exists("b:is_bash")
 ShFoldIfDoFor syn region shForPP	matchgroup=shLoop start='\<for\>\_s*((' end='))' contains=@shForList
endif

if exists("b:is_kornshell") || exists("b:is_bash") || exists("b:is_posix")
 syn cluster shCaseList	add=shRepeat
 syn cluster shFunctionList	add=shRepeat
 syn region shRepeat   matchgroup=shLoop   start="\<while\_s" end="\<do\>"me=e-2	contains=@shLoopList,shDblParen,shDblBrace
 syn region shRepeat   matchgroup=shLoop   start="\<until\_s" end="\<do\>"me=e-2	contains=@shLoopList,shDblParen,shDblBrace
 if !exists("b:is_posix")
  syn region shCaseEsac matchgroup=shConditional start="\<select\s" matchgroup=shConditional end="\<in\>" end="\<do\>" contains=@shLoopList
 endif
else
 syn region shRepeat   matchgroup=shLoop   start="\<while\_s" end="\<do\>"me=e-2		contains=@shLoopList
 syn region shRepeat   matchgroup=shLoop   start="\<until\_s" end="\<do\>"me=e-2		contains=@shLoopList
endif
syn region shCurlyIn   contained	matchgroup=Delimiter start="{" end="}" contains=@shCurlyList
syn match  shComma     contained	","

" Case: case...esac {{{1
" ====
syn match shCaseBar	contained skipwhite "\(^\|[^\\]\)\(\\\\\)*\zs|"		nextgroup=shCase,shCaseStart,shCaseBar,shComment,shCaseExSingleQuote,shCaseSingleQuote,shCaseDoubleQuote
syn match shCaseStart	contained skipwhite skipnl "("			nextgroup=shCase,shCaseBar
syn match shCaseLabel	contained skipwhite	"\%(\\.\|[-a-zA-Z0-9_*.]\)\+"	contains=shBracketExpr
if exists("b:is_bash") || (exists("b:is_kornshell") && !exists("b:is_ksh88") && !exists("b:is_ksh93u") && !exists("b:is_ksh93v") && !exists("b:is_ksh2020"))
 ShFoldIfDoFor syn region	shCase	contained skipwhite skipnl matchgroup=shSnglCase start="\%(\\.\|[^#$()'" \t]\)\{-}\zs)"  end=";;" end=";&" end=";;&" end="esac"me=s-1	contains=@shCaseList	nextgroup=shCaseStart,shCase,shComment
elseif exists("b:is_kornshell")
 ShFoldIfDoFor syn region	shCase	contained skipwhite skipnl matchgroup=shSnglCase start="\%(\\.\|[^#$()'" \t]\)\{-}\zs)"  end=";;" end=";&" end="esac"me=s-1	contains=@shCaseList	nextgroup=shCaseStart,shCase,shComment
else
 ShFoldIfDoFor syn region	shCase	contained skipwhite skipnl matchgroup=shSnglCase start="\%(\\.\|[^#$()'" \t]\)\{-}\zs)"  end=";;" end="esac"me=s-1		contains=@shCaseList	nextgroup=shCaseStart,shCase,shComment
endif
ShFoldIfDoFor syn region	shCaseEsac	matchgroup=shConditional start="\<case\>" end="\<esac\>"	contains=@shCaseEsacList

syn keyword shCaseIn	contained skipwhite skipnl in			nextgroup=shCase,shCaseStart,shCaseBar,shComment,shCaseExSingleQuote,shCaseSingleQuote,shCaseDoubleQuote
if exists("b:is_bash") || (exists("b:is_kornshell") && !exists("b:is_ksh88"))
 syn region  shCaseExSingleQuote	matchgroup=shQuote start=+\$'+ skip=+\\\\\|\\.+ end=+'+	contains=shStringSpecial,shSpecial	skipwhite skipnl nextgroup=shCaseBar	contained
elseif !exists("g:sh_no_error")
 syn region  shCaseExSingleQuote	matchgroup=Error start=+\$'+ skip=+\\\\\|\\.+ end=+'+	contains=shStringSpecial	skipwhite skipnl nextgroup=shCaseBar	contained
endif
syn region  shCaseSingleQuote	matchgroup=shQuote start=+'+ end=+'+		contains=shStringSpecial		skipwhite skipnl nextgroup=shCaseBar	contained
syn region  shCaseDoubleQuote	matchgroup=shQuote start=+"+ skip=+\\\\\|\\.+ end=+"+	contains=@shDblQuoteList,shStringSpecial	skipwhite skipnl nextgroup=shCaseBar	contained
syn region  shCaseCommandSub	start=+`+ skip=+\\\\\|\\.+ end=+`+		contains=@shCommandSubList		skipwhite skipnl nextgroup=shCaseBar	contained
call s:GenerateBracketExpressionItems({'itemGroup': 'shCaseRange', 'bracketGroup': 'shBracketExprDelim', 'extraArgs': 'skip=+\\\\+ contained'})
if exists("b:is_bash")
 syn match   shCharClass	"\[:\%(alnum\|alpha\|ascii\|blank\|cntrl\|digit\|graph\|lower\|print\|punct\|space\|upper\|word\|xdigit\):\]"	contained
elseif exists("b:is_kornshell")
 syn match   shCharClass	"\[:\%(alnum\|alpha\|blank\|cntrl\|digit\|graph\|lower\|print\|punct\|space\|upper\|word\|xdigit\):\]"	contained
endif
" Misc: {{{1
"======
syn match   shWrapLineOperator "\\$"
syn region  shCommandSubBQ   	start="`" skip="\\\\\|\\." end="`"	contains=shBQComment,@shCommandSubList
"COMBAK: see ksh13:50
"syn match   shEscape	contained	'\%(^\)\@!\%(\\\\\)*\\.'	nextgroup=shSingleQuote,shDoubleQuote,shComment
"COMBAK: see sh11:27
syn match   shEscape	contained	'\%(^\)\@!\%(\\\\\)*\\.'	nextgroup=shComment
"COMBAK: see ksh13:53
"syn match   shEscape	contained	'\%(^\)\@!\%(\\\\\)*\\.'

" $() and $(()): {{{1
" $(..) is not supported by sh (Bourne shell).  However, apparently
" some systems (HP?) have as their /bin/sh a (link to) Korn shell
" (ie. Posix compliant shell).  /bin/ksh should work for those
" systems too, however, so the following syntax will flag $(..) as
" an Error under /bin/sh.  By consensus of vimdev'ers!
if exists("b:is_kornshell") || exists("b:is_bash") || exists("b:is_posix")
 syn region shCommandSub matchgroup=shCmdSubRegion start="\$((\@!"  skip='\\\\\|\\.' end=")"  contains=@shCommandSubList
 if exists("b:is_kornshell")
  if !exists("b:is_ksh88")
   if exists("b:is_mksh")
    syn region shSubshare matchgroup=shCmdSubRegion start="\${\ze[ \t\n]"  skip='\\\\\|\\.' end="\zs[ \t\n;]}"  contains=@shCommandSubList
   else
    syn region shSubshare matchgroup=shCmdSubRegion start="\${\ze[ \t\n<]"  skip='\\\\\|\\.' end="\zs[ \t\n;]}"  contains=@shCommandSubList
   endif
  endif
  if exists("b:is_mksh") || exists("b:generic_korn")
   syn region shValsub matchgroup=shCmdSubRegion start="\${|"  skip='\\\\\|\\.' end="}"  contains=@shCommandSubList
  endif
 endif
 syn region shArithmetic matchgroup=shArithRegion  start="\$((" skip='\\\\\|\\.' end="))" contains=@shArithList
 syn region shArithmetic matchgroup=shArithRegion  start="\$\[" skip='\\\\\|\\.' end="\]" contains=@shArithList
 syn match  shSkipInitWS contained	"^\s\+"
 syn region shArithParen matchgroup=shArithRegion  contained start="(" end=")" contains=@shArithParenList
elseif !exists("g:sh_no_error")
 syn region shCommandSub matchgroup=Error start="\$(" end=")" contains=@shCommandSubList
endif
syn region shCmdParenRegion matchgroup=shCmdSubRegion start="((\@!" skip='\\\\\|\\.' end=")" contains=@shCommandSubList

if exists("b:is_bash")
 syn cluster shCommandSubList add=bashSpecialVariables,bashStatement
 syn cluster shCaseList add=bashAdminStatement,bashStatement
 syn keyword bashSpecialVariables contained auto_resume BASH BASH_ALIASES BASH_ARGC BASH_ARGV BASH_CMDS BASH_COMMAND BASH_ENV BASH_EXECUTION_STRING BASH_LINENO BASHOPTS BASHPID BASH_REMATCH BASH_SOURCE BASH_SUBSHELL BASH_VERSINFO BASH_VERSION BASH_XTRACEFD CDPATH COLUMNS COMP_CWORD COMP_KEY COMP_LINE COMP_POINT COMPREPLY COMP_TYPE COMP_WORDBREAKS COMP_WORDS COPROC COPROC_PID DIRSTACK EMACS ENV EUID FCEDIT FIGNORE FUNCNAME FUNCNEST GLOBIGNORE GROUPS histchars HISTCMD HISTCONTROL HISTFILE HISTFILESIZE HISTIGNORE HISTSIZE HISTTIMEFORMAT HOME HOSTFILE HOSTNAME HOSTTYPE IFS IGNOREEOF INPUTRC LANG LC_ALL LC_COLLATE LC_CTYPE LC_MESSAGES LC_NUMERIC LINENO LINES MACHTYPE MAIL MAILCHECK MAILPATH MAPFILE OLDPWD OPTARG OPTERR OPTIND OSTYPE PATH PIPESTATUS POSIXLY_CORRECT PPID PROMPT_COMMAND PS0 PS1 PS2 PS3 PS4 PWD RANDOM READLINE_LINE READLINE_POINT REPLY SECONDS SHELL SHELLOPTS SHLVL TIMEFORMAT TIMEOUT TMPDIR UID
 syn keyword bashStatement basename cat chgrp chmod chown cksum clear cmp comm command compgen complete cp cut date dirname du egrep expr fgrep find fmt fold getconf gnufind gnugrep grep head iconv id join less ln logname ls md5sum mkdir mkfifo mknod mktemp mv od paste pathchk readlink realpath rev rm rmdir rpm sed sha1sum sha224sum sha256sum sha384sum sha512sum sleep sort strip stty sum sync tail tee tr tty uname uniq wc which xargs xgrep
 syn keyword bashAdminStatement daemon killall killproc nice reload restart start status stop
endif

if exists("b:is_kornshell") || exists("b:is_posix")
 syn cluster shCommandSubList add=kshSpecialVariables,kshStatement
 syn cluster shCaseList add=kshStatement
 syn keyword kshSpecialVariables contained CDPATH COLUMNS EDITOR ENV FCEDIT FIGNORE FPATH HISTCMD HISTEDIT HISTFILE HISTSIZE HOME IFS JOBMAX KSH_VERSION LANG LC_ALL LC_COLLATE LC_CTYPE LC_MESSAGES LC_NUMERIC LC_TIME LINENO LINES MAIL MAILCHECK MAILPATH OLDPWD OPTARG OPTIND PATH PPID PS1 PS2 PS3 PS4 PWD RANDOM REPLY SECONDS SHELL SHLVL TMOUT VISUAL
 syn keyword kshStatement basename cat chgrp chmod chown cksum clear cmp comm command cp cut date dirname du egrep expr fgrep find fmt fold grep head iconv id join killall less ln logname ls md5sum mkdir mknod mkfifo mktemp mv nice od paste pathchk printenv readlink realpath rev rm rmdir sed setgroups setsenv sha1sum sha224sum sha256sum sha384sum sha512sum sort strip stty sum sync tail tee tput tr tty uname uniq wc which xargs xgrep
 if exists("b:is_ksh88")
  syn keyword kshSpecialVariables contained ERRNO
 elseif exists("b:is_mksh")
  syn keyword kshSpecialVariables contained BASHPID EPOCHREALTIME EXECSHELL KSHEGID KSHGID KSHUID KSH_MATCH PATHSEP PGRP PIPESTATUS TMPDIR USER_ID
  syn keyword kshStatement bind rename
 elseif exists("b:is_ksh93v") || exists("b:is_ksh2020")
  syn keyword kshSpecialVariables contained SH_OPTIONS COMP_CWORD COMP_LINE COMP_POINT COMP_WORDS COMP_KEY COMPREPLY COMP_WORDBREAKS COMP_TYPE
  syn keyword kshStatement compgen complete
  if exists("b:is_ksh93v")
   syn keyword kshSpecialVariables contained VPATH CSWIDTH
   syn keyword kshStatement vmstate alarm fds pids poll sha2sum
  endif
 elseif exists("b:is_ksh93u")
  " ksh93u+
  syn keyword kshSpecialVariables contained VPATH CSWIDTH
  syn keyword kshStatement alarm fds pids vmstate
 else
  " 'ksh' is ambiguous; include everything
  syn keyword kshSpecialVariables contained BASHPID EPOCHREALTIME EXECSHELL KSHEGID KSHGID KSHUID KSH_MATCH PATHSEP PGRP PIPESTATUS TMPDIR USER_ID SH_OPTIONS COMP_CWORD COMP_LINE COMP_POINT COMP_WORDS COMP_KEY COMPREPLY COMP_WORDBREAKS COMP_TYPE VPATH SRANDOM CSWIDTH
  if !exists("b:is_ksh93")
   syn keyword kshSpecialVariables contained ERRNO
  endif
  syn keyword kshStatement vmstate alarm fds pids poll sha2sum alarm eloop fds mkservice pids compgen complete bind rename
 endif
endif

syn match   shSource	"^\.\s"
syn match   shSource	"\s\.\s"
"syn region  shColon	start="^\s*:" end="$" end="\s#"me=e-2 contains=@shColonList
"syn region  shColon	start="^\s*\zs:" end="$" end="\s#"me=e-2
if exists("b:is_kornshell") || exists("b:is_posix")
 syn match   shColon	'^\s*\zs:'
endif

" String And Character Constants: {{{1
"================================
syn match   shNumber	"\<\d\+\>#\="
syn match   shNumber	"\<-\=\.\=\d\+\>#\="
syn match   shCtrlSeq	"\\\d\d\d\|\\[abcfnrtv0]"			contained
if exists("b:is_bash") || exists("b:is_kornshell")
 syn match   shSpecial	"[^\\]\(\\\\\)*\zs\\\o\o\o\|\\x\x\x\|\\c[^"]\|\\[abefnrtv]"	contained
 syn match   shSpecial	"^\(\\\\\)*\zs\\\o\o\o\|\\x\x\x\|\\c[^"]\|\\[abefnrtv]"	contained
 syn region  shExSingleQuote	matchgroup=shQuote start=+\$'+ skip=+\\\\\|\\.+ end=+'+	contains=shStringSpecial,shSpecial		nextgroup=shSpecialNxt
 syn region  shExDoubleQuote	matchgroup=shQuote start=+\$"+ skip=+\\\\\|\\.\|\\"+ end=+"+	contains=@shDblQuoteList,shStringSpecial,shSpecial	nextgroup=shSpecialNxt
elseif !exists("g:sh_no_error")
 syn region  shExSingleQuote	matchGroup=Error start=+\$'+ skip=+\\\\\|\\.+ end=+'+	contains=shStringSpecial
 syn region  shExDoubleQuote	matchGroup=Error start=+\$"+ skip=+\\\\\|\\.+ end=+"+	contains=shStringSpecial
endif
syn region  shSingleQuote	matchgroup=shQuote start=+'+ end=+'+		contains=@Spell	nextgroup=shSpecialStart,shSpecialSQ
syn region  shDoubleQuote	matchgroup=shQuote start=+\%(\%(\\\\\)*\\\)\@<!"+ skip=+\\.+ end=+"+			contains=@shDblQuoteList,shStringSpecial,@Spell	nextgroup=shSpecialStart
syn match   shStringSpecial	"[^[:print:] \t]"			contained
syn match   shStringSpecial	"[^\\]\zs\%(\\\\\)*\(\\[\\"'`$()#]\)\+"			nextgroup=shComment
syn match   shSpecialSQ	"[^\\]\zs\%(\\\\\)*\(\\[\\"'`$()#]\)\+"		contained	nextgroup=shBkslshSnglQuote,@shNoZSList
syn match   shSpecialDQ	"[^\\]\zs\%(\\\\\)*\(\\[\\"'`$()#]\)\+"		contained	nextgroup=shBkslshDblQuote,@shNoZSList
syn match   shSpecialStart	"\%(\\\\\)*\\[\\"'`$()#]"			contained	nextgroup=shBkslshSnglQuote,shBkslshDblQuote,@shNoZSList
syn match   shSpecial	"^\%(\\\\\)*\\[\\"'`$()#]"
syn match   shSpecialNoZS	contained	"\%(\\\\\)*\\[\\"'`$()#]"
syn match   shSpecialNxt	contained	"\\[\\"'`$()#]"
"syn region  shBkslshSnglQuote	contained	matchgroup=shQuote start=+'+ end=+'+	contains=@Spell	nextgroup=shSpecialStart
"syn region  shBkslshDblQuote	contained	matchgroup=shQuote start=+"+ skip=+\\"+ end=+"+	contains=@shDblQuoteList,shStringSpecial,@Spell	nextgroup=shSpecialStart

" Comments: {{{1
"==========
syn cluster	shCommentGroup	contains=shTodo,@Spell
if exists("b:is_bash")
 syn match	shTodo	contained		"\<\%(COMBAK\|FIXME\|TODO\|XXX\)\ze:\=\>"
else
 syn keyword	shTodo	contained		COMBAK FIXME TODO XXX
endif
syn match	shComment		"^\s*\zs#.*$"	contains=@shCommentGroup
syn match	shComment		"\s\zs#.*$"	contains=@shCommentGroup
syn match	shComment	contained	"#.*$"	contains=@shCommentGroup
syn match	shQuickComment	contained	"#.*$"          contains=@shCommentGroup
syn match	shBQComment	contained	"#.\{-}\ze`"	contains=@shCommentGroup

" Here Documents: {{{1
"  (modified by Felipe Contreras)
" =========================================
ShFoldHereDoc syn region shHereDoc matchgroup=shHereDoc01 start="<<\s*\z([^ \t|>]\+\)"		matchgroup=shHereDoc01 end="^\z1$"	contains=@shDblQuoteList
ShFoldHereDoc syn region shHereDoc matchgroup=shHereDoc02 start="<<-\s*\z([^ \t|>]\+\)"		matchgroup=shHereDoc02 end="^\t*\z1$"	contains=@shDblQuoteList
ShFoldHereDoc syn region shHereDoc matchgroup=shHereDoc03 start="<<\s*\\\z([^ \t|>]\+\)"		matchgroup=shHereDoc03 end="^\z1$"
ShFoldHereDoc syn region shHereDoc matchgroup=shHereDoc04 start="<<-\s*\\\z([^ \t|>]\+\)"		matchgroup=shHereDoc04 end="^\t*\z1$"
ShFoldHereDoc syn region shHereDoc matchgroup=shHereDoc05 start="<<\s*'\z([^']\+\)'"		matchgroup=shHereDoc05 end="^\z1$"
ShFoldHereDoc syn region shHereDoc matchgroup=shHereDoc06 start="<<-\s*'\z([^']\+\)'"		matchgroup=shHereDoc06 end="^\t*\z1$"
ShFoldHereDoc syn region shHereDoc matchgroup=shHereDoc07 start="<<\s*\"\z([^"]\+\)\""		matchgroup=shHereDoc07 end="^\z1$"
ShFoldHereDoc syn region shHereDoc matchgroup=shHereDoc08 start="<<-\s*\"\z([^"]\+\)\""		matchgroup=shHereDoc08 end="^\t*\z1$"
ShFoldHereDoc syn region shHereDoc matchgroup=shHereDoc09 start="<<\s*\\\_$\_s*\z([^ \t|>]\+\)"		matchgroup=shHereDoc09 end="^\z1$"	contains=@shDblQuoteList
ShFoldHereDoc syn region shHereDoc matchgroup=shHereDoc10 start="<<-\s*\\\_$\_s*\z([^ \t|>]\+\)"	matchgroup=shHereDoc10 end="^\t*\z1$"	contains=@shDblQuoteList
ShFoldHereDoc syn region shHereDoc matchgroup=shHereDoc11 start="<<\s*\\\_$\_s*\\\z([^ \t|>]\+\)"	matchgroup=shHereDoc11 end="^\z1$"
ShFoldHereDoc syn region shHereDoc matchgroup=shHereDoc12 start="<<-\s*\\\_$\_s*\\\z([^ \t|>]\+\)"	matchgroup=shHereDoc12 end="^\t*\z1$"
ShFoldHereDoc syn region shHereDoc matchgroup=shHereDoc13 start="<<\s*\\\_$\_s*'\z([^']\+\)'"		matchgroup=shHereDoc13 end="^\z1$"
ShFoldHereDoc syn region shHereDoc matchgroup=shHereDoc14 start="<<-\s*\\\_$\_s*'\z([^']\+\)'"		matchgroup=shHereDoc14 end="^\t*\z1$"
ShFoldHereDoc syn region shHereDoc matchgroup=shHereDoc15 start="<<\s*\\\_$\_s*\"\z([^"]\+\)\""		matchgroup=shHereDoc15 end="^\z1$"
ShFoldHereDoc syn region shHereDoc matchgroup=shHereDoc16 start="<<-\s*\\\_$\_s*\"\z([^"]\+\)\""	matchgroup=shHereDoc16 end="^\t*\z1$"


" Here Strings: {{{1
" =============
" available for: bash and ksh (except ksh88) but not if its a posix
if exists("b:is_bash") || ((exists("b:is_kornshell") && !exists("b:is_ksh88")) && !exists("b:is_posix"))
 syn match shHereString "<<<"	skipwhite	nextgroup=shCmdParenRegion
endif

" Identifiers: {{{1
"=============
syn match  shSetOption	"\s\zs[-+][a-zA-Z0-9]\+\>"	contained
syn match  shVariable	"\<\h\w*\ze="			nextgroup=shVarAssign
if exists("b:is_bash")
 " The subscript form for array values, e.g. "foo=([2]=10 [4]=100)".
 syn region  shArrayValue	contained	start="\[\%(..\{-}\]=\)\@=" end="\]=\@="	contains=@shArrayValueList nextgroup=shVarAssign
 syn cluster shArrayValueList	contains=shArithmetic,shArithParen,shCommandSub,shDeref,shDerefSimple,shExpr,shNumber,shExSingleQuote,shExDoubleQuote,shSingleQuote,shDoubleQuote,shSpecial,shParen,bashSpecialVariables,shParenError
 syn region  shArrayRegion	contained matchgroup=shShellVariables start="(" skip='\\\\\|\\.' end=")" contains=@shArrayValueList,shArrayValue,shComment
elseif (exists("b:is_kornshell") && !exists("b:is_ksh88"))
 " The subscript form for array values, e.g. "foo=([2]=10 [4]=100)".
 syn region  shArrayValue	contained	start="\[\%(..\{-}\]=\)\@=" end="\]=\@="	contains=@shArrayValueList nextgroup=shVarAssign
 syn cluster shArrayValueList	contains=shArithmetic,shArithParen,shCommandSub,shDeref,shDerefSimple,shExpr,shNumber,shExSingleQuote,shExDoubleQuote,shSingleQuote,shDoubleQuote,shSpecial,shParen,kshSpecialVariables,shParenError
 syn region  shArrayRegion	contained matchgroup=shShellVariables start="(" skip='\\\\\|\\.' end=")" contains=@shArrayValueList,shArrayValue,shComment,shArrayRegion
endif
if exists("b:is_bash") || exists("b:is_kornshell")
 syn match shVariable	"\<\h\w*\%(\[..\{-}\]\)\=\ze\%([|^&*/%+-]\|[<^]<\|[>^]>\)\=="	contains=shDerefVarArray nextgroup=shVarAssign
 syn match shVarAssign	contained	"\%([|^&*/%+-]\|[<^]<\|[>^]>\)\=="	nextgroup=shArrayRegion,shPattern,shDeref,shDerefSimple,shDoubleQuote,shExDoubleQuote,shSingleQuote,shExSingleQuote,shVar
else
 syn match  shVarAssign	contained	"="	nextgroup=shPattern,shDeref,shDerefSimple,shDoubleQuote,shExDoubleQuote,shSingleQuote,shExSingleQuote,shVar
endif
syn match  shVar	contained	"\h\w*"
syn region shAtExpr	contained	start="@(" end=")" contains=@shIdList
if exists("b:is_bash")
 syn match  shSet "^\s*set\ze\s\+$"
 syn region shSetList oneline matchgroup=shSet start="\<\%(declare\|local\|export\)\>\ze[/a-zA-Z_]\@!" end="$"		matchgroup=shSetListDelim end="\ze[}|);&]" matchgroup=NONE end="\ze\s\+#\|="	contains=@shIdList
 syn region shSetList oneline matchgroup=shSet start="\<\%(set\|unset\)\>[/a-zA-Z_]\@!" end="\ze[;|#)]\|$"		matchgroup=shSetListDelim end="\ze[}|);&]" matchgroup=NONE end="\ze\s\+="	contains=@shIdList nextgroup=shComment
elseif exists("b:is_kornshell") || exists("b:is_posix")
 syn match  shSet "^\s*set\ze\s\+$"
 if exists("b:is_dash")
  syn region shSetList oneline matchgroup=shSet start="\<\%(local\)\>\ze[/]\@!" end="$"			matchgroup=shSetListDelim end="\ze[}|);&]" matchgroup=NONE end="\ze\s\+[#=]"	contains=@shIdList
 endif
 syn region shSetList oneline matchgroup=shSet start="\<\(export\)\>\ze[/]\@!" end="$"			matchgroup=shSetListDelim end="\ze[}|);&]" matchgroup=NONE end="\ze\s\+[#=]"	contains=@shIdList
 syn region shSetList oneline matchgroup=shSet start="\<\%(set\|unset\>\)\ze[/a-zA-Z_]\@!" end="\ze[;|#)]\|$"		matchgroup=shSetListDelim end="\ze[}|);&]" matchgroup=NONE end="\ze\s\+[#=]"	contains=@shIdList nextgroup=shComment
else
 syn region shSetList oneline matchgroup=shSet start="\<\(set\|export\|unset\)\>\ze[/a-zA-Z_]\@!" end="\ze[;|#)]\|$"	matchgroup=shSetListDelim end="\ze[}|);&]" matchgroup=NONE end="\ze\s\+[#=]"	contains=@shIdList
endif

" KornShell namespace: {{{1
if exists("b:is_kornshell") && !exists("b:is_ksh88") && !exists("b:is_mksh")
 syn keyword shFunctionKey namespace skipwhite skipnl nextgroup=shFunctionTwo
endif

" Functions: {{{1
if !exists("b:is_posix")
 syn keyword shFunctionKey function	skipwhite skipnl nextgroup=shFunctionTwo
endif

if exists("b:is_bash")
 syn keyword shFunctionKey coproc
 ShFoldFunctions syn region shFunctionOne	matchgroup=shFunction start="^\s*[A-Za-z_0-9:][-a-zA-Z_0-9:]*\s*()\_s*{"		end="}"	contains=@shFunctionList		 skipwhite skipnl nextgroup=shFunctionStart,shQuickComment
 ShFoldFunctions syn region shFunctionTwo	matchgroup=shFunction start="\%(do\)\@!\&\<[A-Za-z_0-9:][-a-zA-Z_0-9:]*\>\s*\%(()\)\=\_s*{"	end="}"	contains=shFunctionKey,@shFunctionList contained skipwhite skipnl nextgroup=shFunctionStart,shQuickComment
 ShFoldFunctions syn region shFunctionThree	matchgroup=shFunction start="^\s*[A-Za-z_0-9:][-a-zA-Z_0-9:]*\s*()\_s*("		end=")"	contains=@shFunctionList		 skipwhite skipnl nextgroup=shFunctionStart,shQuickComment
 ShFoldFunctions syn region shFunctionFour	matchgroup=shFunction start="\%(do\)\@!\&\<[A-Za-z_0-9:][-a-zA-Z_0-9:]*\>\s*\%(()\)\=\_s*)"	end=")"	contains=shFunctionKey,@shFunctionList contained skipwhite skipnl nextgroup=shFunctionStart,shQuickComment
else
 ShFoldFunctions syn region shFunctionOne	matchgroup=shFunction start="^\s*\h\w*\s*()\_s*{"			end="}"	contains=@shFunctionList		 skipwhite skipnl nextgroup=shFunctionStart,shQuickComment
 ShFoldFunctions syn region shFunctionTwo	matchgroup=shFunction start="\%(do\)\@!\&\<\h\w*\>\s*\%(()\)\=\_s*{"		end="}"	contains=shFunctionKey,@shFunctionList contained skipwhite skipnl nextgroup=shFunctionStart,shQuickComment
 ShFoldFunctions syn region shFunctionThree	matchgroup=shFunction start="^\s*\h\w*\s*()\_s*("			end=")"	contains=@shFunctionList		 skipwhite skipnl nextgroup=shFunctionStart,shQuickComment
 ShFoldFunctions syn region shFunctionFour	matchgroup=shFunction start="\%(do\)\@!\&\<\h\w*\>\s*\%(()\)\=\_s*("		end=")"	contains=shFunctionKey,@shFunctionList contained skipwhite skipnl nextgroup=shFunctionStart,shQuickComment
endif

" Parameter Dereferencing: {{{1
" ========================
" Note: sh04 failure with following line
"if !exists("g:sh_no_error") && !(exists("b:is_bash") || exists("b:is_kornshell") || exists("b:is_posix"))
if !exists("g:sh_no_error")
 syn match  shDerefWordError	"[^}$[~]"	contained
endif
syn match  shDerefSimple	"\$\%(\h\w*\|\d\)"	nextgroup=@shNoZSList
if exists("b:is_kornshell") && !exists("b:is_ksh88")
 if exists("b:is_mksh")
  syn region shDeref	matchgroup=PreProc start="\${\ze[^ \t\n|]" end="}"	contains=@shDerefList,shDerefVarArray nextgroup=shSpecialStart
 elseif exists("b:generic_korn")
  syn region shDeref	matchgroup=PreProc start="\${\ze[^ \t\n<|]" end="}"	contains=@shDerefList,shDerefVarArray nextgroup=shSpecialStart
 else
  syn region shDeref	matchgroup=PreProc start="\${\ze[^ \t\n<]" end="}"	contains=@shDerefList,shDerefVarArray nextgroup=shSpecialStart
 endif
else
 syn region shDeref	matchgroup=PreProc start="\${" end="}"			contains=@shDerefList,shDerefVarArray nextgroup=shSpecialStart
endif
syn match  shDerefSimple	"\$[-#*@!?]"	nextgroup=@shNoZSList
syn match  shDerefSimple	"\$\$"	nextgroup=@shNoZSList
syn match  shDerefSimple	"\${\d}"	nextgroup=@shNoZSList	nextgroup=shSpecialStart
if exists("b:is_bash") || exists("b:is_kornshell") || exists("b:is_posix")
 syn region shDeref	matchgroup=PreProc start="\${##\=" end="}"	contains=@shDerefList	nextgroup=@shSpecialNoZS,shSpecialStart
 syn region shDeref	matchgroup=PreProc start="\${\$\$" end="}"	contains=@shDerefList	nextgroup=@shSpecialNoZS,shSpecialStart
endif

" ksh: ${.sh.*} variables: {{{1
" ========================================
if exists("b:is_kornshell") && !exists("b:is_ksh88") && !exists("b:is_mksh")
 syn match  shDerefVar	contained	"\.\+"	nextgroup=@shDerefVarList
 syn region shDeref	matchgroup=PreProc start="\${\ze[\.]" end="}"	contains=@shDerefVarList,shDerefPSR,shDerefPPS
endif

" ksh: ${!var[*]} array index list syntax: {{{1
" ========================================
if (exists("b:is_kornshell") && !exists("b:is_ksh88")) || exists("b:is_posix")
 syn region shDeref	matchgroup=PreProc start="\${!" end="}"	contains=@shDerefVarArray
endif

" bash: ${!prefix*} and ${#parameter}: {{{1
" ====================================
if exists("b:is_bash")
 syn region shDeref	matchgroup=PreProc start="\${!" end="\*\=}"	contains=@shDerefList,shDerefOffset
 syn match  shDerefVar	contained	"{\@<=!\h\w*"		nextgroup=@shDerefVarList
endif
if (exists("b:is_kornshell") && !exists("b:is_ksh88"))
 syn match  shDerefVar	contained	"{\@<=!\h\w*[[:alnum:]_.]*"	nextgroup=@shDerefVarList
endif

syn match  shDerefSpecial	contained	"{\@<=[-*@?0]"		nextgroup=shDerefOp,shDerefOffset,shDerefOpError
syn match  shDerefSpecial	contained	"\({[#!]\)\@<=[[:alnum:]*@_]\+"	nextgroup=@shDerefVarList,shDerefOp
syn match  shDerefVar	contained	"{\@<=\h\w*"		nextgroup=@shDerefVarList
syn match  shDerefVar	contained	'\d'                            nextgroup=@shDerefVarList
if exists("b:is_kornshell") || exists("b:is_posix")
  syn match  shDerefVar	contained	"{\@<=\h\w*[[:alnum:]_.]*"	nextgroup=@shDerefVarList
endif

" sh ksh bash : ${var[... ]...}  array reference: {{{1
syn region  shDerefVarArray   contained	matchgroup=shDeref start="\[" end="]"	contains=@shCommandSubList nextgroup=shDerefOp,shDerefOpError,shDerefOffset

" Special ${parameter OPERATOR word} handling: {{{1
" sh ksh bash : ${parameter:-word}    word is default value
" sh ksh bash : ${parameter:=word}    assign word as default value
" sh ksh bash : ${parameter:?word}    display word if parameter is null
" sh ksh bash : ${parameter:+word}    use word if parameter is not null, otherwise nothing
"    ksh bash : ${parameter#pattern}  remove small left  pattern
"    ksh bash : ${parameter##pattern} remove large left  pattern
"    ksh bash : ${parameter%pattern}  remove small right pattern
"    ksh bash : ${parameter%%pattern} remove large right pattern
"    ksh bash : ${parameter^pattern}  Case modification
"    ksh bash : ${parameter^^pattern} Case modification
"    ksh bash : ${parameter,pattern}  Case modification
"    ksh bash : ${parameter,,pattern} Case modification
"        bash : ${@:start:qty}        display command line arguments from start to start+qty-1 (inferred)
"        bash : ${parameter@operator} transforms parameter (operator∈[uULqEPARa])
syn cluster shDerefPatternList	contains=shDerefPattern,shDerefString
if !exists("g:sh_no_error")
 syn match shDerefOpError	contained	":[[:punct:]]"
endif
syn match  shDerefOp	contained	":\=[-=?]"	nextgroup=@shDerefPatternList
syn match  shDerefOp	contained	":\=+"	nextgroup=@shDerefPatternList
if exists("b:is_bash") || exists("b:is_kornshell") || exists("b:is_posix")
 syn match  shDerefOp	contained	"#\{1,2}"		nextgroup=@shDerefPatternList
 syn match  shDerefOp	contained	"%\{1,2}"		nextgroup=@shDerefPatternList
 syn match  shDerefPattern	contained	"[^{}]\+"		contains=shDeref,shDerefSimple,shDerefPattern,shDerefString,shCommandSub,shDerefEscape nextgroup=shDerefPattern skipnl
 syn region shDerefPattern	contained	start="{" end="}"	contains=shDeref,shDerefSimple,shDerefString,shCommandSub nextgroup=shDerefPattern
 " Match parametric bracket expressions with a leading whitespace character.
 syn region shDerefPattern	contained	matchgroup=shBracketExprDelim start="\[" end="\]"	contains=@shBracketExprList,shDoubleQuote nextgroup=shDerefPattern
 call s:GenerateBracketExpressionItems({'itemGroup': 'shDerefPattern', 'bracketGroup': 'shBracketExprDelim', 'extraArgs': 'contained nextgroup=shDerefPattern'})
 syn match  shDerefEscape	contained	'\%(\\\\\)*\\.'
endif
if exists("b:is_bash") || (exists("b:is_kornshell") && !exists("b:is_ksh88") && !exists("b:is_mksh") && !exists("b:is_ksh93u") && !exists("b:is_ksh2020"))
 syn match  shDerefOp	contained	"[,^]\{1,2}"	nextgroup=@shDerefPatternList
endif
if exists("b:is_bash")
 syn match  shDerefOp	contained	"@[uULQEPAKa]"
endif
syn region shDerefString	contained	matchgroup=shDerefDelim start=+\%(\\\)\@<!'+ end=+'+
syn region shDerefString	contained	matchgroup=shDerefDelim start=+\%(\\\)\@<!"+ skip=+\\"+ end=+"+	contains=@shDblQuoteList,shStringSpecial
syn match  shDerefString	contained	"\\["']"	nextgroup=shDerefPattern

if exists("b:is_bash") || (exists("b:is_kornshell") && !exists("b:is_ksh88")) || exists("b:is_posix")
 " bash ksh posix : ${parameter:offset}
 " bash ksh posix : ${parameter:offset:length}
 syn region shDerefOffset	contained	start=':[^-=?+]' end='\ze:'	end='\ze}'	contains=shDeref,shDerefSimple,shDerefEscape	nextgroup=shDerefLen,shDeref,shDerefSimple
 syn region shDerefOffset	contained	start=':\s-'	end='\ze:'	end='\ze}'	contains=shDeref,shDerefSimple,shDerefEscape	nextgroup=shDerefLen,shDeref,shDerefSimple
 syn match  shDerefLen	contained	":[^}]\+"	contains=shDeref,shDerefSimple,shArithmetic
endif

if exists("b:is_bash") || (exists("b:is_kornshell") && !exists("b:is_ksh88"))
 " bash ksh : ${parameter/pattern/string}
 " bash ksh : ${parameter//pattern/string}
 syn match  shDerefPPS	contained	'/\{1,2}'	nextgroup=shDerefPPSleft
 syn region shDerefPPSleft	contained	start='.'	skip=@\%(\\\\\)*\\/@ matchgroup=shDerefOp	end='/' end='\ze}' end='"'	nextgroup=shDerefPPSright	contains=@shPPSLeftList
 syn region shDerefPPSright	contained	start='.'	skip=@\%(\\\\\)\+@		end='\ze}'				contains=@shPPSRightList

 " bash ksh : ${parameter/#pattern/string}
 " bash ksh : ${parameter/%pattern/string}
 syn match  shDerefPSR	contained	'/[#%]'	nextgroup=shDerefPSRleft,shDoubleQuote,shSingleQuote
 syn region shDerefPSRleft	contained	start='[^"']'	skip=@\%(\\\\\)*\\/@ matchgroup=shDerefOp	end='/' end='\ze}'	nextgroup=shDerefPSRright	contains=shBracketExpr
 syn region shDerefPSRright	contained	start='.'	skip=@\%(\\\\\)\+@		end='\ze}'
endif

" Arithmetic Parenthesized Expressions: {{{1
"syn region shParen matchgroup=shArithRegion start='[^$]\zs(\%(\ze[^(]\|$\)' end=')' contains=@shArithParenList
syn region shParen matchgroup=shArithRegion start='\$\@!(\%(\ze[^(]\|$\)' end=')' contains=@shArithParenList

" Additional sh Keywords: {{{1
" ===================
syn keyword shStatement break cd chdir continue eval exec exit kill newgrp pwd read readonly return shift test trap ulimit umask wait
syn keyword shConditional contained elif else then
if !exists("g:sh_no_error")
 syn keyword shCondError elif else then
endif

" Additional ksh Keywords and Aliases: {{{1
" ===================================
if exists("b:is_kornshell") || exists("b:is_posix")
 syn keyword shStatement bg builtin disown enum export false fg getconf getopts hist jobs let printf sleep true unalias whence
 syn keyword shStatement typeset skipwhite nextgroup=shSetOption
 syn keyword shStatement autoload compound fc float functions hash history integer nameref nohup r redirect source stop suspend times type
 if exists("b:is_posix")
  syn keyword shStatement command
 else
  syn keyword shStatement time
 endif

" Additional bash Keywords: {{{1
" =====================
elseif exists("b:is_bash")
 syn keyword shStatement bg builtin disown export false fg getopts jobs let printf true unalias
 syn keyword shStatement typeset nextgroup=shSetOption
 syn keyword shStatement fc hash history source suspend times type
 syn keyword shStatement bind caller compopt declare dirs enable help logout local mapfile popd pushd readarray shopt typeset
else
 syn keyword shStatement login newgrp
endif

" Synchronization: {{{1
" ================
if !exists("g:sh_minlines")
 let s:sh_minlines = 200
else
 let s:sh_minlines= g:sh_minlines
endif
if !exists("g:sh_maxlines")
 let s:sh_maxlines = 2*s:sh_minlines
 if s:sh_maxlines < 25
  let s:sh_maxlines= 25
 endif
else
 let s:sh_maxlines= g:sh_maxlines
endif
exec "syn sync minlines=" . s:sh_minlines . " maxlines=" . s:sh_maxlines
syn sync match shCaseEsacSync	grouphere	shCaseEsac	"\<case\>"
syn sync match shCaseEsacSync	groupthere	shCaseEsac	"\<esac\>"
syn sync match shDoSync	grouphere	shDo	"\<do\>"
syn sync match shDoSync	groupthere	shDo	"\<done\>"
syn sync match shForSync	grouphere	shFor	"\<for\>"
syn sync match shForSync	groupthere	shFor	"\<in\>"
syn sync match shIfSync	grouphere	shIf	"\<if\>"
syn sync match shIfSync	groupthere	shIf	"\<fi\>"
syn sync match shUntilSync	grouphere	shRepeat	"\<until\>"
syn sync match shWhileSync	grouphere	shRepeat	"\<while\>"

" Default Highlighting: {{{1
" =====================
if !exists("skip_sh_syntax_inits")
 hi def link shArithRegion	shShellVariables
 hi def link shArrayValue	shDeref
 hi def link shAstQuote	shDoubleQuote
 hi def link shAtExpr	shSetList
 hi def link shBkslshSnglQuote	shSingleQuote
 hi def link shBkslshDblQuote	shDOubleQuote
 hi def link shBeginHere	shRedir
 hi def link shCaseBar	shConditional
 hi def link shCaseCommandSub	shCommandSub
 hi def link shCaseDoubleQuote	shDoubleQuote
 hi def link shCaseIn	shConditional
 hi def link shQuote	shOperator
 hi def link shCaseSingleQuote	shSingleQuote
 hi def link shCaseStart	shConditional
 hi def link shCmdSubRegion	shShellVariables
 hi def link shColon	shComment
 hi def link shDerefOp	shOperator
 hi def link shDerefPOL	shDerefOp
 hi def link shDerefPPS	shDerefOp
 hi def link shDerefPSR	shDerefOp
 hi def link shDeref	shShellVariables
 hi def link shDerefDelim	shOperator
 hi def link shDerefSimple	shDeref
 hi def link shDerefSpecial	shDeref
 hi def link shDerefString	shDoubleQuote
 hi def link shDerefVar	shDeref
 hi def link shDoubleQuote	shString
 hi def link shEcho	shString
 hi def link shEchoDelim	shOperator
 hi def link shEchoQuote	shString
 hi def link shForPP	shLoop
 hi def link shFunction	Function
 hi def link shEmbeddedEcho	shString
 hi def link shEscape	shCommandSub
 hi def link shExDoubleQuote	shDoubleQuote
 hi def link shExSingleQuote	shSingleQuote
 hi def link shHereDoc	shString
 hi def link shHereString	shRedir
 hi def link shHerePayload	shHereDoc
 hi def link shLoop	shStatement
 hi def link shSpecialNxt	shSpecial
 hi def link shNoQuote	shDoubleQuote
 hi def link shOption	shCommandSub
 hi def link shPattern	shString
 hi def link shParen	shArithmetic
 hi def link shPosnParm	shShellVariables
 hi def link shQuickComment	shComment
 hi def link shBQComment	shComment
 hi def link shRange	shOperator
 hi def link shRedir	shOperator
 hi def link shSetListDelim	shOperator
 hi def link shSetOption	shOption
 hi def link shSingleQuote	shString
 hi def link shSource	shOperator
 hi def link shStringSpecial	shSpecial
 hi def link shSpecialStart	shSpecial
 hi def link shSubShRegion	shOperator
 hi def link shTestOpr	shConditional
 hi def link shTestPattern	shString
 hi def link shTestDoubleQuote	shString
 hi def link shTestSingleQuote	shString
 hi def link shTouchCmd	shStatement
 hi def link shVariable	shSetList
 hi def link shWrapLineOperator	shOperator

 if exists("b:is_bash")
   hi def link bashAdminStatement	shStatement
   hi def link bashSpecialVariables	shShellVariables
   hi def link bashStatement		shStatement
   hi def link shCharClass		shSpecial
   hi def link shDerefOffset		shDerefOp
   hi def link shDerefLen		shDerefOffset
 endif
 if exists("b:is_kornshell") || exists("b:is_posix")
   hi def link kshSpecialVariables	shShellVariables
   hi def link kshStatement		shStatement
 endif

 if !exists("g:sh_no_error")
  hi def link shCaseError		Error
  hi def link shCondError		Error
  hi def link shCurlyError		Error
  hi def link shDerefOpError		Error
  hi def link shDerefWordError		Error
  hi def link shDoError		Error
  hi def link shEsacError		Error
  hi def link shIfError		Error
  hi def link shInError		Error
  hi def link shParenError		Error
  hi def link shTestError		Error
  if exists("b:is_kornshell") || exists("b:is_posix")
    hi def link shDTestError		Error
  endif
 endif

 hi def link shArithmetic		Special
 hi def link shBracketExprDelim		Delimiter
 hi def link shCharClass		Identifier
 hi def link shCollSymb		shCharClass
 hi def link shEqClass		shCharClass
 hi def link shSnglCase		Statement
 hi def link shCommandSub		Special
 hi def link shCommandSubBQ		shCommandSub
 hi def link shSubshare		shCommandSub
 hi def link shValsub		shCommandSub
 hi def link shComment		Comment
 hi def link shConditional		Conditional
 hi def link shCtrlSeq		Special
 hi def link shExprRegion		Delimiter
 hi def link shFunctionKey		Function
 hi def link shFunctionName		Function
 hi def link shNumber		Number
 hi def link shOperator		Operator
 hi def link shRepeat		Repeat
 hi def link shSet		Statement
 hi def link shSetList		Identifier
 hi def link shShellVariables		PreProc
 hi def link shSpecial		Special
 hi def link shSpecialDQ		Special
 hi def link shSpecialSQ		Special
 hi def link shSpecialNoZS		shSpecial
 hi def link shStatement		Statement
 hi def link shString		String
 hi def link shTodo		Todo
 hi def link shAlias		Identifier
 hi def link shHereDoc01		shRedir
 hi def link shHereDoc02		shRedir
 hi def link shHereDoc03		shRedir
 hi def link shHereDoc04		shRedir
 hi def link shHereDoc05		shRedir
 hi def link shHereDoc06		shRedir
 hi def link shHereDoc07		shRedir
 hi def link shHereDoc08		shRedir
 hi def link shHereDoc09		shRedir
 hi def link shHereDoc10		shRedir
 hi def link shHereDoc11		shRedir
 hi def link shHereDoc12		shRedir
 hi def link shHereDoc13		shRedir
 hi def link shHereDoc14		shRedir
 hi def link shHereDoc15		shRedir
 hi def link shHereDoc16		shRedir
endif

" Delete shell folding commands {{{1
" =============================
delc ShFoldFunctions
delc ShFoldHereDoc
delc ShFoldIfDoFor

" Delete the bracket expression function {{{1
" ======================================
delfun s:GenerateBracketExpressionItems

" Set Current Syntax: {{{1
" ===================
if exists("b:is_bash")
 let b:current_syntax = "bash"
elseif exists("b:is_kornshell")
 let b:current_syntax = "ksh"
elseif exists("b:is_posix")
 let b:current_syntax = "posix"
else
 let b:current_syntax = "sh"
endif

" vim: ts=16 fdm=marker
