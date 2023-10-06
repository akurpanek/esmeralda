
Quelle:

- <https://www.chezmoi.io/quick-start/#concepts>

```shell
# Assuming that you have already installed chezmoi, initialize chezmoi with:
chezmoi init

# Commit changes
chezmoi cd
git add .
git commit -m "Initial commit"

# Push repo
git config credential.helper store
git remote add origin https://github.com/$GITHUB_USERNAME/dotfiles.git
git branch -M main
git push -u origin main
exit

# Add bash-shell files
chezmoi add ~/.bashrc

```
