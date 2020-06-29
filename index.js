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
        btNew.setAttribute('onclick', 'minimalApp.createItem(this)');
        this.td.appendChild(btNew);

        var div = document.getElementById("minimal-table");
        div.innerHTML = '';
        div.appendChild(table);
    }

    this.createItem = function (oButton) {

        var xhttp = new XMLHttpRequest();

        xhttp.onreadystatechange = function () {

            if (this.readyState == 4 && this.status == 200) {

                minimalApp.buildTable(this.responseText)
            }
        }

        xhttp.open("POST", apiUrl, true);

        var activeRow = oButton.parentNode.parentNode.rowIndex;
        var tab = document.getElementById('minimalTable').rows[activeRow];
        var td = tab.getElementsByTagName("td")[1];

        xhttp.send(td.childNodes[0].value);
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
