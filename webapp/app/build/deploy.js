var ghpages = require('gh-pages')


console.log("deploying")
ghpages.publish('dist', {
    repo: 'git@github.com:coreytcallaghan/eBirder-visualizations.git'
}, () => {
    console.log('deployed')
})

