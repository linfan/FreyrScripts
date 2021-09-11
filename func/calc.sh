# Provide math calculation functions
# [Usage]:
# Use "source" command to load this script.

# Conversion of number system
function bin-to-dec()
{
    ((decNum=2#${1})); echo ${decNum} 
}
function bin-to-hex()
{
    dec-to-hex `bin-to-dec ${1}` 
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
    dec-to-bin `hex-to-dec ${1}`
}
function hex-to-dec()
{
    ((decNum=16#${1})); echo ${decNum}
}

# Time conversion
function epoch-to-date()
{
    date -r ${1} +'%Y-%m-%d %H:%M:%S'
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

