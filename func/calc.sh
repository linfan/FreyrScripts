# Provide math calculation functions
# [Usage]:
# Use "source" command to load this script.

# Conversion of number system
function bin-to-dec()
{
    echo $(echo $((2#${1})))
}
function bin-to-hex()
{
    echo $(echo "obase=16;$(echo $((2#${1})))"|bc)
}
function dec-to-bin()
{
    echo "obase=2;${1}" | bc
}
function dec-to-hex()
{
    echo "obase=16;${1}" | bc
}
function hex-to-bin()
{
    echo $(echo "obase=2;$(echo "ibase=16;obase=1010;$(echo ${1}|tr '[a-f]' '[A-F]')"|bc)"|bc)
}
function hex-to-dec()
{
    echo $(echo "ibase=16;obase=1010;$(echo ${1}|tr '[a-f]' '[A-F]')"|bc)
}

# Time conversion
function epoch-to-date()
{
    date -r ${1: 0: 10} +'%Y-%m-%d %H:%M:%S'
}
function date-to-epoch()
{
    date -j -f '%Y-%m-%d %H:%M:%S' "${*}" +'%s'
}

# Case conversion
# capitalize all words
function str-capital-all()
{
    echo "${*}" | sed 's/\b[a-z]/\U&/g'
}
# lowercase all words
function str-lower-all()
{
    echo "${*}" | sed 's/[A-Z]/\L&/g'
}
# uppercase all words
function str-upper-all()
{
    echo "${*}" | sed 's/[a-z]/\U&/g'
}

# Calculate a formula
function calc
{
    python -c "print ${*}"
}

