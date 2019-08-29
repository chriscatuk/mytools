#!/bin/bash

# Exit with error on any error
set -e

# Are all variables set in the environment?
if [ -z "$source_code_path" ] || [ -z "$path_cwd" ] || [ -z "$path_module" ] || [ -z "$runtime" ] || [ -z "$function_name" ] || [ -z "$random_string" ] || [ -z "$lambda_dir_name" ]; then
    echo "At least one of the mandatory environment variable is missing. Exiting with error 1" >&2
    exit 1
fi

echo "***************************************************************************"
echo "*   Creating dir $lambda_dir_name in $path_cwd"
cd $path_cwd
dir_name=$lambda_dir_name
mkdir $dir_name
echo "***************************************************************************"

#virtual env setup
echo "*   Creating virtualenv with runtime $runtime in $path_module"
cd $path_module
virtualenv -p $runtime env-$function_name
source env-$function_name/bin/activate
echo "***************************************************************************"

#installing python dependencies
echo "*   Installing python dependencies..."
FILE=$source_code_path/requirements.txt
if [ -f $FILE ]; then
  echo "requirement.txt file exists in source_code_path. Installing dependencies.."
  pip install -q -r $FILE --upgrade
else
  echo "requirement.txt file does not exist. Skipping installation of dependencies."
fi
echo "***************************************************************************"

#deactivate virtualenv
deactivate
#creating deployment package
echo "*   creating deployment package..."
cd env-$function_name/lib/$runtime/site-packages/
cp -r . $path_cwd/$dir_name
cp -r $source_code_path/ $path_cwd/$dir_name
#removing virtual env folder
echo "*   removing virtual env folder..."
rm -rf $path_module/env-$function_name/
# #add lambda_pkg directory to .gitignore
# echo "*   Adding lambda_pkg directory to .gitignore..."
# GIT_FILE=$path_cwd/.gitignore
# if [ -f $GIT_FILE ]; then
#   echo '#ignore lambda_pkg dir' >> $path_cwd/.gitignore
#   echo $dir_name >> $path_cwd/.gitignore
# else
#   echo '#ignore lambda_pkg dir' > $path_cwd/.gitignore
#   echo $dir_name > $path_cwd/.gitignore

echo "***************************************************************************"
echo "    The Environment is now ready in"
echo "    $dir_name"
echo "***************************************************************************"
