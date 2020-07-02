var apiUrl = "${api_url}"

var minimalApp = new function () {

    this.buildTable = function (jsonText) {

        var tableEntries = JSON.parse(jsonText)
        var table = document.createElement("table");
        table.setAttribute('id', 'minimalTable');

        for (var entryNumber = 0; entryNumber < tableEntries.length; entryNumber++) {

            tr = table.insertRow(-1);

            var idCell = tr.insertCell(-1);
            idCell.innerHTML = tableEntries[entryNumber]["id"];
            var nameCell = tr.insertCell(-1);
            nameCell.innerHTML = tableEntries[entryNumber]["name"];

            this.td = document.createElement('td');
            tr.appendChild(this.td);

            var btDelete = document.createElement('input');
            btDelete.setAttribute('type', 'button');
            btDelete.setAttribute('value', 'Delete');
            btDelete.setAttribute('onclick', 'minimalApp.updateBackEnd(this)');
            this.td.appendChild(btDelete);
        }

        tr = table.insertRow(-1);

        tr.insertCell(0);
        var newCell = tr.insertCell(1);

        var tBox = document.createElement('input');
        tBox.setAttribute('type', 'text');
        tBox.setAttribute('value', '');

        newCell.appendChild(tBox);

        this.td = document.createElement('td');
        tr.appendChild(this.td);

        var btNew = document.createElement('input');
        btNew.setAttribute('type', 'button');
        btNew.setAttribute('value', 'Create');
        btNew.setAttribute('onclick', 'minimalApp.updateBackEnd(this)');
        this.td.appendChild(btNew);

        var div = document.getElementById("minimal-table");
        div.innerHTML = '';
        div.appendChild(table);
    }

    this.updateBackEnd = function (oButton) {

        var xhttp = new XMLHttpRequest();

        xhttp.onreadystatechange = function () {

            if (this.readyState == 4 && this.status == 200) {

                minimalApp.buildTable(this.responseText)
            }
        }

        xhttp.open("POST", apiUrl, true);

        var activeRow = oButton.parentNode.parentNode.rowIndex;
        var tab = document.getElementById('minimalTable').rows[activeRow];

        if (oButton.value == "Delete") {

            var td = tab.getElementsByTagName("td")[0];

            payload = JSON.stringify({ "operation": "delete", "id": td.innerHTML })
        }
        // default to create
        else {

            var td = tab.getElementsByTagName("td")[1];

            payload = JSON.stringify({ "operation": "create", "name": td.childNodes[0].value })
        }

        xhttp.send(payload);
    }
}

var xhttp = new XMLHttpRequest();

xhttp.onreadystatechange = function () {

    if (this.readyState == 4 && this.status == 200) {

        minimalApp.buildTable(this.responseText)
    }
}

xhttp.open("GET", apiUrl, true);
xhttp.send();
