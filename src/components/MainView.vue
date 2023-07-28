
<template>
  <div class="hello">
    <h1>{{ msg }}</h1>
    <div class="seeder">
      <t-button v-if="seededTorrent.magnetURI" @click="share">Share seeded file</t-button>
      <t-input type="file" multiple class="btn" @change="seed"> Seed File</t-input>
      <div class="files" v-if="seededTorrent.magnetURI">
        <div class="accordion" >{{seededTorrent.name}}
            <br>
            <label> <b>Num. of peers {{seededTorrent.numPeers}} </b></label>
            <br>

            <div class="button-actions">
              <button @click="toggle">Toggle File List</button>
            </div>
        </div>
          <div class="panel" >
            <ol>
              <li v-for="(file, index) in seededTorrent.files" :key="index" :id="file.name" @click="preview(file)"><a href="#">{{file.name}}</a></li>
            </ol>
          </div>
        </div>
    </div>
    <hr/>
    <div class="downloader">
      <div class="torrent-progress" v-for="(t,index) in torrents" :key="index">
        <div class="files">
          <div class="accordion" >{{t.name}}
              <br>
              <label> <b>Num. of peers {{t.numPeers}} </b></label>
              <br>
              <progress  :id="t.name" :value="t.progress*100" max="100"/>
              {{Math.round(t.progress*100)}}%
              <br>
              <span v-if="t.progress < 1">Time Remaining: {{millisToMinutesAndSeconds(t.timeRemaining)}}</span>
              <div class="button-actions">
                <button @click="toggle">Toggle File List</button>
                <br>
                <button @click="destroyTorrent(index)">Destroy Torrent</button>
                <br>
                <button v-if="t.progress === 1" @click="downloadZip(t)">Download Files</button>

              </div>
          </div>
            <div class="panel" :id="t.infoHash">
              <ol>
                <li :id="file.length" v-for="(file, index) in t.files" :key="index" @click="preview(file, t)"><a href="#">{{file.name}}</a></li>
              </ol>
            </div>
          </div>
          <br>
      </div>

      <t-input type="text" v-model="magnet"/>
      <t-button  classes="['block', 'px-4', 'py-2', 'transition', 'duration-100']" @click="download">Download File</t-button>

    </div>
  </div>
</template>

<script>
import WebTorrent from 'webtorrent';
import { saveAs } from 'file-saver';
import JSZip from 'jszip'
export default {
  name: 'MainView',
  props: {
    msg: String
  },
  data () {
    return {
      client: {},
      seededTorrent: {},
      magnet: '',
      downloadProgress: 0.00,
      downloading: false,
      numPeers: 0,
      torrentFiles: [],
      downloaded: false,
      torrents: []
    }
  },
  created() {

    //this.registerHandler()
    this.client = new WebTorrent()

  },
  mounted () {
    this.getParams()
  },
  methods: {
    destroyTorrent(index) {
      this.torrents[index].destroy()
      this.torrents.splice(index,1)
    },
    preview(item, t) {

      const elem = document.getElementById(t.infoHash)
      const li = document.getElementById(item.length)
      if(li.classList.contains('disabled') == false) {
        item.appendTo(elem)
        li.classList.add('disabled')
      }

    },
    millisToMinutesAndSeconds(millis) {
        var minutes = Math.floor(millis / 60000);
        var seconds = ((millis % 60000) / 1000).toFixed(0);
        return minutes + ":" + (seconds < 10 ? '0' : '') + seconds;
    },
    seed (args) {
      try {
        const files = args.target.files
        const that = this
        that.client.seed(files, function (torrent) {
          that.seededTorrent = torrent
        })} catch(e) {
          console.log(e.message)
        }
    },
    async download () {
      const that = this
      try {
        const data = {
          torrent: this.magnet
        }
        const res = await fetch('http://localhost:3000/add', {
          method: "POST", // or 'PUT'
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify(data),
        });
    const result = await res.json()
    this.magnet = result.magnetUri
    this.client.add(this.magnet, {
      announce: ['wss://tracker.openwebtorrent.com','wss://tracker.btorrent.xyz','wss://tracker.webtorrent.dev']
    }, (torrent) => {
      that.torrents.push(torrent)
      that.downloading = true
      that.downloaded = false
      torrent.on('download', function () {
        that.downloadProgress = torrent.progress * 100
        that.numPeers = torrent.numPeers

      })
      torrent.on('done', async function (){
        chrome.notifications.create({
          title: `${torrent.name} Downloaded!`,
          message: 'Enjoy your torrent!',
          iconUrl: '/image/shake-48.png',
          type: 'basic'
        })
        torrent.zip = new JSZip();
        await torrent.files.forEach(async file => {
          await file.getBlob(async (err, blob) => {
            await torrent.zip.file(file.name, blob);
            })
          })
      torrent.files.forEach(torrent => {
        that.torrentFiles.push(torrent)
      })

      that.downloading = false
      that.downloaded = true
      })
    })
  } catch {
        this.client.add(this.magnet, {
          announce: ['wss://tracker.openwebtorrent.com','wss://tracker.btorrent.xyz','wss://tracker.webtorrent.dev']
        }, (torrent) => {
          that.torrents.push(torrent)
          that.downloading = true
          that.downloaded = false
          torrent.on('download', function () {
            that.downloadProgress = torrent.progress * 100
            that.numPeers = torrent.numPeers

          })
          torrent.on('done', async function (){
            torrent.zip = new JSZip();
            await torrent.files.forEach(async file => {
              await file.getBlob(async (err, blob) => {
                await torrent.zip.file(file.name, blob);
                })
              })

          torrent.files.forEach(torrent => {
            that.torrentFiles.push(torrent)
          })

          that.downloading = false
          that.downloaded = true
          })
        })
      }

    },
    async downloadZip(torrent) {
      try {
        const that = this

          torrent.zip.generateAsync({type:"blob"})
          .then(function(content) {
              saveAs(content, torrent.name + '.zip');
              that.zip = {}
          });
      } catch(e) {
        console.log(e.message)
        }
    },
    toggle (args) {
      const acc = args.target.parentNode.parentNode
      acc.classList.toggle("active");
      var panel = acc.nextElementSibling;
      if (panel.style.display === "block") {
        panel.style.display = "none";
      } else {
        panel.style.display = "block";
      }
    },
    async share () {
      const url = this.seededTorrent.magnetURI
      try {
        await navigator.share(url)
      } catch {
        await navigator.clipboard.writeText(url)
        alert('Magnet URI written to your clipboard')
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
/* Style the buttons that are used to open and close the accordion panel */
.accordion {
  background-color: #eee;
  color: #444;
  cursor: pointer;
  padding: 18px;
  width: 100%;
  text-align: left;
  border: none;
  outline: none;
  transition: 0.4s;
}

/* Add a background color to the button if it is clicked on (add the .active class with JS), and when you move the mouse over it (hover) */
.active, .accordion:hover {
  background-color: #ccc;
}

/* Style the accordion panel. Note: hidden by default */
.panel {
  padding: 0 18px;
  background-color: white;
  display: none;
  overflow: hidden;
}

img, video {
  width: 250px;
  height: 250px;
}
</style>
