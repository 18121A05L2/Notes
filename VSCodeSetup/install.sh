#!/bin/bash
echo "Installing VS Code Extensions..."
cat extensions.txt | xargs -L 1 code --install-extension
echo "Done."