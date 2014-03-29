#!/bin/bash
SCRIPT_DIR="$(dirname $0)"
ORIGINAL_DIR="$(pwd)"
DIR_PATH='.'
ANSIBLE_ROLES=()
ROLES_ONLY=false

# Directory layout according to http://docs.ansible.com/playbooks_best_practices.html
# production                # inventory file for production servers
# stage                     # inventory file for stage environment

# group_vars/
#    group1                 # here we assign variables to particular groups
#    group2                 # ""
# host_vars/
#    hostname1              # if systems need specific variables, put them here
#    hostname2              # ""

# site.yml                  # master playbook
# webservers.yml            # playbook for webserver tier
# dbservers.yml             # playbook for dbserver tier

# roles/
#     common/               # this hierarchy represents a "role"
#         tasks/            #
#             main.yml      #  <-- tasks file can include smaller files if warranted
#         handlers/         #
#             main.yml      #  <-- handlers file
#         templates/        #  <-- files for use with the template resource
#             ntp.conf.j2   #  <------- templates end in .j2
#         files/            #
#             bar.txt       #  <-- files for use with the copy resource
#             foo.sh        #  <-- script files for use with the script resource
#         vars/             #
#             main.yml      #  <-- variables associated with this role

#     webtier/              # same kind of structure as "common" was above, done for the webtier role
#     monitoring/           # ""
#     fooapp/               # ""
function init_ansible_directory_structure()
{
    if [[ ! -n "$1" ]]; then
        echo "No path supplied, please try again"
        return
    fi
    # create directory structure
    mkdir -p ${1}/{group_vars,host_vars,roles}

    # create production inventory file
    create_empty_file "$1" "production"
    # create production inventory file
    create_empty_file "$1" "stage"

    # add .gitkeep to the directories
    for i in group_vars host_vars; do
        if [[ ! -f ${1}/${i}/.gitkeep ]]; then
        echo creating file:  ${1}/${i}/.gitkeep
        echo "" > ${1}/${i}/.gitkeep
        else
            echo ${1}/${i}/.gitkeep exists skipping
        fi
    done

    # create the master playbook
    create_yaml_file "$1" "site.yml"

    # create the common role
    for i in "${ANSIBLE_ROLES[@]}"; do
      init_ansible_role "$1" "${i}"
    done

}

function create_yaml_file()
{
    if [[ ! -n "$1" ]]; then
        echo "No path supplied, please try again"
        return
    fi
    local FILE_PATH="$1"
    local FILE_NAME="$2"
    : ${FILE_NAME:="default.yml"}

    if [[ ! -f ${FILE_PATH}/${FILE_NAME} ]]; then
        echo "Creating file:  ${FILE_PATH}/${FILE_NAME}"
        echo "---
# Default Ansible YAML
" > ${FILE_PATH}/${FILE_NAME}
        else
            echo "${FILE_PATH}/${FILE_NAME} exists skipping"
        fi
}

function create_empty_file()
{
    if [[ ! -n "$1" ]]; then
        echo "No path supplied, please try again"
        return
    fi
    local FILE_PATH="$1"
    local FILE_NAME="$2"
    : ${FILE_NAME:="default"}

    if [[ ! -f ${FILE_PATH}/${FILE_NAME} ]]; then
        echo "Creating file:  ${FILE_PATH}/${FILE_NAME}"
        echo "" > ${FILE_PATH}/${FILE_NAME}
        else
            echo "${FILE_PATH}/${FILE_NAME} exists skipping"
        fi
}

# found this in https://gist.github.com/zircote/8640585
# modified it to accept the path and role name, setup role name default and add .gitkeep where needed
function init_ansible_role()
{
  if [[ ! -n "$1" ]]; then
      echo "No path supplied, please try again"
      return
  fi
  local ROLE_PATH="$1"
  local ROLE_NAME="$2"
  : ${ROLE_NAME:="common"}

  mkdir -p ${ROLE_PATH}/roles/${ROLE_NAME}/{defaults,tasks,files,templates,vars,handlers,meta}
  for i in defaults tasks vars handlers meta; do
      create_yaml_file "$ROLE_PATH/roles/${ROLE_NAME}/${i}" "main.yml"
  done

  for i in templates files; do
      create_empty_file "$ROLE_PATH/roles/${ROLE_NAME}/${i}" ".gitkeep"
  done
}

