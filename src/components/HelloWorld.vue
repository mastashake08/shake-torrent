<template>
  <div class="hello">
    <h1>{{ msg }}</h1>
    <p>
      WebTorrent downloader and viewer
    </p>
    <div class="seeder">
      <button v-if="seededTorrent.magnetURI" @click="share">Share seeded file</button>
      <input type="file" class="btn" @change="seed">Seed File
    </div>
    <div class="downloader">
      <p>Download torrent</p>
      <t-input type="text" v-model="magnet"/>
      <t-button  classes="['block', 'px-4', 'py-2', 'transition', 'duration-100']" @click="download">Download File</t-button>
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
    //this.registerHandler()
  },
  mounted () {
    this.getParams()
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
          console.log('downloading')
        })
        torrent.files.forEach(function (file) {
        file.appendTo('body')
      })

      // Display the file by adding it to the DOM. Supports video, audio, image, etc. files

      })
    },
    async share () {
      try {
        await navigator.clipboard.writeText(this.seededTorrent.magnetURI)
        alert('Magnet URI written to your clipboard')
      } catch(e) {
        console.log(e)
      }
    },
    registerHandler () {
      const current_root =  this.getHashParamsFromUrl()
      navigator.registerProtocolHandler('magnet', '%s='+current_root,
        'Shake Torrent magnet handler');
    },
    getParams () {
      this.magnet = this.getHashParamsFromUrl()

    },
    getHashParamsFromUrl() {
    const hashString = location.hash ? location.hash.replace(/^#/, '') : '';
      return (hashString.length > 0) ? window.location.hash.substr(1) : '';
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
