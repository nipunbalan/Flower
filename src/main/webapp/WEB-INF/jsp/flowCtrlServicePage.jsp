<%-- 
    Document   : flowCtrlServicePage
    Created on : 05/04/2016, 5:41:54 PM
    Author     : kho01f
--%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://tiles.apache.org/tags-tiles" prefix="tiles" %>
<html>
    <head>
        <link rel="stylesheet" href="//code.jquery.com/ui/1.11.4/themes/smoothness/jquery-ui.css">

        <link href="${pageContext.request.contextPath}/resources/css/stepform.css" rel="stylesheet" type="text/css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/epoch.css">
        <script src="//code.jquery.com/jquery-1.10.2.js"></script>
        <script src="//code.jquery.com/ui/1.11.4/jquery-ui.js"></script>
        <script src="https://d3js.org/d3.v3.min.js" charset="utf-8"></script>
        <script src="${pageContext.request.contextPath}/resources/js/epoch.min.js"></script>

        <style>
            .ui-accordion .ui-accordion-header {
                /*text-align: center;*/
                font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
                color:#23527c;
                display: block;
                cursor: pointer;
                position: relative;
                margin: 2px 0 0 0;
                padding: .5em .5em .5em .7em;
                min-height: 0; /* support: IE7 */
                /*                border: 1px #c1e2b3 solid;*/

            }
            .ui-accordion .ui-accordion-icons {
                padding-left: 2.2em;
            }
            .ui-accordion .ui-accordion-icons .ui-accordion-icons {
                padding-left: 2.2em;
            }
            .ui-accordion .ui-accordion-header .ui-accordion-header-icon {
                position: absolute;
                left: .5em;
                top: 50%;
                margin-top: -8px;
            }
            .ui-accordion .ui-accordion-content {
                padding: 1em 2.2em;
                border: 0;
                overflow: auto;
                border: 1px solid #ddd;
            }
            img.icon{
                width:30px; height:30px;
            }

        </style>
        <style>
            div.play {
                color: #ffffff;
                width: 70px;
                height: 30px;
                text-align: center;
                line-height: 30px;
                font-size: 14px;
                cursor: pointer;
                position: relative;
                background-color: #67B168;  
                -webkit-border-radius: 50%;
                -moz-border-radius: 50%;
                border-radius: 5%;
                -webkit-box-shadow: inset 0 0 0 1px #ddd, inset 0 0 0 3px #fff,inset 0 0 0 4px #ddd;
                box-shadow: inset 0 0 0 1px #ddd, inset 0 0 0 3px #fff,inset 0 0 0 4px #ddd;
                -webkit-transition: all .2s ease;
                transition: all .2s ease;
                margin-right: 5px; 
                float: left;
            }

            div.play:hover,
            div.play.active {
                -webkit-box-shadow: inset 0 0 0 0 #CD391F, inset 0 0 0 0 #fff,inset 0 0 0 0px #cd3920;
                -moz-box-shadow: inset 0 0 0 0 #CD391F, inset 0 0 0 0 #fff,inset 0 0 0 0px #cd3920;
                box-shadow: inset 0 0 0 0 #CD391F, inset 0 0 0 0 #fff,inset 0 0 0 0px #cd3920;
                color: #fff;
                background-color: #CD391F;
            }

            .form-style-ctrl-stat{
                width: 980px;
                padding: 20px 12px 10px 20px;
                font: 13px Arial, Helvetica, sans-serif;
                position: relative;
                /*float: left;*/
            }
            .form-style-ctrl-diag{
                width: 780px;
                padding: 20px 12px 10px 20px;
                font: 13px Arial, Helvetica, sans-serif;
                position: relative;
                float: left;
            }
            .form-style-resource-share{
                width: 200px;
                padding: 20px 12px 10px 20px;
                font: 13px Arial, Helvetica, sans-serif;
                position: relative;
                float: left;
            }

        </style>
        <script type="text/javascript">
            $(function() {

                var flow = '${flow.platforms}';
                var $flowId = '${flow.flowId}';
                var systems = flow.split(",");
                var system;

                for (var i = 0; i < systems.length; i++) {
                    system = systems[i].replace(' ', '');
                    $("#accordion").children().last()
                            .after('<h3 class="accordion-header ui-accordion-header \n\
                                    ui-helper-reset ui-state-default ui-accordion-icons \n\
                                    ui-corner-all"><span class="ui-accordion-header-icon ui-icon \n\
                                    ui-icon-triangle-1-e"></span><img class="icon" \n\
                                    src="${pageContext.request.contextPath}/resources/img/'
                                    + systems[i] + '.png" /> ' + systems[i] +
                                    '</h3><div class="ui-accordion-content ui-helper-reset \n\
                                    ui-widget-content ui-corner-bottom"><div class="form-style-ctrl-stat">\n\
                                    <div class="form-style-3-heading">Controller Stats</div>\n\
                                     <table id="' + system + 'Tbl"> \n\
                                        <tbody> </tbody></table>\n\
                                      </div><div class="form-style-resource-share">\n\
                                    <div class="form-style-3-heading">Resource Share</div>\n\
                                   <div id="' + system + 'Pie" class="epoch category20c" style="width: 180px; height: 180px"></div></div>\n\
                                    <div class="form-style-ctrl-diag">\n\
                                    <div class="form-style-3-heading">System Performance Monitoring</div>\n\
                                     </div>\n\
                                        </div></div></div>');
                    switch (system) {
                        case "ApacheStorm":
                            {
                                $('#ApacheStormTbl')
                                        .append('<thead>\n\
                                    <tr><th>Topology Name</th><th>Controller Status</th> \n\
                                     <th>Measurement Target</th><th>Ref. Value</th><th>Scheduling</th> \n\
                                     <th>Backoff No</th> <th></th>\n\
                                    <th></th></tr></thead>');
                                $.get("stormCtrl/" + $flowId, function(stormCtrl) {
                                    var $ctrlStatus = getCtrlStatus('ApacheStorm', stormCtrl.targetTopology, $flowId);
                                    $('#ApacheStormTbl tr:last')
                                            .after('<tr><td>' + stormCtrl.targetTopology + '</td>\n\
                                        <td>' + $ctrlStatus + '</td>\n\
                                        <td>' + stormCtrl.measurementTarget + '</td>\n\
                                        <td>' + stormCtrl.refValue + '</td> \n\
                                        <td>' + stormCtrl.monitoringPeriod + '</td>\n\
                                        <td>' + stormCtrl.backoffNo + '</td>\n\
                                        <td><div class="play ' + getCtrlBtnCls($ctrlStatus) + '" style="text-shadow:none">' + getCtrlBtnName($ctrlStatus) + '</div></td>\n\
                                        <td><input type="radio" name="ApacheStorm" value="' + stormCtrl.targetTopology + '" ></td></tr>');
                                });
                                break;
                            }
                        case "DynamoDB":
                            {
                                $('#DynamoDBTbl')
                                        .append('<thead>\n\
                                    <tr><th>Table Name</th><th>Controller Status</th> \n\
                                     <th>Measurement Target</th><th>Ref. Value</th> <th>Scheduling</th> \n\
                                     <th>Backoff No</th> <th></th>\n\
                                    <th></th></tr></thead>');
                                //Technique 1: Consuming json using ajax and parsing using each function
                                $.get("dynamoCtrl/" + $flowId, function(data) {
                                    $.each(data, function(i, dynamoCtrl) {
                                        var $ctrlStatus = getCtrlStatus('DynamoDB', dynamoCtrl.tableName, $flowId);
                                        $('#DynamoDBTbl tr:last')
                                                .after('<tr><td>' + dynamoCtrl.tableName + '</td>\n\
                                                    <td>' + $ctrlStatus + '</td>\n\
                                                    <td>' + dynamoCtrl.measurementTarget + '</td>\n\
                                                    <td>' + dynamoCtrl.refValue + '</td> \n\
                                                    <td>' + dynamoCtrl.monitoringPeriod + '</td>\n\
                                                    <td>' + dynamoCtrl.backoffNo + '</td>\n\
                                                    <td><div class="play ' + getCtrlBtnCls($ctrlStatus) + '" style="text-shadow:none">' + getCtrlBtnName($ctrlStatus) + '</div></td>\n\
                                                    <td><input type="radio" name="DynamoDB" value="' + dynamoCtrl.tableName + '" \n\
                                                        ></td></tr>');
                                    });
                                });
                                break;
                            }
                        case "AmazonKinesis":
                            {
                                $('#AmazonKinesisTbl')
                                        .append('<thead>\n\
                                    <tr><th>Stream Name</th><th>Controller Status</th> \n\
                                     <th>Measurement Target</th><th>Ref. Value</th> <th>Scheduling</th> \n\
                                     <th>Backoff No</th> <th></th>\n\
                                    <th></th><th></th></tr></thead>');
                                $.get("kinesisCtrl/" + $flowId, function(data) {
                                    $.each(data, function(i, kinesisCtrl) {
                                        var $ctrlStatus = getCtrlStatus('AmazonKinesis', kinesisCtrl.streamName, $flowId);
                                        $('#AmazonKinesisTbl tr:last')
                                                .after('<tr><td>' + kinesisCtrl.streamName + '</td>\n\
                                                    <td>' + $ctrlStatus + '</td>\n\
                                                    <td>' + kinesisCtrl.measurementTarget + '</td>\n\
                                                    <td>' + kinesisCtrl.refValue + '</td> \n\
                                                    <td>' + kinesisCtrl.monitoringPeriod + '</td>\n\
                                                    <td>' + kinesisCtrl.backoffNo + '</td>\n\
                                                    <td>7.03</td>\n\
                                                    <td><div class="play ' + getCtrlBtnCls($ctrlStatus) + '" style="text-shadow:none">' + getCtrlBtnName($ctrlStatus) + '</div></td>\n\
                                                    <td><input type="radio" name="AmazonKinesis" value="' + kinesisCtrl.streamName + '" \n\
                                                    ></td></tr>');
                                    });
                                });
                                break;
                            }
                    }
                }

                function getCtrlBtnCls($ctrlStatus) {
                    var $ctrlBtnCls;
                    ($ctrlStatus === 'Running') ? $ctrlBtnCls = "active" : $ctrlBtnCls = "";
                    return $ctrlBtnCls;
                }

                function getCtrlBtnName($ctrlStatus) {
                    var $ctrlBtnName;
                    ($ctrlStatus === 'Running') ? $ctrlBtnName = "Stop" : $ctrlBtnName = "Start";
                    return $ctrlBtnName;
                }

                function getCtrlStatus(ctrlName, resource, flowId) {
                    return $.ajax({
                        contentType: 'application/json',
                        type: 'GET',
                        url: '../ctrls/getCtrlStatus',
                        async: false,
                        data: {ctrlName: ctrlName, resource: resource, flowId: flowId}
                    }).responseText;
                }

                $(document).on('click', '.play', function() {
                    var $this = $(this);
//                    var $id = $this.attr('id');
                    var $ctrlName = $this.parents('table').attr('id').replace('Tbl', '');
                    var $resource = $(this).closest('tr').find('td:eq(0)').text();
                    var $measurementTarget = $(this).closest('tr').find('td:eq(2)').text();
                    $this.toggleClass('active');
                    if (!$this.hasClass('active')) {
                        $this.text('Start');
                        $.post(
                                'stopCtrl',
                                {ctrlName: $ctrlName, resource: $resource, flowId: $flowId}
                        );
                        $(this).closest('tr').find('td:eq(1)').text('Stopped');
                    } else {
                        $this.text('Stop');
                        $.post(
                                'restartCtrl',
                                {ctrlName: $ctrlName, resource: $resource, flowId: $flowId, measurementTarget: $measurementTarget}
                        );
                        $(this).closest('tr').find('td:eq(1)').text('Running');
                    }
                });

                var timeoutMap = {};
                $(document).on('click', 'input:radio', function() {
                    var $this = $(this);
                    var $ctrlName = $this.attr('name');
                    var $resource = $this.val();
                    var chartDiv = '#' + $resource + 'LineChart';
                    var $timeInterval = parseInt($(this).closest('tr').find('td:eq(4)').text()) * 60000;
                    if ($this.is(':checked')) {
//                        if (!$(chartDiv).length) {
                        $this.parents('div[class="form-style-ctrl-stat"]')
                                .siblings('div[class="form-style-ctrl-diag"]').append(
                                '<div id="' + $resource + 'LineChart" class="epoch category30" style="width: 700px; height: 200px">');
//                        }
                        var lineChart = setupLineChart(chartDiv);
                        drawer(lineChart, $ctrlName, $resource, $flowId, $timeInterval);
                    }
                });

                $(document).on('change', 'input:radio', function() {
                    var $this = $(this);
                    var $resource = $this.val();
                    if (!$this.is(':checked')) {
                        clearTimeout(timeoutMap[$resource]);
                        delete timeoutMap[$resource];
                        $('#' + $resource + 'LineChart').remove();
                    }
                });

                function setupLineChart(chartDiv) {
                    var graph = $(chartDiv).epoch({
                        type: 'time.line',
                        data: [{label: "S1", values: [{time: getTimeStampSec((new Date()).getTime()), y: 0}]},
                            {label: "S2", values: [{time: getTimeStampSec((new Date()).getTime()), y: 0}]}],
                        axes: ['bottom', 'left', 'right']
                    });
                    return graph;
                }

                function getTimeStampSec(timeStampMill) {
                    return parseInt(timeStampMill / 1000);
                }



                function drawer(lineChart, $ctrlName, $resource, $flowId, $timeInterval) {
                    $.get('getCtrlStats',
                            {ctrlName: $ctrlName, resource: $resource, flowId: $flowId, timeStamp: (new Date()).getTime() - $timeInterval},
                    function(ctrlStatRecords) {
                        if (!ctrlStatRecords.length) {
                            console.log(ctrlStatRecords.length);
                        } else {
                            $.each(ctrlStatRecords, function(i, ctrlStatRecord) {
                                lineChart.push([{time: getTimeStampSec(ctrlStatRecord.timeStamp), y: ctrlStatRecord.measurementTargetValue},
                                    {time: getTimeStampSec(ctrlStatRecord.timeStamp), y: ctrlStatRecord.allocatedResource}]);
                            });
                        }
                        timeoutMap[$resource] = setTimeout(function() {
                            drawer(lineChart, $ctrlName, $resource, $flowId, $timeInterval);
                        }, $timeInterval);
                    });
                }




                var pieData = [
                    {label: 'Slice 1', value: 10},
                    {label: 'Slice 2', value: 20}
                ];

                $('#ApacheStormPie').epoch({
                    type: 'pie',
                    data: pieData
                });




                var headers = $('#accordion .accordion-header');
                var contentAreas = $('#accordion .ui-accordion-content ').hide();
                var expandLink = $('.accordion-expand-all');
                // add the accordion functionality
                headers.click(function() {
                    var panel = $(this).next();
                    var isOpen = panel.is(':visible');
                    // open or close as necessary
                    panel[isOpen ? 'slideUp' : 'slideDown']()
                            // trigger the correct custom event
                            .trigger(isOpen ? 'hide' : 'show');
                    // stop the link from causing a pagescroll
                    return false;
                });
                // hook up the expand/collapse all
                expandLink.click(function() {
                    var isAllOpen = $(this).data('isAllOpen');
                    contentAreas[isAllOpen ? 'hide' : 'show']()
                            .trigger(isAllOpen ? 'hide' : 'show');
                });
                // when panels open or close, check to see if they're all open
                contentAreas.on({
                    // whenever we open a panel, check to see if they're all open
                    // if all open, swap the button to collapser
                    show: function() {
                        var isAllOpen = !contentAreas.is(':hidden');
                        if (isAllOpen) {
                            expandLink.text('Collapse All')
                                    .data('isAllOpen', true);
                        }
                    },
                    // whenever we close a panel, check to see if they're all open
                    // if not all open, swap the button to expander
                    hide: function() {
                        var isAllOpen = !contentAreas.is(':hidden');
                        if (!isAllOpen) {
                            expandLink.text('Expand all')
                                    .data('isAllOpen', false);
                        }
                    }
                });
            });
        </script>
    </head>
    <%--
    Technique 1:
    $('#ApacheStormTbl tr:last')
        .after('<tr><td>' + '${flowSetting.stormCtrl.targetTopology}' + '</td>\n\
        <td>Active</td>\n\
        <td>' + '${flowSetting.stormCtrl.measurementTarget}' + '</td>\n\
        <td>' + '${flowSetting.stormCtrl.refValue}' + '</td> \n\
        <td>' + '${flowSetting.stormCtrl.monitoringPeriod}' + '</td>\n\
        <td>' + '${flowSetting.stormCtrl.backoffNo}' + '</td>\n\
        <td>7.03</td>\n\
        <td><div id="' + '${flowSetting.stormCtrl.targetTopology}' + '" class="play active" style="text-shadow:none">pause</div></td>\n\
        <td><input type="radio" name="ApacheStormRadio" value="" checked="checked" ></td></tr>');
    
    Technique 2: Iterate through model object using jsp tags
    <c:forEach items="${flowSetting.kinesisCtrls}" var="kCtrl">
    $('#AmazonKinesisTbl tr:last')
    .after('<tr><td>' + '${kCtrl.streamName}' + '</td>\n\
    <td>Running</td>\n\
    <td>' + '${kCtrl.measurementTarget}' + '</td>\n\
    <td>' + '${kCtrl.refValue}' + '</td> \n\
    <td>' + '${kCtrl.monitoringPeriod}' + '</td>\n\
    <td>' + '${kCtrl.backoffNo}' + '</td>\n\
    <td>7.03</td>\n\
    <td><div id="' + '${kCtrl.streamName}' + '" class="play active" style="text-shadow:none">stop</div></td>\n\
    <td><input type="radio" name="' + system + 'Radio" value="' + '${kCtrl.streamName}' + '" \n\
    checked="checked" ></td></tr>');
    </c:forEach>
    --%>
    <body>
        <tiles:insertDefinition name="defaultbar" />

        <div class="col-xs-12">
            <h3><strong style="color: #555">Elasticity Management of <font color="#67B168">${flow.flowName}</font> Flow</strong></h3>
            <hr>
            <p id="ssman">${flowSetting.stormCtrl.measurementTarget}

            </p>
            <br>
        </div>


        <div  class="jumbotron_body">

            <div class="container">

                <div class="row" >

                    <div class="container">

                        <p class="accordion-expand-holder">
                            <a class="accordion-expand-all" href="#">Expand all</a>
                        </p>
                        <div id="accordion" class="ui-accordion ui-widget ui-helper-reset">
                            <span></span>
                        </div>

                    </div>




                </div>            
            </div>
        </div>
        <div class="jumbotron2">
            <div id="buttonContainer" class="container">
            </div>

        </div>

        <tiles:insertDefinition name="defaultfooter" />

    </body>
</html>