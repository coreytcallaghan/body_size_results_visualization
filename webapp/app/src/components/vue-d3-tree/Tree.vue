<template>
  <div class="treeclass" v-resize="resize">
  </div>
</template>
<script>
import resize from 'vue-resize-directive'
import euclidean from './euclidean-layout'
import circular from './circular-layout'
import radial from './radial-layout'
import {anchorTodx, drawLink, toPromise, findInParents, mapMany, removeTextAndGraph, translate} from './d3-utils'

import * as d3 from 'd3'
import * as d3Hierarchy from 'd3-hierarchy'
import * as d3ScaleChromatic from 'd3-scale-chromatic'
Object.assign(d3, d3Hierarchy, d3ScaleChromatic)

const layout = {
  euclidean,
  circular,
  radial
}

var i = 0
var currentSelected = null
const types = ['tree', 'cluster']
const layouts = ['circular', 'euclidean', 'radial']

const props = {
  data: Object,
  duration: {
    type: Number,
    default: 750
  },
  type: {
    type: String,
    default: 'tree',
    validator (value) {
      return types.indexOf(value) !== -1
    }
  },
  layoutType: {
    type: String,
    default: 'euclidean',
    validator (value) {
      return layouts.indexOf(value) !== -1
    }
  },
  color: {
    type: Function,
    default: d3.scaleOrdinal()
                .domain(['Bacteria', 'Eukaryota', 'Archaea'])
                .range(d3.schemeCategory10)
  },
  marginX: {
    type: Number,
    default: 20
  },
  marginY: {
    type: Number,
    default: 20
  },
  nodeText: {
    type: String,
    required: true
  },
  person: {
    type: String,
    default: 'main'
  },
  identifier: {
    type: Function,
    default: () => i++
  },
  ramp: { // color ramp used for vis, will work for one of these https://github.com/d3/d3-scale-chromatic
    String,
    default: 'interpolateRdYlBu'
  },
  zoomable: {
    type: Boolean,
    default: false
  }
}

const directives = {
  resize
}

function hasChildren (d) {
  return d.children || d._children
}

function getChildren (d) {
  return d.children ? {children: d.children, visible: true} : (d._children ? {children: d._children, visible: false} : null)
}

function onAllChilddren (d, callback, fatherVisible = undefined) {
  if (callback(d, fatherVisible) === false) {
    return
  }
  var directChildren = getChildren(d)
  directChildren && directChildren.children.forEach(child => onAllChilddren(child, callback, directChildren.visible))
}

