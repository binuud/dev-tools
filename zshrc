# Enable the Zsh completion system
autoload -Uz compinit && compinit

# Enable zsh hooks
autoload -U add-zsh-hook

# Speed up make completion by targeting explicit targets
zstyle ':completion:*:*:make:*' tag-order 'targets'

# Load version control module
autoload -Uz vcs_info

# Load the high-precision time module
zmodload zsh/datetime


# Define Colors (ANSI 256-color)
COLOR_GIT_BG="012"      # Green
COLOR_GIT_FG="0"      # Dark Charcoal
COLOR_PATH_BG="014"     # cyan
COLOR_PATH_FG="0"     # White
COLOR_USER_BG="004"     # Blue
COLOR_USER_FG="0"     # White
COLOR_RESET="%f%k"

# Powerline arrow symbols
ARROW_RIGHT=$'\uE0B0'

function preexec() {
  # Record the start time in seconds.microseconds
  G_DEV_TOOLS_CMD_START=$EPOCHREALTIME
}

# Caculates the time taken for a command
# and displays same after command execution
function time_taken_info() {
  # Display time taken
  if [ -n "$G_DEV_TOOLS_CMD_START" ]; then
    # Calculate duration
    local cmd_end=$EPOCHREALTIME
    local elapsed=$(( cmd_end - G_DEV_TOOLS_CMD_START ))
    
    # Format to seconds and milliseconds (3 decimal places)
    local formatted_time=$(printf "%.3f" $elapsed)
    
    # Print the execution time in yellow text
    #echo -e "\n\033[1;33m[ \ue641 Took ${formatted_time}s ]\033[0m\n"
    echo -e "\n\033[0;33m[ \ue641 Took ${formatted_time}s ]\033[0m\n"
    
    unset G_DEV_TOOLS_CMD_START
  fi
}


# Define the hook function (Must use the '+vi-' prefix)
function +vi-git-untracked() {
  # Ensure we are inside a git repo to prevent errors
  if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' ]]; then
      local status_output staged_count untracked_count

      # Get git status output once to save performance
      status_output=$(git status --porcelain 2> /dev/null)

      # Count lines starting with M, A, D, R, C in the first column (Staged)
      staged_count=$(echo "$status_output" | grep -c '^ [MADRC]')
      
      # Count lines starting with ?? (Untracked)
      untracked_count=$(echo "$status_output" | grep -c '^\??')

      # Append the counts to the vcs_info message if they are greater than 0
      if (( staged_count > 0 )); then
          hook_com[staged]=" +${staged_count}"
      fi
      if (( untracked_count > 0 )); then
          hook_com[unstaged]=" ?${untracked_count}"
      fi
  fi
}

function build_prompt() {

  # Define your Terminal Prompt (User/Dir on left, Git info on right or next to it)
  
  # %n = username, %m = machine, %~ = current directory
  prompt_str="%K{$COLOR_USER_BG}%F{$COLOR_USER_FG} %n@%m "
  
  # add git status
  prompt_str+="${vcs_info_msg_0_}"

  # add path details
  prompt_str+="%K{$COLOR_PATH_BG}%F{$COLOR_PATH_FG} %~ %k%F{cyan}$ARROW_RIGHT $COLOR_RESET "

  echo -n "$prompt_str"
}

# Configure basic vcs_info styles for Git
zstyle ':vcs_info:*' enable git
# %b = branch, %c = staged, %u = unstaged
zstyle ':vcs_info:git:*' formats "%K{$COLOR_GIT_BG}%F{$COLOR_GIT_FG}  %b%c%u  %k%f"
zstyle ':vcs_info:git:*' actionformats '(%b|%a%c%u)'

# Enable checking for staged (%c) and unstaged (%u) changes
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr '+'
zstyle ':vcs_info:git:*' unstagedstr '!'

# Register the custom hook for untracked files into the set-message stage
zstyle ':vcs_info:git*+set-message:*' hooks git-untracked

# Execute time taken
add-zsh-hook precmd time_taken_info
# Execute vcs_info before displayinh the prompt
add-zsh-hook precmd vcs_info

setopt PROMPT_SUBST

# Set the prompt
PROMPT="\$(build_prompt)"

# Force a Blinking Bar (Beam) cursor
echo -ne '\e[1 q'