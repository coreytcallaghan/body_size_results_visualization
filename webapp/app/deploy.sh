#!/usr/bin/env sh

# abort on errors
set -e

# build
npm run bnd

# navigate into the build output directory
cd dist

git init
git add -A
git commit -m 'deploy webapp update'

git push -f git@github.com:<coreytcallaghan>/<body_size_urban_tolerance>.git master:gh-pages

cd -