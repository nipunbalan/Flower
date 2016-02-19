<%-- 
    Document   : configform
    Created on : 17/02/2016, 12:24:35 PM
    Author     : kho01f
--%>

<html lang="en">
    <head>
        <meta charset="utf-8">
        <link rel="stylesheet" href="//code.jquery.com/ui/1.11.4/themes/smoothness/jquery-ui.css">
        <script src="//code.jquery.com/jquery-1.10.2.js"></script>
        <script src="//code.jquery.com/ui/1.11.4/jquery-ui.js"></script>
        <!--<link rel="stylesheet" href="/resources/demos/style.css">-->
        <style>
            body { font-size: 62.5%; }
            label, input { display:block; }
            input.text { margin-bottom:12px; width:95%; padding: .4em; }
            fieldset { padding:0; border:0; margin-top:25px; }
            h1 { font-size: 1.2em; margin: .6em 0; }
            div#users-contain { width: 350px; margin: 20px 0; }
            div#users-contain table { margin: 1em 0; border-collapse: collapse; width: 100%; }
            div#users-contain table td, div#users-contain table th { border: 1px solid #eee; padding: .6em 10px; text-align: left; }
            .ui-dialog .ui-state-error { padding: .3em}
            .validateTips { border: 1px solid transparent; padding: 0.3em; }
        </style>
        <script>
            $(function() {
                var dialog, form,
                        access = $("#access"),
                        secret = $("#secret"),
                        category = $("#categories"),
                        allFields = $([]).add(access).add(secret).add(category),
                        tips = $(".validateTips");

                function updateTips(t) {
                    tips
                            .text(t)
                            .addClass("ui-state-highlight");
                    setTimeout(function() {
                        tips.removeClass("ui-state-highlight", 1500);
                    }, 500);
                }

                function saveData() {
                    var valid = true;
                    allFields.removeClass("ui-state-error");

                    if (category.val() == "") {
                        updateTips("Please select the Cloud provider.");
                        return false;
                    }
                    if (access.val() == "" || access.val() == null) {
                        updateTips("Access Key is empty.");
                        return false;
                    }

                    if (secret.val() == "" || secret.val() == null) {
                        updateTips("Secret Key is empty.");
                        return false;
                    }

                    if (valid) {
                        $("#users").append('<img class="warning" />');

                        dialog.dialog("close");
                    }
                    return valid;
                }

                dialog = $("#dialog-form").dialog({
                    autoOpen: false,
                    height: 350,
                    width: 350,
                    modal: true,
                    buttons: {
                        "Save": saveData,
                        Cancel: function() {
                            dialog.dialog("close");
                        }
                    },
                    close: function() {
                        //form[ 0 ].reset();
                        allFields.removeClass("ui-state-error");
                    }
                });

                form = dialog.find("form").on("save", function(event) {
                    event.preventDefault();
//                    addUser();
                });

                $("#confbutton").button().on("click", function() {
                    dialog.dialog("open");
                });
            });
        </script>
        <script>
            $(document).ready(function() {

                var AWS = [
                    {display: "US East (N. Virginia)", value: "us-east-1"},
                    {display: "US West (Oregon)", value: "us-west-2"},
                    {display: "EU (Ireland)", value: "eu-west-1"},
                    {display: "Asia Pacific (Tokyo)", value: "ap-northeast-1"},
                    {display: "Asia Pacific (Sydney)", value: "ap-southeast-2"}];
                var Azure = [
                    {display: "R1", value: "R1"},
                    {display: "R2", value: "R2"},
                    {display: "R3", value: "R3"}];
                $("#categories").change(function() {
                    var parent = $(this).val();
                    switch (parent) {
                        case 'Amazon':
                            list(AWS);
                            break;
                        case 'Microsoft':
                            list(Azure);
                            break;
                        case 'Google':
                            list(Azure);
                            break;
                        default: //default child option is blank
                            $("#subcats").html('');
                            break;
                    }
                });
                function list(array_list)
                {
                    $("#subcats").html(""); //reset child options
                    $(array_list).each(function(i) { //populate child options
                        $("#subcats").append("<option value=\"" + array_list[i].value + "\">" + array_list[i].display + "</option>");
                    });
                }
            });</script>
    </head>
    <body>

               <div id="dialog-form" title="Platform config information">
            <p class="validateTips">All form fields are required.</p>

            <form>
                <fieldset>
                    <label for="CloudProvider">Cloud Provider</label>
                    <select id="categories" class="text ui-widget-content ui-corner-all" style="margin-bottom:12px">
                        <option value="">--Select--</option>
                        <option value="Amazon">Amazon Cloud Services</option>
                        <option value="Google">Google Cloud Platform</option>
                        <option value="Microsoft">Microsoft Azure</option>
                    </select>

                    <!--<input type="text" name="name" id="name" class="text ui-widget-content ui-corner-all">-->
                    <label for="region">Region</label>
                    <select id="subcats" class="text ui-widget-content ui-corner-all" style="margin-bottom:12px;width:165px">
                    </select>

                    <label for="access">Access Key</label>
                    <input type="text" name="accesskey" id="accesskey" class="text ui-widget-content ui-corner-all">
                    <label for="secret">Secret Key</label>
                    <input type="text" name="secretkey" id="secretkey" class="text ui-widget-content ui-corner-all">
                    
                    <!-- Allow form submission with keyboard without duplicating the dialog button -->
                    <!--<input type="submit" tabindex="-1" style="position:absolute; top:-1000px">-->
                </fieldset>
            </form>
        </div>

        <div id="users-contain" class="ui-widget">
            <h1>Existing Users:</h1>
            <div id="users">
            </div>
        </div>
        <input type="image" src="${pageContext.request.contextPath}/resources/img/setting1.png" name="saveForm" id="confbutton" />

    </body>
</html>