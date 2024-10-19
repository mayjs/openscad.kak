
# Detection
# ‾‾‾‾‾‾‾‾‾

hook global BufCreate .*[.](scad) %{
    set-option buffer filetype openscad
}

# Initialization
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾

hook global WinSetOption filetype=openscad %{
    require-module openscad

    set-option window static_words %opt{openscad_static_words}

    hook window InsertChar \n -group openscad-indent openscad-indent-on-new-line
    hook -once -always window WinSetOption filetype=.* %{ remove-hooks window openscad-.+ }
}

hook -group openscad-highlight global WinSetOption filetype=openscad %{
    add-highlighter window/openscad ref openscad
    hook -once -always window WinSetOption filetype=.* %{ remove-highlighter window/openscad }
}

provide-module openscad %§

# Highlighters & Completion
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

add-highlighter shared/openscad regions
add-highlighter shared/openscad/code default-region group
add-highlighter shared/openscad/double_string region '"' (?<!\\)(\\\\)*" fill string
add-highlighter shared/openscad/single_string region "'" (?<!\\)(\\\\)*' fill string
add-highlighter shared/openscad/comment region '//' '$' fill comment
add-highlighter shared/openscad/block_comment region '/\*' '\*/' fill comment

# Integer formats
add-highlighter shared/openscad/code/ regex '(?i)\b0b[01]+l?\b' 0:value
add-highlighter shared/openscad/code/ regex '(?i)\b0x[\da-f]+l?\b' 0:value
add-highlighter shared/openscad/code/ regex '(?i)\b0o?[0-7]+l?\b' 0:value
add-highlighter shared/openscad/code/ regex '(?i)\b([1-9]\d*|0)l?\b' 0:value
# Float formats
add-highlighter shared/openscad/code/ regex '\b\d+[eE][+-]?\d+\b' 0:value
add-highlighter shared/openscad/code/ regex '(\b\d+)?\.\d+\b' 0:value
add-highlighter shared/openscad/code/ regex '\b\d+\.' 0:value

evaluate-commands %sh{
    # Grammar
    values='true false undef PI \$fa \$fs \$fn \$t \$vpr \$vpd $children $preview'
    echo echo -debug $values
    meta="include use"

    keywords="module function for each"

    # Taken from the OpenSCAD cheat sheet
    modules="circle square polygon text import projection
                sphere cube cylinder polyhedron import linear_extrude rotate_extrude surface
                translate rotate scale resize mirror multmatrix color offset hull minkowski
                union difference intersection"
    functions="concat lookup str chr ord search version version_num parent_module
                abs sign sin cos tan acos asin atan atan2 floor round ceil ln len let log
                pow sqrt exp rands min max norm cross
                is_undef is_bool is_num is_string is_list
                echo render children assert"

    join() { sep=$2; eval set -- $1; IFS="$sep"; echo "$*"; }
    echo echo -debug $(join "${values}" '|')

    # Add the language's grammar to the static completion list
    printf %s\\n "declare-option str-list openscad_static_words $(join "${values} ${meta} ${modules} ${keywords} ${functions}" ' ')"

    # Highlight keywords
    printf %s "
        add-highlighter shared/openscad/code/ regex '\b($(join "${values}" '|'))\b' 0:value
        add-highlighter shared/openscad/code/ regex '\b($(join "${meta}" '|'))\b' 0:meta
        add-highlighter shared/openscad/code/ regex '\b($(join "${keywords}" '|'))\b' 0:keyword
        add-highlighter shared/openscad/code/ regex '\b($(join "${functions} ${modules}" '|'))\b\(' 1:builtin
    "
}

add-highlighter shared/openscad/code/ regex (?<=[\w\s\d'"_])(<=|<<|>>|>=|<>|<|>|!=|==|\||\^|&|\+|-|\*\*|\*|//|/|%|~) 0:operator
add-highlighter shared/openscad/code/ regex (?<=[\w\s\d'"_])((?<![=<>!])=(?![=])|[+*-]=) 0:builtin
# Add highlighters for all the $X special variables manually since the join function creates invalid regexes for them.
# We would need to somehow escape $ characters in the join function to get rid of this 
add-highlighter shared/openscad/code/ regex (\$(fa|fs|fn|t|vpr|vpd|children|preview)) 0:italic

define-command -hidden openscad-indent-on-new-line %~
    evaluate-commands -draft -itersel %=
        # preserve previous line indent
        try %{ execute-keys -draft \;K<a-&> }
        # indent after lines ending with { or (
        try %[ execute-keys -draft k<a-x> <a-k> [{(]\h*$ <ret> j<a-gt> ]
        # cleanup trailing white spaces on the previous line
        try %{ execute-keys -draft k<a-x> s \h+$ <ret>d }
        # align to opening paren of previous line
        try %{ execute-keys -draft [( <a-k> \A\([^\n]+\n[^\n]*\n?\z <ret> s \A\(\h*.|.\z <ret> '<a-;>' & }
        # copy // comments prefix
        try %{ execute-keys -draft \;<c-s>k<a-x> s ^\h*\K/{2,} <ret> y<c-o>P<esc> }
    =
~
§
