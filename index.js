var xhttp = new XMLHttpRequest();
xhttp.onreadystatechange = function () {
    if (this.readyState == 4 && this.status == 200) {
        this.responseObjects = JSON.parse(this.responseText)
        var table = document.createElement("table");

        for (var objectNumber = 0; objectNumber < this.responseObjects.length; objectNumber++) {

            tr = table.insertRow(-1);

            var idCell = tr.insertCell(-1);
            idCell.innerHTML = this.responseObjects[objectNumber]["id"];
            var nameCell = tr.insertCell(-1);
            nameCell.innerHTML = this.responseObjects[objectNumber]["name"];
        }

        var div = document.getElementById("minimal-table");
        div.appendChild(table);
    }
};
xhttp.open("GET", "${api_url}", true);
xhttp.send();
