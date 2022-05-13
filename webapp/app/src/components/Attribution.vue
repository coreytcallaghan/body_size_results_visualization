<template lang="pug">
.ui.one.column.wide.center.aligned.page.padded.grid#attribution
  .column
    .ui.horizontal.divider Attribution
    p Text and Images: 
      a(href="https://en.wikipedia.org/wiki/Main_Page") Wikipedia,  
      | Trees: 
      a(href="http://tree.opentreeoflife.org/") Open Tree of Life
    p Inspired by: 
      a(href="https://bl.ocks.org/mbostock/c034d66572fd6bd6815a") Tree of Life
      |  and 
      a(href="https://coreytcallaghan.github.io/eBirder-visualizations/") Family Birding Visualizer
    p Developed by:
      |  Original code was developed by John Wilshire and adapted for this project by Vaughn Shirey and Corey Callaghan
</template>
<script>
export default {
  name: 'attribution'
}
</script>

<style>
.sources {
  text-align: center;
}
</style>