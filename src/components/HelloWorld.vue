<template>
  <div class="hello">
    <h1>{{ msg }}</h1>
    <p>
      WebTorrent downloader and viewer
    </p>
    <!-- <div class="seeder">
      <p>Seeded file - {{seededTorrent.magnetURI}}</p>
      <input type="file" class="btn" @change="seed">Seed File
    </div> -->
    <div class="downloader">
      <p>Download torrent</p>
      <input type="text" v-model="magnet">
      <button class="btn" @click="download">Download File</button>
    </div>
  </div>
</template>

<script>
import WebTorrent from 'webtorrent';
export default {
  name: 'HelloWorld',
  props: {
    msg: String
  },
  data () {
    return {
      clent: {},
      seededTorrent: {},
      magnet: '',
      downloadProgress: 0.00
    }
  },
  created() {
    this.client = new WebTorrent()
    this.client.on('seed', (torrent) => {
      this.seededTorrent = torrent
    })
  },
  methods: {
    seed (args) {
      const seed = args.target.files[0]
      this.client.seed(seed)

    },
    download () {
      this.client.add(this.magnet, (torrent) => {
        torrent.on('download', function () {
          this.downloadProgress = torrent.progress
        })
        torrent.files.forEach(function (file) {
        file.appendTo('body')
      })

      // Display the file by adding it to the DOM. Supports video, audio, image, etc. files

      })
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
h3 {
  margin: 40px 0 0;
}
ul {
  list-style-type: none;
  padding: 0;
}
li {
  display: inline-block;
  margin: 0 10px;
}
a {
  color: #42b983;
}
</style>
