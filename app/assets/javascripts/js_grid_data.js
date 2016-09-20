var fields = [
    { "Name": "Otto Clay", "Type": 1 }
];

var types = [
    { Name: "Boolean",  Id: 0 },
    { Name: "Time",     Id: 1 },
    { Name: "DateTime", Id: 2 }
];

function initJSGrid(){
    $("#fields").jsGrid({
        width: "100%",
        height: "400px",

        inserting: true,
        editing: true,
        sorting: true,
        paging: true,

        data: fields,

        fields: [
            { name: "Name", type: "text", width: 150, validate: "required" },
            { name: "Type", type: "select", items: types, valueField: "Id", textField: "Name" },
            { type: "control" }
        ]
})}
