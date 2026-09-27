# Enable the Zsh completion system
autoload -Uz compinit && compinit

# Speed up make completion by targeting explicit targets
zstyle ':completion:*:*:make:*' tag-order 'targets'

# Load version control module
autoload -Uz vcs_info

# Load the high-precision time module
zmodload zsh/datetime

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
    echo -e "\n\033[1;33m[ Took ${formatted_time}s ]\033[0m\n"
    
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
          hook_com[staged]="+${staged_count}"
      fi
      if (( untracked_count > 0 )); then
          hook_com[unstaged]="?${untracked_count}"
      fi
  fi
}

# Configure basic vcs_info styles for Git
zstyle ':vcs_info:*' enable git
# %b = branch, %c = staged, %u = unstaged
zstyle ':vcs_info:git:*' formats '%F{cyan}( %F{green}%b %F{yellow}%c %F{red}%u %F{cyan})'
zstyle ':vcs_info:git:*' actionformats '(%b|%a%c%u)'

# Enable checking for staged (%c) and unstaged (%u) changes
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr '+'
zstyle ':vcs_info:git:*' unstagedstr '!'

# Register the custom hook for untracked files into the set-message stage
zstyle ':vcs_info:git*+set-message:*' hooks git-untracked

# Execute vcs_info before drawing the prompt
add-zsh-hook precmd time_taken_info
# Execute vcs_info before drawing the prompt
add-zsh-hook precmd vcs_info

# zstyle ':vcs_info:git:*' formats '(%b)'
# setopt PROMPT_SUBST
# PROMPT='%F{cyan}%~%f %F{green}${vcs_info_msg_0_}%f $ '

# Define your Terminal Prompt (User/Dir on left, Git info on right or next to it)
# %n = username, %m = machine, %~ = current directory
setopt PROMPT_SUBST
# Force a Blinking Bar (Beam) cursor

PROMPT='%n@%m %F{cyan}%~ ${vcs_info_msg_0_} %F{white}$ '
echo -ne '\e[1 q'