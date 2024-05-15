<template lang="pug">
#over-time
  div(ref="cumulative")
  .ui.divider
  div(ref="oneoff")

</template>

<script>
var species = require('data/corey_new_species_over_time.json')
var submissions = require('data/corey_submissions_over_time.json')

import {plot} from 'plotly.js'

export default {
  name: 'over-time',
  mounted () {
    plot(this.$refs.cumulative, [
      {
        x: species.map(x => x.Year_mon),
        y: species.map(x => x.cumulative),
        type: 'scatter',
        name: 'Cumulative Species'
      },
      {
        x: submissions.map(x => x.Year_mon),
        y: submissions.map(x => x.cumulative),
        type: 'scatter',
        name: 'Cumulative Submissions'
      }
    ], {
      title: 'Coreys cumulative new species and submissions over time.',
      xaxis: {
        rangeslider: {}
      }
    }, {displayModeBar: false})

    plot(this.$refs.oneoff, [
      {
        x: species.map(x => x.Year_mon),
        y: species.map(x => x.species),
        type: 'scatter',
        name: 'Species Observations'
      },
      {
        x: submissions.map(x => x.Year_mon),
        y: submissions.map(x => x.checklists),
        type: 'scatter',
        name: 'Checklists Submitted'
      }
    ], {
      xaxis: {
        rangeslider: {}
      }
    }, {displayModeBar: false})
  }
}
</script>