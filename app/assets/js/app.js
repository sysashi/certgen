const byId = (id) => document.getElementById(id)

var RATIO = 1

const EDITOR = {
    init() {
        let certimg = byId("cert-img")
        let real_width = certimg.dataset.width
        if (certimg.width != real_width) {
            RATIO = real_width / certimg.width
        }
        let canvas = newEditorCanvas(certimg.width, certimg.height)
        insertAfter(certimg, canvas)
        drawExistingFields(canvas)
        addFieldEvent(canvas)
        addFieldFormEvents(canvas)
        addGenerateEvent()
    }
};

(function() {
    let editor = byId("editor");
    if (editor) {
        EDITOR.init()
    }
})();

function deleteField(id) {
    let xhr = new XMLHttpRequest()
    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            let result = JSON.parse(xhr.responseText)
            console.log(result)
        }
    }
    xhr.open("DELETE", "field/" + id, true);
    xhr.send()
}

function newField(canvas) {
    let fields = byId("fields")
    retriveFieldOptions(canvas, (markup, name) => {
        let li = document.createElement("li")
        li.insertAdjacentHTML("afterbegin", markup)
        li.firstChild.elements["name"].value = name
        let form = li.firstChild

        // add event handlers
        addFieldFormEvent(form)
        addDeleteFieldEvent(form, canvas)
        let index = fields.children.length === 0
            ? 1 : fields.children.length + 1
        addPositionEvent(canvas, li.firstChild, index)
        fields.appendChild(li)
    })
}

function retriveFieldOptions(canvas, callback) {
    let xhr = new XMLHttpRequest()
    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            let markup = xhr.responseText
            let name = window.prompt("Enter field name", "default")
            callback(markup, name)
        }
    }
    xhr.open("GET", "field-options", true);
    xhr.send();
}

function addPositionEvent(canvas, form, field_index) {
    let rect = canvas.getBoundingClientRect()
    let handler = (e) => {
        let x = e.clientX - rect.left
        let y = e.clientY - rect.top
        drawMark(canvas, x, y, field_index)
        // FIXME
        if (window.confirm("Is position corrent?"))  {
            canvas.removeEventListener("click", handler, false)
            form.elements["x"].value = Math.ceil(x * RATIO)
            form.elements["y"].value = Math.ceil(y * RATIO)
            let data = new FormData(form)
            postField(data, (id) => {
                form.dataset.id = id
            })
        } else {
            clearCircle(canvas, x, y, 16)
        }
    }
    canvas.addEventListener("click", handler, false)
}

function postField(data, callback) {
    let xhr = new XMLHttpRequest()
    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            let result = JSON.parse(xhr.responseText)
            callback(result.id)
        }
    }
    xhr.open("POST", "field", true);
    xhr.send(data)
}

function putField(form) {
    let xhr = new XMLHttpRequest()
    let data = new FormData(form)
    let id = form.dataset.id
    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            let result = JSON.parse(xhr.responseText)
        }
    }
    xhr.open("PUT", "field/" + id, true);
    xhr.send(data)
}

function drawExistingFields(canvas) {
    let fields = byId("fields")
    let lis = Array.from(fields.children)
    lis.forEach((li, index) => {
        let form = li.firstChild
        let x = form.elements["x"].value
        let y = form.elements["y"].value
        drawMark(canvas, x / RATIO, y / RATIO, index + 1)
    })
}

function addFieldFormEvents(canvas) {
    let fields = byId("fields")
    let lis = Array.from(fields.children)
    lis.forEach((li, index) => {
        let form = li.firstChild
        addFieldFormEvent(form)
        addDeleteFieldEvent(form, canvas)
    })
}

function clearCircle(canvas, x, y, radius) {
    let ctx = canvas.getContext("2d")
    ctx.save()
    ctx.beginPath()
    ctx.arc(x, y, radius + 1, 0, 2 * Math.PI, false)
    ctx.clip()
    ctx.clearRect(0, 0, canvas.width, canvas.height)
    ctx.restore()
    return ctx
}

function drawMark(canvas, x, y, number) {
    let ctx = canvas.getContext("2d")
    ctx.beginPath()
    ctx.fillStyle = "rgba(0, 0, 255, 0.5)";
    ctx.arc(x, y, 16, 0, 2 * Math.PI, false)
    ctx.fill()
    ctx.fillStyle = "rgba(255, 255, 255, 1)";
    ctx.font = "28px sans-serif";
    ctx.fillText(number.toString(), x - 8, y + 10);
    return ctx
}

function addFieldEvent(canvas) {
    let button = byId("add-field")
    button.addEventListener("click", (e) => {
        e.preventDefault()
        newField(canvas)
    }, false)
    return button
}

// TODO clear canvas
function addDeleteFieldEvent(form, canvas) {
    let id = form.dataset.id
    let x = form.elements["x"].value
    let y = form.elements["y"].value
    let button = form.querySelector(".delete")
    button.addEventListener("click", (e) => {
        e.preventDefault()
        deleteField(id)
        removeListEntry(form)
        // FIXME
        clearCircle(canvas, x, y, 16)
    }, false)
}

function removeListEntry(form) {
    let li = form.parentNode
    let ul = li.parentNode
    ul.removeChild(li)
}

// add delta timer
function addFieldFormEvent(form) {
    form.addEventListener("change", (e) => {
        putField(form)
    }, false)
}

function addGenerateEvent() {
    let button = byId("generate")
    button.addEventListener("click", (e) => {
        e.preventDefault()
        let href = button.getAttribute("href")
        let query = serialize(harvestFieldsContent())
        window.open(href + "?" + query, "_blank")
    }, false)
}

function harvestFieldsContent() {
    let fields = byId("fields")
    let lis = Array.from(fields.children)
    let obj = {}
    lis.forEach((li, index) => {
        let form = li.firstChild
        let field_id = form.dataset.id
        let content = form.elements["content"].value
        obj[field_id] = content
    })
    return obj
}

function newEditorCanvas(width, height) {
    console.log(width, height)
    let canvas = document.createElement("canvas")
	  canvas.width = width
	  canvas.height = height
	  return canvas
}

// Thanks SO
function insertAfter(referenceNode, newNode) {
    referenceNode.parentNode.insertBefore(newNode, referenceNode.nextSibling)
}

function serialize(obj) {
    let str = [];
    for(var p in obj)
        if (obj.hasOwnProperty(p)) {
            str.push(encodeURIComponent(p) + "=" + encodeURIComponent(obj[p]));
        }
    return str.join("&");
}
