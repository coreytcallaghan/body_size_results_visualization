
import fam from 'taxonomy/family_stats'

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
            tree.sp_count = seen[name].sp_count
            tree.obs_count = seen[name].obs_count
            tree.bio_count = seen[name].bio_count
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
