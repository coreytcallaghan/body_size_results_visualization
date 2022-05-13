#!/usr/bin/env sh

# abort on errors
set -e

# build
npm run build

# navigate into the build output directory
cd dist

git init
git add -A
git commit -m 'New app deployment'

git push -f git@github.com:<coreytcallaghan>/<body_size_results_visualization>.git master:gh-pages

cd -