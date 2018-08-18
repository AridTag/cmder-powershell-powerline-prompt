function SignCommitsByAuthor($authorEmail) {
    &git filter-branch --commit-filter 'if [ "$GIT_COMMITTER_EMAIL" = "$(@authorEmail)" ]; then git commit-tree -S "$@"; else git commit-tree "$@"; fi' HEAD
}

Set-Alias -name "gitsigncommits" -value "SignCommitsByAuthor"