export default {
  name: 'D3Tree',

  props,

  directives,

  data () {
    return {
      currentTransform: null,
      maxTextLenght: {
        first: 0,
        last: 0
      }
    }
  },

  mounted () {
    const size = this.getSize()
    var svg = d3.select(this.$el).append('svg')
          .attr('width', size.width)
          .attr('height', size.height)
    if (size.width === 400) {
      svg = svg.attr('viewBox', '-300 -270 1000 1000') // kinda a hack to make it more usable on mobile devices
    }

    let g = null
    let zoom = null

    if (this.zoomable) {
      g = svg.append('g')
      zoom = d3.zoom().scaleExtent([0.9, 8]).on('zoom', this.zoomed(g))
      svg.call(zoom).on('wheel', () => d3.event.preventDefault())
      svg.call(zoom.transform, d3.zoomIdentity)
    } else {
      g = this.transformSvg(svg.append('g'), size)
    }

    const tree = this.tree
    this.internaldata = {
      svg,
      g,
      tree,
      zoom
    }

    this.data && this.onData(this.data)
  },

  methods: {
    getSize () {
      var width = this.$el.clientWidth
      var height = this.$el.clientHeight
      return { width, height }
    },

    resize () {
      const size = this.getSize()
      this.internaldata.svg
              .attr('width', size.width)
              .attr('height', size.height)
      this.layout.size(this.internaldata.tree, size, this.margin, this.maxTextLenght)
      this.applyZoom(size)
      this.redraw()
    },

    completeRedraw ({margin = null, layout = null}) {
      const size = this.getSize()
      this.layout.size(this.internaldata.tree, size, this.margin, this.maxTextLenght)
      this.applyTransition(size, {margin, layout})
      this.redraw()
    },

    transformSvg (g, size) {
      size = size || this.getSize()
      return this.layout.transformSvg(g, this.margin, size, this.maxTextLenght)
    },

    updateTransform (g, size) {
      size = size || this.getSize()
      return this.layout.updateTransform(g, this.margin, size, this.maxTextLenght)
    },

    updateGraph (source) {
      let originBuilder = source
      let forExit = source
      if (typeof source === 'object') {
        const origin = {x: source.x0, y: source.y0}
        originBuilder = d => origin
        forExit = d => ({x: source.x, y: source.y})
      }

      const root = this.internaldata.root
      const links = this.internaldata.g.selectAll('.linktree')
         .data(this.internaldata.tree(root).descendants().slice(1), d => d.id)

      const updateLinks = links.enter().append('path').attr('class', 'linktree')
      const node = this.internaldata.g.selectAll('.nodetree').data(root.descendants(), d => d.id)
      const newNodes = node.enter().append('g').attr('class', 'nodetree')
      const allNodes = newNodes.merge(node)

      removeTextAndGraph(node)

      const text = allNodes.append('text')
        .attr('dy', '.35em')
        .text(d => {
          if (!d.data[this.nodeText].match(/ott/)) { // removes labels that are non-order level subclades
            return d.data[this.nodeText]
          }
        })
        .on('click', d => {
          currentSelected = (currentSelected === d) ? null : d
          this.mouseovered(false)(d)
          d3.event.stopPropagation()
          this.redraw()
          this.$emit('clicked', {element: d, data: d.data})
        })
        .on('mouseover', this.mouseovered(true))
        .on('mouseout', this.mouseovered(false))
        .attr('fill', d => {
          return d3[this.ramp](d.data.scaled_estimate)
        })

      // branch coloring
      updateLinks.each(function (d) { d.linkExtensionNode = this })
        .attr('d', d => drawLink(originBuilder(d), originBuilder(d), this.layout))
        .attr('stroke', x => x.color ? x.color : '#AAAAAA')

      const updateAndNewLinks = links.merge(updateLinks)
      const updateAndNewLinksPromise = toPromise(updateAndNewLinks.transition().duration(this.duration).attr('d', d => drawLink(d, d.parent, this.layout)))

      const exitingLinksPromise = toPromise(links.exit().transition().duration(this.duration).attr('d', d => drawLink(forExit(d), forExit(d), this.layout)).remove())

      newNodes.attr('transform', d => translate(originBuilder(d), this.layout))

      allNodes.classed('node--internal', d => hasChildren(d))
        .classed('node--leaf', d => !hasChildren(d))
        .classed('selected', d => d === currentSelected)
        .on('click', this.onNodeClick)

      const allNodesPromise = toPromise(allNodes.transition().duration(this.duration)
        .attr('transform', d => translate(d, this.layout))
        .attr('opacity', 1))
      // the outter circle
      // this is where we color the nodes
      allNodes.append('circle')
        .attr('fill', d => {
          return d3[this.ramp](d.data.scaled_estimate)
        })

      text.attr('x', d => { return d.textInfo ? d.textInfo.x : 0 })
          .attr('dx', function (d) { return d.textInfo ? anchorTodx(d.textInfo.anchor, this) : 0 })
          .attr('transform', d => 'rotate(' + (d.textInfo ? d.textInfo.rotate : 0) + ')')

      const {transformText} = this.layout
      allNodes.each((d) => {
        d.textInfo = transformText(d, hasChildren(d))
      })

      const textTransition = toPromise(text.transition().duration(this.duration)
          .attr('x', d => d.textInfo.x)
          .attr('dx', function (d) { return anchorTodx(d.textInfo.anchor, this) })
          .attr('transform', d => `rotate(${d.textInfo.rotate})`))

      allNodes.each((d) => {
        d.x0 = d.x
        d.y0 = d.y
      })

      const exitingNodes = node.exit()
      const exitingNodesPromise = toPromise(exitingNodes.transition().duration(this.duration)
                  .attr('transform', d => translate(forExit(d), this.layout))
                  .attr('opacity', 0).remove())
      exitingNodes.select('circle').attr('r', 1e6)

      const leaves = root.leaves()
      const extremeNodes = text.filter(d => leaves.indexOf(d) !== -1).nodes()
      const last = Math.max(...extremeNodes.map(node => node.getComputedTextLength())) + 6
      const first = text.node().getComputedTextLength() + 6
      if (last <= this.maxTextLenght.last && first <= this.maxTextLenght.first) {
        return Promise.all([allNodesPromise, exitingNodesPromise, textTransition, updateAndNewLinksPromise, exitingLinksPromise])
      }

      this.maxTextLenght = {first, last}
      const size = this.getSize()
      if (this.zoomable) {
        this.internaldata.svg.call(this.internaldata.zoom.transform, this.currentTransform)
      } else {
        const {g} = this.internaldata
        this.transformSvg(g, size)
      }
      this.layout.size(this.internaldata.tree, size, this.margin, this.maxTextLenght)
      return this.updateGraph(source)
    },

    onNodeClick (d) {
      if (d.children) {
        this.collapse(d)
      } else {
        this.expand(d)
      }
    },
    setColor (d) {
      var name = d.data.name
      d.color = this.color.domain().indexOf(name) >= 0 ? this.color(name) : d.parent ? d.parent.color : null
      if (d.children) d.children.forEach(this.setColor)
    },

    onData (data) {
      if (!data) {
        this.internaldata.root = null
        this.clean()
        return
      }
      const root = d3.hierarchy(data)
        .sum(x => x.children ? 0 : 1)
        .sort((a, b) => {
          return a.length - b.length || d3.ascending(a.data.length, b.data.length)
          // return compareString(a.data.length, b.data.length)
        })
      this.internaldata.root = root
      root.each(d => { d.id = this.identifier(d.data) })
      const size = this.getSize()
      root.x = size.height / 2
      root.y = 0
      root.x0 = root.x
      root.y0 = root.y
      this.setColor(root)
      this.redraw()
    },

    clean () {
      ['.linktree', '.nodetree', 'text', 'circle'].forEach(selector => {
        this.internaldata.g.selectAll(selector).transition().duration(this.duration).attr('opacity', 0).remove()
      })
    },

    redraw () {
      const root = this.internaldata.root
      if (root) {
        return this.updateGraph(root)
      }
      return Promise.resolve('no graph')
    },

    getNodeOriginComputer (originalVisibleNodes) {
      return node => {
        const parentVisible = findInParents(node, originalVisibleNodes)
        return {x: parentVisible.x0, y: parentVisible.y0}
      }
    },

    applyZoom (size) {
      const {g, zoom} = this.internaldata
      if (this.zoomable) {
        g.call(zoom.transform, this.currentTransform)
      } else {
        this.transformSvg(g, size)
      }
    },

    applyTransition (size, {margin, layout}) {
      const {g, svg, zoom} = this.internaldata
      if (this.zoomable) {
        const transform = this.currentTransform
        const oldMargin = margin || this.margin
        const oldLayout = layout || this.layout

        const nowTransform = oldLayout.updateTransform(transform, oldMargin, size, this.maxTextLenght)
        const nextRealTransform = this.updateTransform(transform, size)
        const current = d3.zoomIdentity.translate(transform.x + nowTransform.x - nextRealTransform.x, transform.y + nowTransform.y - nextRealTransform.y).scale(transform.k)

        svg.call(zoom.transform, current).transition().duration(this.duration).call(zoom.transform, transform)
      } else {
        const transitiong = g.transition().duration(this.duration)
        this.transformSvg(transitiong, size)
      }
    },
    mouseovered (active) {
      return function (d) {
        d3.select(this).classed('label-active', active)
        d3.select(d.linkExtensionNode).classed('link-active', active)
        d = d.parent
        while (d) {
          d3.select(d.linkExtensionNode).classed('link-active', active)
          d = d.parent
        }
        // d3.select(d.linkExtensionNode).classed("link-extension--active", active).each(this.moveToFront)
      }
    },

    zoomed (g) {
      return () => {
        const transform = d3.event.transform
        const size = this.getSize()
        const transformToApply = this.updateTransform(transform, size)
        this.currentTransform = transform
        this.$emit('zoom', {transform})
        g.attr('transform', transformToApply)
      }
    },

    updateIfNeeded (d, update) {
      return update ? this.updateGraph(d).then(() => true) : Promise.resolve(true)
    },

    // API
    collapse (d, update = true) {
      if (!d.children) {
        return Promise.resolve(false)
      }

      d._children = d.children
      d.children = null
      this.$emit('retract', {element: d, data: d.data})
      return this.updateIfNeeded(d, update)
    },

    expand (d, update = true) {
      if (!d._children) {
        return Promise.resolve(false)
      }

      d.children = d._children
      d._children = null
      this.$emit('expand', {element: d, data: d.data})
      return this.updateIfNeeded(d, update)
    },

    expandAll (d, update = true) {
      const lastVisible = d.leaves()
      onAllChilddren(d, child => { this.expand(child, false) })
      return this.updateIfNeeded(this.getNodeOriginComputer(lastVisible), update)
    },

    collapseAll (d, update = true) {
      onAllChilddren(d, child => this.collapse(child, false))
      return this.updateIfNeeded(d, update)
    },

    show (d, update = true) {
      const path = d.ancestors().reverse()
      const root = path.find(node => node.children === null) || d
      path.forEach(node => this.expand(node, false))
      return this.updateIfNeeded(root, update)
    },

    showOnly (d) {
      const root = this.internaldata.root
      const path = d.ancestors().reverse()
      const shouldBeRetracted = mapMany(path, p => p.children ? p.children : []).filter(node => node && (path.indexOf(node) === -1))
      const mapped = {}
      shouldBeRetracted.filter(node => node.children)
                      .forEach(rectractedNode => rectractedNode.each(c => { mapped[c.id] = rectractedNode }))
      const origin = node => {
        const reference = mapped[node.id]
        return {x: reference.x, y: reference.y}
      }
      const updater = node => {
        if (shouldBeRetracted.indexOf(node) !== -1) {
          this.collapse(node, false)
          return false
        }
        return (node !== d)
      }
      onAllChilddren(root, updater)
      return this.updateGraph(origin).then(() => true)
    },

    resetZoom () {
      if (!this.zoomable) {
        return Promise.resolve(false)
      }
      const {svg, zoom} = this.internaldata
      const transitionPromise = toPromise(svg.transition().duration(this.duration).call(zoom.transform, () => d3.zoomIdentity))
      return transitionPromise.then(() => true)
    }
  },

  computed: {
    tree () {
      const size = this.getSize()
      const tree = this.type === 'cluster' ? d3.cluster() : d3.tree()
      this.layout.size(tree, size, this.margin, this.maxTextLenght)
      return tree
    },

    margin () {
      return {x: this.marginX, y: this.marginY}
    },

    layout () {
      return layout[this.layoutType]
    }
  },

  watch: {
    data (current, old) {
      this.onData(current)
    },

    type () {
      if (!this.internaldata.tree) {
        return
      }
      this.internaldata.tree = this.tree
      this.redraw()
    },

    person () {
      if (!this.internaldata.tree) {
        return
      }
      this.redraw()
    },

    marginX (newMarginX, oldMarginX) {
      this.completeRedraw({margin: {x: oldMarginX, y: this.marginY}})
    },

    marginY (newMarginY, oldMarginY) {
      this.completeRedraw({margin: {x: this.marginX, y: oldMarginY}})
    },

    layout (newLayout, oldLayout) {
      this.completeRedraw({layout: oldLayout})
    }
  }
}
</script>