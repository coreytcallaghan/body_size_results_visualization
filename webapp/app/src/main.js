// The Vue build version to load with the `import` command
// (runtime-only or standalone) has been set in webpack.base.conf with an alias.
import Vue from 'vue'
import App from './App'
import AsyncComputed from 'vue-async-computed'
import VueScrollTo from 'vue-scrollto'

Vue.config.productionTip = false

window.introJS = require('intro.js').introJs

Vue.use(AsyncComputed)

Vue.use(VueScrollTo)

/* eslint-disable no-new */
new Vue({
  el: '#app',
  template: '<App/>',
  components: { App }
})
