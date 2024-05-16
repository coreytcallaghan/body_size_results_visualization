import fam from 'taxonomy/family_stats'
// import main from 'data/main'
// function assign (li, name) {
//  li.forEach(x => {
//    seen[x.Family][name] = x.estimate
//  })
// }
// assign(main, 'main')

var seen = fam.reduce((res, x) => {
  res[x.fam] = x
  return res
}, {})

// <!-- A modified version of  https://github.com/jasondavies/newick.js -->
function parseNewick (s) {
  var ancestors = []
  var tree = {}
  var tokens = s.split(/\s*(;|\(|\)|,|:)\s*/)
  for (var i = 0; i < tokens.length; i++) {
    var token = tokens[i]
    switch (token) {
      case '(': // new children
        var subtree = {}
        tree.children = [subtree]
        ancestors.push(tree)
        tree = subtree
        break
      case ',': // another branch
        subtree = {}
        ancestors[ancestors.length - 1].children.push(subtree)
        tree = subtree
        break
      case ')': // optional name next
        tree = ancestors.pop()
        break
      case ':': // optional length next
        break
      default:
        var x = tokens[i - 1]
        if (x === ')' || x === '(' || x === ',') {
          token = token.replace(/_/g, ' ')
          var name = token.replace(/ -.*/, '')
          if (name.match(/ ott[0-9]+$/)) {
            tree.ott = name.match(/ ott([0-9]+)$/)[2]
            name = name.replace(/ ott[0-9]+$/, '')
          }
          tree.name = name
          if (seen[name]) {
            tree.lwr_95 = seen[name].lwr_95 ? seen[name].lwr_95 : 0
            tree.estimate = seen[name].estimate ? seen[name].estimate : 0
            tree.scaled_estimate = seen[name].scaled_estimate ? seen[name].scaled_estimate : 0
            tree.upr_95 = seen[name].upr_95 ? seen[name].upr_95 : 0
          }

          tree.common = token.replace(/.*?-/, '')
        } else if (x === ':') {
          tree.length = parseFloat(token)
        }
    }
  }
  return tree
}
export {
  parseNewick,
  seen
}
