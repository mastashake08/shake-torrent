<template>
  <div id="app">
    <img alt="Shake Torrent logo" src="./assets/cover.png" width="500" height="200">
    <MainView msg="Shake Torrent - WebTorrent File Viewer"/>
  </div>
</template>

<script>
import MainView from './components/MainView.vue'

export default {
  name: 'App',
  components: {
    MainView
  }
}
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
</style>