function usage()
{
cat << EOF
usage: $0 options [ ANSIBLE_DIRECTORY_PATH ]

This script will help with ansible directory structures.
If ANSIBLE_DIRECTORY_PATH is supplied the script will use it as base path,
otherwise it assumes operation in current directory.

OPTIONS:
   -i      Show this message
   -r      Specify the roles you want created
   -o      Create supplied roles only, running with this argument without specified roles will create a common role only
EOF
}


while getopts "ihp:r:o" OPTION
do
     case "$OPTION" in
          "p")
            DIR_PATH="$OPTARG"
            [ "${DIR_PATH/#\//}" != "$DIR_PATH" ] || DIR_PATH="$SCRIPT_DIR/$DIR_PATH"
            [ "${DIR_PATH/#\//}" != "$DIR_PATH" ] || DIR_PATH="$ORIGINAL_DIR/$DIR_PATH"
            [ ${DIR_PATH:0:1} != "/" ]
              DIR_PATH=${DIR_PATH%/}
            ;;
          "r")
            ANSIBLE_ROLES+=("${OPTARG}")
            ;;
          "o")
            ROLES_ONLY=true
            ;;
          ?)
            usage
            exit
            ;;
     esac
done

if [ ${#ANSIBLE_ROLES[@]} -eq 0 ]; then
    ANSIBLE_ROLES=("common")
fi

if [ "$ROLES_ONLY" = true ] ; then

  for i in "${ANSIBLE_ROLES[@]}"; do
    init_ansible_role "$DIR_PATH" "${i}"
  done
else
  init_ansible_directory_structure "$DIR_PATH" "$ANSIBLE_ROLES"
fi

# echo $DIR_PATH
# init_ansible_directory_structure "$DIR_PATH"
# usage

# #!/bin/bash

# LOREM_PIXEL_URL='http://lorempixel.com'
# WIDTH='800'
# HEIGHT='600'
# REPEAT='1'
# DRY_RUN=false
# VERBOSE='-nv'
# CATEGORY='0'

# URL=$LOREM_PIXEL_URL

# IMAGE_NAME='image'

# usage()
# {
# cat << EOF
# usage: $0 options

# This script will download an image from the lorempixel.com with set width and height.

# OPTIONS:
#    -i      Show this message
#    -w      Width of the image, if ommited the default value of $WIDTH is used
#    -h      Height of the image, if ommited the default value of $HEIGHT is used
#    -c      category of the image, categories are: abstract, animals, city, food, nightlife, fashion, people, nature, sports, technics, transport
#    -r      How many images do you need, aka how many times to repeat the process, default is $REPEAT
#    -v      verbose mode
#    -d      Dry run, testing purposes only
# EOF
# }

# while getopts â€œitgtdtvt:w:h:r:c:â€ OPTION
# do
#      case $OPTION in
#          help)
#              usage
#              exit 1
#              ;;
#          w)
#              WIDTH=$OPTARG
#              ;;
#          h)
#              HEIGHT=$OPTARG
#              ;;
#          r)
#              REPEAT=$OPTARG
#              ;;
#          c)
#              CATEGORY=$OPTARG
#              ;;
#          g)
#              URL=$LOREM_PIXEL_URL'/greyscale'
#              IMAGE_NAME='image-greyscale'
#              ;;
#          v)
#              VERBOSE=''
#              ;;
#          d)
#              DRY_RUN=true
#              ;;
#          ?)
#              usage
#              exit
#              ;;
#      esac
# done


# ITERATION='0'

# while [ $ITERATION -lt $REPEAT ]
# do
#   WGET_URL="$URL/$WIDTH/$HEIGHT/$CATEGORY"

#   WGET_IMAGE=$IMAGE_NAME

#   if [[ $CATEGORY != '0' ]];
#     then
#     WGET_IMAGE=$WGET_IMAGE'-'$CATEGORY
#   fi

#   WGET_IMAGE=$WGET_IMAGE'-'$WIDTH'-'$HEIGHT

#   if [ $REPEAT -gt '1' ];
#     then
#     WGET_IMAGE=$WGET_IMAGE'-'$[$ITERATION+1]
#   fi

#     WGET_IMAGE=$WGET_IMAGE'.jpg'

#   if [ $DRY_RUN == true ];
#     then
#     echo $WGET_URL' -> '$WGET_IMAGE
#     else
#     wget -O $WGET_IMAGE $WGET_URL $VERBOSE
#   fi

#   ITERATION=$[$ITERATION+1]
# done



