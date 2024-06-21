<template lang="pug">
#family-table
  h1.ui.center.aligned.header Observations per Family table
  table.ui.celled.center.aligned.padded.table
    thead
      th Order
      th Family
      th Species Name
      th Number of species in this Family

    tr(v-for="f in fam")
      td {{f.Order}}
      td {{f.Family}}
      td {{f.gs}}
      td {{f.sp_count}}
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