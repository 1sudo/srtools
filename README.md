# srtools

A bash alias can be created for quick access to SRTools. Edit `~/.bashrc` adding the following to the bottom:
```
alias srtools="~/.scripts/srtools/srtools.sh"
```

A file in the `~/.scripts` directory should contain the following information (with your own repo details):
```
# Set your Git protocol and site
protocol="https"
git_site="github.com"

# Set your Core3 repo information
export core3_repo_user="your_github_username"
export core3_repo_name="Core3"
export core3_repo_branch="master"

# Set your Engine repo information
export engine_repo_user="your_github_username"
export engine_repo_name="engine3"
export engine_repo_branch="master"

export core3_repo_url="$protocol://$git_site/$core3_repo_user/$core3_repo_name.git"
export engine_repo_url="$protocol://$git_site/$engine_repo_user/$engine_repo_name.git"
```
