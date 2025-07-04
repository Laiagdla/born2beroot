#!/bin/bash
echo -e "\033[1;32m∙∙∙∙∙∙∙∙∙∙\t $1 \t\t\t∙∙∙∙∙∙∙∙∙∙\033[0m"


# tput sc # Save cursor pos
# tput csr 1 $((`tput lines` - 1)) # Change scroll region to exclude first line
# tput cup 0 0 # Move to upper-left corner
# tput el # Clear to the end of the line
# echo -ne "\033[1;32m∙∙∙∙∙∙∙∙∙∙ $1 ∙∙∙∙∙∙∙∙∙∙\033[0m" # Create a header row
# tput rc # Restore cursor position
