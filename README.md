## Update kubectl

This script installs (or updates) [kubectl](https://kubernetes.io/docs/tasks/tools/).

### Usage
My home directory structure looks like this:
```
$HOME
└─── .local
    ├── bin
    ├── lib
    │   ├── python
    │   ├── shell
    │   └── venv
    ├── man
    │   └── man1
    ├── share
    │   ├── doc
    │   ├── man
    │   └── ykman
    └── src
        ├── aws-cli
        ├── fzf
        └── lesspipe
```

Where `$HOME/.local/bin` is the first or second entry in `$PATH` depending if I'm running homebrew.

If your home directory structure differs, you can edit the variables at the top of the script to match your system.

Just run the script to install or update kubectl:
```
./update-kubectl.sh
```

Follow the directions for installing the tab auto completions:
- Linux: https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#enable-shell-autocompletion
- Mac: https://kubernetes.io/docs/tasks/tools/install-kubectl-macos/#enable-shell-autocompletion
