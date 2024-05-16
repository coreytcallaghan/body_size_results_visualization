<template lang="pug">
#app
  my-menu
  phylo-tree
</template>

<script>
import PhyloTree from './components/PhyloTree'
import MyMenu from './components/MyMenu'
export default {
  name: 'app',
  components: {
    PhyloTree,
    MyMenu
  }
}
</script>

<style>
@import './assets/introjs.css'
</style>
