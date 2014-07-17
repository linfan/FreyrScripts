# Provide "flushUserAppFolders" and "getPrefix" command
# [Usage]:
# Use "source" command to load this script.
# [Commands]:
# 1) flushUserAppFolders
# Add applications under user app folder to corresponding variables
# (PATH, LD_LIBRARY_PATH, C_INCLUDE_PATH, CPLUS_INCLUDE_PATH, MANPATH).
# 2) getPrefix
# Get prefix parameter for configure or cmake to install application
# to user app folder.

# check if the given path is already part of given variable
# ${1}: variable content
# ${2}: path to check
function isPathInVariable()
{
    if [[ "`echo \"${1}\" | ggrep -o \":${2}:\"`" == "" &&
          "`echo \"${1}\" | ggrep -o \"^${2}:\"`" == "" &&
          "`echo \"${1}\" | ggrep -o \":${2}$\"`" == "" ]]; then
        echo "N"
    else
        echo "Y"
    fi
}

# export new path to variable if not exist
# ${1}: variable name
# ${2}: value to append
# ${3}: [optional] original value
function exportPathOnce()
{
    if [ "${3}" == "" ]; then
        if [ `isPathInVariable "${!1}" "${2}"` == "N" ]; then
            if [ "${!1}" == "" ]; then
                export $"${1}"=${2}
            else
                export $"${1}"=${2}:${!1}
            fi
        fi
    else
        if [ `isPathInVariable "${3}" "${2}"` == "N" ]; then
            export $"${1}"=${2}:${3}
        fi
    fi
}

# export path to variable only if specified path exist and is folder
# ${1}: variable name
# ${2}: folder to append
# ${3}: original variable value
function exportFolderOnce()
{
    if [ -d "${2}" ]; then
        exportPathOnce "${1}" "${2}" "${3}"
    fi
}

# export user specified applications to system path
# ${1}: root folder to user applications
function exportUserPath()
{
    base_folder="${1}"
    # ignore folder end with _OFF
    for folder in `ls "${base_folder}" | ggrep -v '_OFF$'`; do
        #echo "[DEBUG] Got ${app_folder}"
        app_folder="${base_folder}${folder}"
        if [ -d ${app_folder} ]; then
            exportFolderOnce PATH ${app_folder}/bin
            exportFolderOnce PATH ${app_folder}/sbin
            exportFolderOnce LD_LIBRARY_PATH ${app_folder}/lib
            exportFolderOnce LD_LIBRARY_PATH ${app_folder}/lib64
            exportFolderOnce C_INCLUDE_PATH ${app_folder}/include
            exportFolderOnce CPLUS_INCLUDE_PATH ${app_folder}/include
            if [ "${MANPATH}" == "" ]; then
                exportFolderOnce MANPATH ${app_folder}/share/man `manpath`
            else
                exportFolderOnce MANPATH ${app_folder}/share/man
            fi
        fi
    done
}

# remove items begin with specified prefix from a variable
# ${1}: path variable to tackle
# ${2}: prefix to match
function removeItemsByPrefix()
{
    echo ${1} | gsed -e "s#${2}[^:]*##g" -e "s#[:]\+#:#g" -e "s#^:##g" 
}

APP_FOLDER="${HOME}/Apps/"

# update the user application folder to system paths
# ${1}: [optional] folder content user applications, default is "${HOME}/app/"
function flushUserAppFolders()
{
    base_folder="${APP_FOLDER}"
    export PATH=`removeItemsByPrefix "${PATH}" "${base_folder}"`
    export LD_LIBRARY_PATH=`removeItemsByPrefix "${LD_LIBRARY_PATH}" "${base_folder}"`
    export C_INCLUDE_PATH=`removeItemsByPrefix "${C_INCLUDE_PATH}" "${base_folder}"`
    export CPLUS_INCLUDE_PATH=`removeItemsByPrefix "${CPLUS_INCLUDE_PATH}" "${base_folder}"`
    export MANPATH=`removeItemsByPrefix "${MANPATH}" "${base_folder}"`
    exportUserPath "${base_folder}"
}

# return a string like --prefix=${HOME}/app/app-name-version
# ${1}: use "cmake" if want to get cmake-style prefix parameter
function getPrefix()
{
    cur_folder=`pwd`
    cur_folder=${cur_folder##*/}
    if [ "${1}" == "cmake" ]; then
        echo "-DCMAKE_INSTALL_PREFIX=${APP_FOLDER}/${cur_folder}"
    else
        echo "--prefix=${APP_FOLDER}/${cur_folder}"
    fi
}

