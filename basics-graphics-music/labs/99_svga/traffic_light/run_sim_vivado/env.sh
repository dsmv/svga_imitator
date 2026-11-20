
FILE=./env_user.sh
DEFAULT=/tools/Xilinx/Vivado/2023.2/settings64.sh

if [ -f "$FILE" ]; then
    echo "$FILE exists, use it"
    source $FILE
else
    echo "$FILE missing, use default "
    echo   $DEFAULT
    source $DEFAULT
fi


