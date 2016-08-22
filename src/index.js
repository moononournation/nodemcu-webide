var blockSize = 1024;
var normalColor = "#0067B0";
var selectedColor = "#CCCCCC";
var showInvisibles = false;
var editor;
var curFileItem;
var savingText;
var savingFilename;
var savingFileOffset;
var savingXhr;

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
  var xhr = new XMLHttpRequest();
  xhr.open("POST", "file-api.lc", true);
  xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
  xhr.onreadystatechange = function () {
    if (isXhrSuccess(xhr)) {
      //setRemoteStatus("");
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
      curFileItem = null;

      fileItemList = document.getElementsByClassName("fileItem");
      for (i = 0; i < fileItemList.length; i++) {
        fileItemList[i].addEventListener("click", function (e) {
          handleFileClick(e.target);
        });
      }

      setLocalStatus("");
    } else {
      //setRemoteStatus(xhr.responseText);
    }
  };
  setLocalStatus("<span class=\"icon icon-loading\"></span> Loading file list");
  xhr.send("action=list");
}

function handleSaveCallback() {
  if (isXhrSuccess(savingXhr)) {
    setRemoteStatus("");

    savingFileOffset += blockSize;
    if (savingFileOffset < savingText.length) {
      var params = "action=append&filename=" + savingFilename + "&data=" + encodeURIComponent(savingText.substring(savingFileOffset, savingFileOffset + blockSize));
      savingXhr = new XMLHttpRequest();
      savingXhr.open("POST", "file-api.lc", true);
      savingXhr.onreadystatechange = handleSaveCallback;
      savingXhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
      setLocalStatus("<span class=\"icon icon-loading\"></span> Saving file: " + savingFilename + " " + savingFileOffset + "/" + savingText.length + " bytes");
      savingXhr.send(params);
    } else {
      if ((savingFilename.split(".").pop() == "lua") && (savingFilename != "config.lua") && (savingFilename != "init.lua")) {
        params = "action=compile&filename=" + savingFilename;
        var xhr = new XMLHttpRequest();
        xhr.open("POST", "file-api.lc", true);
        xhr.onreadystatechange = handleCompileCallback;
        xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
        setLocalStatus("<span class=\"icon icon-loading\"></span> Compiling file: " + savingFilename);
        xhr.send(params);
      } else {
        setLocalStatus("Saved file: " + savingFilename + " " + savingText.length + " bytes");
      }
    }
  } else {
    setRemoteStatus(savingXhr.responseText);
  }
}

function handleCompileCallback() {
  if (isXhrSuccess(xhr)) {
    setLocalStatus("");
  }
  setRemoteStatus(xhr.responseText);
}

function handleFileCallback() {
  setRemoteStatus(xhr.responseText);
  if (isXhrSuccess(xhr)) {
    loadFilelist();
    setLocalStatus("");
  }
}


function loadFile() {
  var filename = curFileItem.id;
  var params = "action=load&filename=" + filename;
  var xhr = new XMLHttpRequest();
  xhr.open("POST", "file-api.lc", true);
  xhr.onreadystatechange = function () {
    if (isXhrSuccess(xhr)) {
      setRemoteStatus("");
      editor.setValue(xhr.responseText);
      editor.markClean();
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
    } else {
      //setRemoteStatus(xhr.responseText);
    }
  }
  xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
  setLocalStatus("<span class=\"icon icon-loading\"></span> Loading file: " + filename);
  xhr.send(params);
}

function undo() {
  setLocalStatus("undo");
  editor.undo();
}

function save() {
  savingText = editor.getValue();
  savingFilename = curFileItem.id;
  savingFileOffset = 0;
  var params = "action=save&filename=" + savingFilename + "&data=" + encodeURIComponent(savingText.substring(savingFileOffset, savingFileOffset + blockSize));
  savingXhr = new XMLHttpRequest();
  savingXhr.open("POST", "file-api.lc", true);
  savingXhr.onreadystatechange = handleSaveCallback;
  savingXhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
  setLocalStatus("<span class=\"icon icon-loading\"></span> Saving file: " + savingFilename + " " + savingFileOffset + "/" + savingText.length + " bytes");
  savingXhr.send(params);
}

function preview() {
  if (curFileItem) {
    var url = curFileItem.id;
    setLocalStatus("Preview: "+url);
    var win = window.open(url+'?', '_blank');
    win.focus();
  }
}

function new_file() {
  var xhr = new XMLHttpRequest();
  xhr.open("POST", "file-api.lc", true);
  xhr.onreadystatechange = handleFileCallback;
  xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
  setLocalStatus("<span class=\"icon icon-loading\"></span> Creating new file");
  xhr.send("action=new");
}

function rename_file() {
  if (curFileItem) {
    var filename = curFileItem.id;
    var newfilename = prompt("Rename " + filename + " to:", filename);
    if (newfilename != null) {
      var xhr = new XMLHttpRequest();
      xhr.open("POST", "file-api.lc", true);
      xhr.onreadystatechange = handleFileCallback;
      xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
      setLocalStatus("<span class=\"icon icon-loading\"></span> Renaming file from \""+filename+"\" to \""+newfilename+"\"");
      xhr.send("action=rename&filename="+escape(filename)+"&newfilename="+escape(newfilename));
    }
  }
}

function delete_file() {
  if (curFileItem) {
    var filename = curFileItem.id;
    var xhr = new XMLHttpRequest();
    xhr.open("POST", "file-api.lc", true);
    xhr.onreadystatechange = handleFileCallback;
    xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    setLocalStatus("<span class=\"icon icon-loading\"></span> Deleting file: \""+filename+"\"");
    xhr.send("action=delete&filename="+escape(filename));
  }
}

function init() {
  editor = CodeMirror(document.getElementById("editor"), {
    lineNumbers: true,
    lineWrapping: true,
    styleActiveLine: true, // activeline
    matchBrackets: true,
    matchTags: true,
    autoCloseBrackets: true,
    autoCloseTags: true,
    showTrailingSpace: true
  });

  loadFilelist();

  document.getElementById("undo").addEventListener("click", undo);
  document.getElementById("save").addEventListener("click", save);
  document.getElementById("preview").addEventListener("click", preview);
  document.getElementById("new").addEventListener("click", new_file);
  document.getElementById("rename").addEventListener("click", rename_file);
  document.getElementById("delete").addEventListener("click", delete_file);
}

// load large size script in sequence to avoid NodeMCU overflow
// http://codemirror.net/doc/compress.html
loadScript("codemirror.js", function () {
  // css.js, htmlmixed.js, javascript.js, lua.js, xml.js
  loadScript("modes.js", function () {
    // active-line.js, closebrackets.js, closetag.js,
    // matchbrackets.js, matchtags.js,  trailingspace.js, xml-fold.js
    loadScript("addons.js", function () {
      init();
    })
  })
})
