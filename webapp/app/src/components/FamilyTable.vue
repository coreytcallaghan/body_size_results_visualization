<template lang="pug">
#family-table
  h1.ui.center.aligned.header Observations per Family table
  table.ui.celled.center.aligned.padded.table
    thead
      th Order
      th Family
      th Number of Species Analysed
      th Number of Biomes Analysed

    tr(v-for="f in fam")
      td {{f.Order}}
      td {{f.Family}}
      td {{f.sp_count}}
      td {{f.bio_count}}
</template>

<script>
var fam = require('taxonomy/family_stats.json')
export default {
  name: 'family-table',
  data: () => {
    return {
      fam: fam
    }
  }
}
</script>