var ghpages = require('gh-pages')


console.log("deploying")
ghpages.publish('dist', {
    repo: 'git@github.com:coreytcallaghan/body_size_results_visualization.git'
}, () => {
    console.log('deployed')
})

