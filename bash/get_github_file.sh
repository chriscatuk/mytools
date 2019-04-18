#!/bin/bash
# Copy locally a file from github

    #   # Copy file from github
    #   ./get_github_file.sh -v \
    #     --repo   git@github.com:ABC/sys_cfg.git \
    #     --key    ./key.pem \
    #     --source proxy.pac \
    #     --dest   /usr/share/nginx/html/proxy.pac \
    #     --branch master
    #   #exec immediatly
    #   $($proxypac_cmd)
      
    #   chmod a+r  /usr/share/nginx/html/proxy.pac


export version=2019-04-16.01
export verbose=0

# Output the message to standard error as well as to the system log.
function cjg_logerror() {
    logger -s "[DNS Check][Error] $1" -p user.err
}
function cjg_logdebug() {
    if [ "$verbose" -ne 0 ] ; then
        logger -s "[DNS Check][Debug] $1" -p user.debug
    fi
}

function showHelp() {
cat << EOF  

    Usage: $0 -r <repo> [-b <branch>] [-k <sshkey>] -s <file_path> [-d <destination_path>] [--verbose] [--help] 
    Example: $0 -r "git@github.com:ABC/sys_appname_cfg.git" -s "rep1/file.html" -d "/usr/share/nginx/html/index.html"
    (version: $version)

    Pre-requisites: logger, curl, wget, git

    -h, --help                       Display help

    -v, --verbose                    Run script in verbose mode. Will print out each step of execution.

    -r <repo>, --repo                Github Repository Ex: git@github.com:ABC/sys_appname_cfg.git
    -b <branch>, --branch            Optional. Name of the branch. master by default. Ex: develop
    -k <sshkey>, --key               Optional. Path to the file containing the private key for read access to github.
                                     Default: ~/.ssh/github_readonly

    -s <file_path>, --source         Path to the file to get from the repository
    -d <destination_path>, --dest    Optional. If absent, the script use local path

EOF
}

# Pre Req Check
# Check if required commands are installed
for item in logger \
                git \
                wget \
                curl
    do
        command -v "$item" > /dev/null || \
            { cjg_logerror "requires {$item} but it's not installed. Aborting."; exit 1; }
    done


# Options of the script
export param_repo=""
export param_branch=""
export param_key=""
export param_source=""
export param_dest=""
options=$(getopt -l "help,verbose,repo:,branch:,key:,source:,dest:" -o "hvr:b:k:s:d:" -a -- "$@")
eval set -- "$options"
while  true
do
    case $1 in
        -h|--help)
            showHelp $0
            exit 0
            ;;
        -v|--verbose)
            shift
            export verbose=1
            #set -xv  # Set xtrace and verbose mode.
            ;;
        -r|--repo)
            shift
            export param_repo=$1
            shift
            ;;
        -b|--branch)
            shift
            export param_branch=$1
            shift
            ;;
        -k|--key)
            shift
            export param_key=$1
            shift
            ;;
        -s|--source)
            shift
            export param_source=$1
            shift
            ;;
        -d|--dest)
            shift
            export param_dest=$1
            shift
            ;;
        --)
            shift
            break;;
        ?)
            showHelp $0
            exit 1
            ;;
    esac
done
# export param_repo=""
# export param_branch=""
# export param_key=""
# export param_source=""
# export param_dest=""
if [ -z "$param_branch" ]; then
    cjg_logdebug "Branch is set to default value: master"
    param_branch="master"
fi
if [ -z "$param_key" ]; then
    cjg_logdebug "Key is set to default value: ~/.ssh/github_readonly"
    param_key="~/.ssh/github_readonly"
fi
if [ -z "$param_dest" ]; then
    cjg_logdebug "Destination is set to default value: ./"
    param_dest="./"
fi
if [ -z "$param_repo" ] || [ -z "$param_branch" ] || [ -z "$param_key" ] || [ -z "$param_source" ] || [ -z "$param_dest" ]; then
    cjg_logerror "At least one of the mandatory options is missing"
    showHelp $0
    exit 2
fi

cjg_logdebug "**************************************"
cjg_logdebug "* script starting with following values"
cjg_logdebug "* repo:   $param_repo"
cjg_logdebug "* branch: $param_branch"
cjg_logdebug "* key:    $param_key"
cjg_logdebug "* source: $param_source"
cjg_logdebug "* dest:   $param_dest"
cjg_logdebug "**************************************"

# Creating Temp folder for cloning
    cjg_logdebug "* Creating Github Temp folder for cloning"
    temp_dir=$(mktemp -d)
    if [ "$?" -ne 0 ] || [ -z "$temp_dir" ] ; then
        cjg_logerror "Can't create a temporary folder. Aborting";
        cjg_logdebug "Command Result: $temp_dir"
        exit 1;
    fi
    cjg_logdebug "* Temporary folder created: $temp_dir"

    mkdir -p $temp_dir/github
    if [ "$?" -ne 0 ]; then
        cjg_logerror "Can't create the temporary folder $temp_dir/github. Aborting";
        rm -rf $temp_dir
        exit 1;
    fi
    cjg_logdebug "* Temporary folder created: $temp_dir/github"

# Github clone
    cjg_logdebug "**************************************"
    cjg_logdebug "* Github cloning"
    ssh-agent bash -c "ssh-add $param_key; git clone --depth 1 -b $param_branch $param_repo ${temp_dir}/github"
    if [ "$?" -ne 0 ]; then
        cjg_logerror "Can't clone the repo. Aborting";
        rm -rf $temp_dir
        exit 1;
    fi
    cjg_logdebug "* Repo cloned in: $temp_dir/github"
    cjg_logdebug "**************************************"

# Copy file to destination
    cjg_logdebug "* Copying to nginx homedir"
    cp "$temp_dir/github/$param_source" "$param_dest"
    if [ "$?" -ne 0 ]; then
        cjg_logerror "Can't copy '$temp_dir/github/$param_source' to '$param_dest'. Aborting";
        rm -rf $temp_dir
        exit 1;
    fi
    cjg_logdebug "* Copied at: $param_dest"
    cjg_logdebug "**************************************"

# Delete the temporary folder
    rm -rf $temp_dir
    if [ "$?" -ne 0 ]; then
        cjg_logerror "Can't delete the temporary folder $temp_dir. But copy was already done.";
        exit 1;
    fi
    cjg_logdebug "* Temporary folder removed: $temp_dir"
