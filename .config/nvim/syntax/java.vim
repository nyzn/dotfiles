
" note do not change the order...
" some of them are overridding privous regrex 

"this code made with build-in syntax regrex(and key words), and with some custome regrex(and
"key words)

""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set tabstop=4
set shiftwidth=4
set textwidth=250
set nowrap

"" gruvbox (dark)
"" let orange = "#fe8019" "special color for numbers
"" let black = "#282828"
"" let red = "#fb4934"
"" let green = "#b8bb26"
"" let yellow = "#fabd2f"
"" let blue = "#458588"
"" let purple = "#d3869b"
"" let cyan = "#689d6a"
"" let white = "#a89984"

"" melange (dark)
"" let orange = "#fe8019" "special color for numbers
"" let black = "#292522"
"" let red = "#7D2A2F"
"" let green = "#233524"
"" let yellow = "#8B7449"
"" let blue = "#273142"
"" let purple = "#422741"
"" let cyan = "#253333"
"" let white = "#403A36"

"" one dark
""let orange = "#d19a66" "special color for numbers
""let black = "#282c34"
""let red = "#E06C75"
""let green = "#98c379"
""let yellow = "#E5C07B"
""let blue = "#61AFEF"
""let purple = "#C678DD"
""let cyan = "#56B6C2"
""let white = "#ABB2BF"



"" you may chage the color according to your will :)


"" main color (for left over words)
"" syn match main "\w"
" execute "highlight main ctermfg=4  guifg=".red

"" numbers
"syn match posNum "\d"
"execute "highlight posNum ctermfg=4  guifg=".orange

"" method names()
"syn match class ".\w*\((\)\@="
"execute "highlight class ctermfg=4  guifg=".blue

""execute "highlight names which contains numbers
"syn match main "\v(\a)\w*\d"
"execute "highlight main ctermfg=4  guifg=".red


""all regrex works
"" /^import (+);$/mg 
"" import \zs.*\ze
"" \v(^import\s+)@<=.*;

"" imported packages 
"syn match importName "\v(^import\s+)@<=.*;"
"execute "highlight importName ctermfg=4  guifg=".yellow

"" import 
"syn match importWord "import "
"execute "highlight importWord ctermfg=4  guifg=".red

"" package name
"syn match packageName "\v(^package\s+)@<=.*;"
"execute "highlight packageName ctermfg=4  guifg=".yellow

"" package 
"syn match packageWord "package "
"execute "highlight packageWord ctermfg=4  guifg=".red

""ex: int, double, char
"execute "highlight javaType ctermfg=4  guifg=".yellow

""ex: static, throws
"execute "highlight javaStorageClass ctermfg=4  guifg=".purple


""class name... basically starts with caps letter
"syntax match ClassName display '\<\([A-Z][a-z0-9]*\)\+\>'
"syntax match ClassName display '\.\@<=\*'
"highlight link ClassName Identifier
"execute "highlight ClassName ctermfg=4  guifg=".yellow

"" Just some special color, why not?  
"syn match print " System.out."
"execute "highlight print ctermfg=4  guifg=".yellow

"syn match print "//TODO"
"execute "highlight print ctermfg=4 guifg=".yellow

""objects (ex: String) 
"execute "highlight Constant ctermfg=4  guifg=".yellow

"" class
"syn match javaClassDecl2 " class\> "
"execute "highlight javaClassDecl2 ctermfg=4  guifg=".red

"" package
"execute "highlight javaExternal ctermfg=4  guifg=".red

""if else switch
"execute "highlight javaConditional ctermfg=4  guifg=".red

""while for do 
"execute "highlight javaRepeat ctermfg=4  guifg=".red

""true flase
"execute "highlight javaBoolean ctermfg=4  guifg=".orange


"" null
"syn match null "\v[ =]null[; ]"
"execute "highlight null ctermfg=4  guifg=".orange


"" this super
"execute "highlight javaTypedef ctermfg=4  guifg=".red
		
"" var new instanceof
"execute "highlight javaOperator ctermfg=4  guifg=".red
	
"" return
"execute "highlight javaStatement ctermfg=4  guifg=".red

"" static synchronized transient volatile final strictfp serializable
"execute "highlight javaStorageClass ctermfg=4  guifg=".red

""throw try catch finally
"execute "highlight javaExceptions ctermfg=4  guifg=".red

"" assert
"execute "highlight javaAssert ctermfg=4  guifg=".red

"" synchronized throws
"execute "highlight javaMethodDecl ctermfg=4  guifg=".red

"" extends implements interface
"execute "highlight javaClassDecl ctermfg=4  guifg=".red

"" interface 
"execute "highlight javaClassDecl ctermfg=4  guifg=".red

"" break continue skipwhite
"execute "highlight javaBranch ctermfg=4  guifg=".purple

"" public protected private abstract
"execute "highlight javaScopeDecl ctermfg=4  guifg=".red


"""""""""""""""""""""""""""""""""""""""'
"" java 9...
"" module transitive
"execute "highlight javaModuleStorageClass ctermfg=4  guifg=".purple


"" open requires exports opens uses provides 
"execute "highlight javaModuleStmt ctermfg=4  guifg=".yellow


"" to with
"execute "highlight javaModuleExternal ctermfg=4  guifg=".red


""""""""""""""""""""""""""""""""""""""""""
"" lambda
"execute "highlight javaLambdaDef ctermfg=4  guifg=".cyan


"""""""""""""""""""""""""""""""""""""""""""
"" clone equals finalize getClass hashCode
"" notify notifyAll toString wait
"execute "highlight javaLangObject ctermfg=4  guifg=".yellow





"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

