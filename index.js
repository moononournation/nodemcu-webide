var blockSize = 1024;
var normalColor = "#0067B0";
var selectedColor = "#CCCCCC";
var showInvisibles = false;
var editor;
var curFileItem;
var savingText;
var savingFilename;
var savingFileOffset;
var xhr; // reuse

function setLocalStatus(msg) {
  document.getElementById("localStatus").innerHTML = msg;
}

function setRemoteStatus(msg) {
  document.getElementById("remoteStatus").innerHTML = msg;
}

function loadScript(url, callback) {
  setLocalStatus("<span class=\"icon icon-loading\"></span> Loading " + url);

  var script = document.createElement("script");
  script.type = "text/javascript";

  if (script.readyState) {  //IE
    script.onreadystatechange = function () {
      if (script.readyState == "loaded" || script.readyState == "complete") {
        script.onreadystatechange = null;
        callback();
      }
    };
  } else { //Others
    script.onload = function () {
      setLocalStatus("");

      callback();
    };
  }

  script.src = url;
  document.getElementsByTagName("head")[0].appendChild(script);
}

function isXhrSuccess(xhr) {
  return ((xhr.readyState === 4) && (xhr.status == 200));
}

function handleFileClick(item) {
  if (curFileItem) {
    curFileItem.classList.remove("selected");
  }
  item.classList.add("selected");
  curFileItem = item;

  loadFile();
}

function loadFilelist() {
  setLocalStatus("<span class=\"icon icon-loading\"></span> Loading file list");

  if (!xhr) xhr = new XMLHttpRequest();
  xhr.open("POST", "file-api.lc", true);
  xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
  xhr.onreadystatechange = function () {
    if (isXhrSuccess(xhr)) {
      var filelistHtml = "";
      var json = JSON.parse(xhr.responseText);
      var files = new Array(json.length);
      var i = 0;
      for (var filename in json) {
        files[i++] = filename;
      }
      files.sort();
      for (i = 0; i < files.length; i++) {
        filelistHtml += '<div class="fileItem" id="' + files[i] + '"><span class="icon icon-file"></span> ' + files[i] + '</div>'
      }
      document.getElementById("filelist").innerHTML = filelistHtml;

      fileItemList = document.getElementsByClassName("fileItem");
      for (i = 0; i < fileItemList.length; i++) {
        fileItemList[i].addEventListener("click", function (e) {
          handleFileClick(e.srcElement);
        });
      }

      setLocalStatus("");
    }
  };
  xhr.send("action=list");
}

function handleSaveCallback() {
  if (isXhrSuccess(xhr)) {
    setRemoteStatus("");

    savingFileOffset += blockSize;
    if (savingFileOffset < savingText.length) {
      setLocalStatus("<span class=\"icon icon-loading\"></span> Saving file: " + savingFilename + " " + savingFileOffset + "/" + savingText.length + " bytes");

      var params = "action=append&filename=" + savingFilename + "&data=" + encodeURIComponent(savingText.substring(savingFileOffset, savingFileOffset + blockSize));
      if (!xhr) xhr = new XMLHttpRequest();
      xhr.open("POST", "file-api.lc", true);
      xhr.onreadystatechange = handleSaveCallback;
      xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
      xhr.send(params);
    } else {
      if ((savingFilename.split(".").pop() == "lua") && (savingFilename != "config.lua") && (savingFilename != "config.lua")) {
        setLocalStatus("<span class=\"icon icon-loading\"></span> Compiling file: " + savingFilename);

        params = "action=compile&filename=" + savingFilename;
        if (!xhr) xhr = new XMLHttpRequest();
        xhr.open("POST", "file-api.lc", true);
        xhr.onreadystatechange = handleCompileCallback;
        xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
        xhr.send(params);
      } else {
        setLocalStatus("Saved file: " + savingFilename + " " + savingText.length + " bytes");
      }
    }
  } else {
    setRemoteStatus("");
    setRemoteStatus(xhr.responseText);
  }
}

function handleCompileCallback() {
  if (isXhrSuccess(xhr)) {
    setLocalStatus("Compiled file: " + savingFilename);
    setRemoteStatus("");
  }
}

function loadFile() {
  var filename = curFileItem.id;
  setLocalStatus("Loading: " + filename);
  setLocalStatus("<span class=\"icon icon-loading\"></span> Loading file: " + filename);

  var params = "action=load&filename=" + filename;
  if (!xhr) xhr = new XMLHttpRequest();
  xhr.open("POST", "file-api.lc", true);
  xhr.onreadystatechange = function () {
    if (isXhrSuccess(xhr)) {
      editor.setValue(xhr.responseText);
      var extension = filename.split(".").pop();
      switch (extension) {
        case "css":
          editor.setOption("mode", "css");
          break;
        case "htm":
        case "html":
          editor.setOption("mode", "htmlmixed");
          break;
        case "js":
        case "json":
          editor.setOption("mode", "javascript");
          break;
        case "lua":
          editor.setOption("mode", "lua");
          break;
        case "xml":
          editor.setOption("mode", "xml");
          break;
      }

      setLocalStatus("");
    }
  }
  xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
  xhr.send(params);
}

function undo() {
  editor.undo();
}

function save() {
  savingText = editor.getValue();
  savingFilename = curFileItem.id;
  savingFileOffset = 0;
  setLocalStatus("<span class=\"icon icon-loading\"></span> Saving file: " + savingFilename + " " + savingFileOffset + "/" + savingText.length + " bytes");
  setRemoteStatus("");
  var params = "action=save&filename=" + savingFilename + "&data=" + encodeURIComponent(savingText.substring(savingFileOffset, savingFileOffset + blockSize));
  if (!xhr) xhr = new XMLHttpRequest();
  xhr.open("POST", "file-api.lc", true);
  xhr.onreadystatechange = handleSaveCallback;
  xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
  xhr.send(params);
}

function preview() {
  if (curFileItem) {
    var url = curFileItem.id;
    var win = window.open(url, '_blank');
    win.focus();
  }
}

function init() {
  editor = CodeMirror(document.getElementById("editor"), {
    styleActiveLine: true, // activeline
    lineNumbers: true,
    lineWrapping: true,
    autoCloseBrackets: true, // closebrackets
    autoCloseTags: true, //closetag
    gutters: ["CodeMirror-lint-markers"],
    lint: true
  });

  loadFilelist();

  document.getElementById("undo").addEventListener("click", undo);
  document.getElementById("save").addEventListener("click", save);
  document.getElementById("preview").addEventListener("click", preview);
}

// load large size script in sequence to avoid NodeMCU overflow
// CodeMirror Compression helper https://codemirror.net/doc/compress.html
// codemirror.js, css.js, htmlmixed.js, javascript.js, lua.js, xml.js
// active-line.js, css-hint.js, html-hint.js, javascript-hint.js, trailingspace.js, xml-hint.js
loadScript("codemirror-compressed.js", function () {
  //loadScript("further-script.js", function () {
  init();
  //})
})
