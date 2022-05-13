<template lang="pug">
.ui.basic.segment(v-bind:class="{ loading: loading }" v-if="selected")
  .ui.stackable.two.column.grid
    .column
      .ui.rounded.fluid.image
        img(:src="imageUrl")
        .ui.bottom.attached.label(v-if="imageUrl")
          | {{ info ? (info.imageCaption ? info.imageCaption : selected) : 'No caption found.' }}
    .column(:style="[ imageUrl ? '' : 'two wide' ]")
      p(v-if="text") {{ text }}
      p(v-if="!text") No Wikipedia article found for 
        b {{selected}} &#x1F622
</template>

<script>
import wiki from 'wikijs'
var wikiApi = wiki({apiUrl: 'https://en.wikipedia.org/w/api.php'})
export default {
  name: 'wiki-summary',
  props: ['selected'],
  watch: {
    selected () {
      this.loading = true
    },
    imageUrl () {
      console.log('image watch called')
      if (Array.isArray(this.imageUrl)) {
        var filtered = this.imageUrl.filter(img => img.match(new RegExp(this.info.image + '$', 'i')))
        if (filtered) {
          this.imageUrl = filtered.pop()
        }
      } else if (!this.imageUrl) {
        this.imageUrl = 'https://via.placeholder.com/400?text=No+Image+Found'
      }
    }
  },
  asyncComputed: {
    imageUrl () {
      return wikiApi.page(this.selected).then(x => {
        return x.mainImage()
      })
      .catch(reason => {
        console.log('main image failed: ' + reason)
        return wikiApi.page(this.selected)
          .then(page => page.images())
      })
    },
    info () {
      this.info = {}
      return wikiApi.page(this.selected).then(x => x.info())
        .catch(reason => {
          console.log('page info failed' + reason)
        })
    },
    text () {
      var vm = this
      return wikiApi.page(this.selected).then(x => {
        vm.loading = false
        return x.summary()
      }).catch(() => {
        vm.loading = false
        return ''
      })
    }
  }
}
</script>