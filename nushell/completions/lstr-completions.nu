def "nu-complete lstr color" [] {
    ['always', 'auto', 'never']
}
export extern lstr [
    path?: path
    --color: string@"nu-complete lstr color" # Specify when to use colorized output
    --level(-L): int  # Maximum depth to descend in the directory tree
    --dirs-only(-d)   # Display directories only
    --size(-s)        # Display the size of files
    --permissions(-p) # Display file permissions
    --all(-a)         # Show all files, including hidden ones
    --gitignore(-g)   # Respect .gitignore and other standard ignore files
    --git-status(-G)  # Show git status for files and directories
    --icons           # Display file-specific icons (requires a Nerd Font)
    --help(-h)        # Print help
    --version(-V)     # Print version
]
