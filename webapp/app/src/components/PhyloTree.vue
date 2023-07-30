<template lang="pug">
div
  tree.tree(
    :data="treeData" 
    layoutType="radial"
    type="cluster"
    :duration="50"
    nodeText="name"
    :margin-x="0"
    :margin-y="0"
    :person="selectedPerson"
    v-on:clicked="clicked"
    data-step="2"
    data-intro="This is a family-level phylogeny. You can click on the names at each tip of the tree to learn more about each family and our model results."
    )

  .ui.raised.container.segment
    my-header(v-bind:main="selectedLeaf ? selectedLeaf : 'Select a Node to View Summary'", 
              v-bind:sub="common")
    .ui.divider(v-if="selectedTree === 'main'")
    table.ui.center.aligned.single.line.table(v-if="selectedTree === 'main'")
      thead
        tr
          th Lower Bound (95% CRI)
          th Mean Estimated Effect
          th Upper Bound (95% CRI)
      tbody
        tr
          td {{ people.lwr_95 }}
          td {{ people.estimate }}
          td {{ people.upr_95 }}
    .ui.horizontal.divider(v-if="selectedLeaf")#summary Summary
    wiki-summary(:selected="selectedLeaf")
  attribution
</template>

<script>
// Components
import {tree} from './vue-d3-tree'
import WikiSummary from './WikiSummary'
import attribution from './Attribution'
import myHeader from './Header'
// Tree data
import rawTrees from 'tree/trees'
// think of a better name
var parseNewick = require('./parseNewick')

var trees = {}
Object.keys(rawTrees).forEach(x => {
  trees[x] = parseNewick.parseNewick(rawTrees[x])
})

export default {
  name: 'phylo-tree',
  data () {
    return {
      treeData: trees.main,
      selectedPerson: 'main',
      selectedLeaf: '',
      people: {
        lwr_95: 0,
        estimate: 0,
        upr_95: 0
      },
      selectedTree: 'main',
      seen: parseNewick.seen
    }
  },
  methods: {
    clicked: function (x) {
      var d = this.seen[x.data.name]
      if (d) {
        this.people.lwr_95 = this.seen[x.data.name].lwr_95
        this.people.estimate = this.seen[x.data.name].estimate
        this.people.upr_95 = this.seen[x.data.name].upr_95
      }

      this.$scrollTo('#summary')

      this.selectedLeaf = x.data.name
    },
    notNullColor (d) {
      return x => '#F00'
      // d3.scaleOrdinal()
         //  .domain(['Bacteria', 'Eukaryota', 'Archaea'])
         //  .range(d3.schemeCategory10)
    }
  },
  watch: {
    selectedTree (newValue) {
      this.selectedLeaf = ''
      this.treeData = trees[newValue]
    }
  },
  computed: {
    common () {
      var d = this.seen[this.selectedLeaf]
      if (d) {
        return 'Higher Taxonomy: ' + d.Order + '
      }
      return ''
    }
  },
  components: {
    tree,
    attribution,
    WikiSummary,
    myHeader
  }
}
</script>

<style>
label {
  padding-right: 1em;
}
.tree {
  margin: 0 auto;
  height: 950px;
  width: 1000px;
}

@media (max-width: 600px) {
  .tree {
    height: 400px;
    width: 400px;
  }
}
.treeclass .nodetree  circle {
  r: 3;
}

.treeclass .node--internal circle {
  r: 0;
  font: 0px;
}

.link-active {
  opacity: 1;
  stroke: #000;
  stroke-width: 3px !important;
}
.treeclass .nodetree text {
  font: 10px sans-serif;
  cursor: pointer;
}
.treeclass .nodetree text:hover {
  font-weight: bold;
  background-color: #FFF;
  display: block;
}


.treeclass .nodetree.selected text {
  font-weight: bold;
  font-size: 1em;
}

.treeclass .linktree {
  fill: none;
  stroke-opacity: 0.6;
  stroke-width: 1.5px;
}

th {
  cursor: pointer !important;
}

.positive {
  color: #acdfb7 !important;
}
</style>
