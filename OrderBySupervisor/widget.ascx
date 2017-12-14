<%@ Control Language="C#" Inherits="System.Web.Mvc.ViewUserControl" %>

<%
    string strDivID = Guid.NewGuid().ToString();
    FileBound.Business.Standard Business = (FileBound.Business.Standard)Session["FBBusiness"];
    long FBUserId = Business.LoggedInUser.UserID;
%>
<style type="text/css">
    .title {
        width: 100%;
        height: 40px;
        line-height: 40px;
        font-family: Arial Black;
        font-size: 16pt;
        text-align: center;
        vertical-align: middle;
    }

    .dataTables_wrapper {
        min-width: 600px;
    }

    .dataTable tr th {
        color: #fff;
    }

    .dataTable tr th, .dataTable tr td {
        padding: 5px 10px;
    }

    .dataTable thead tr {
        background-color: #8e8c8d;
    }

    .dataTable tbody tr:nth-child(odd) {
        background-color: #fff;
    }

    .dataTable tbody tr:nth-child(even) {
        background-color: #f4f5f5;
    }

    table.dataTable thead .sorting:after, table.dataTable thead .sorting_asc:after, table.dataTable thead .sorting_desc:after, table.dataTable thead .sorting_asc_disabled:after, table.dataTable thead .sorting_desc_disabled:after {
        opacity: 1;
        color: #fff;
        bottom: 3px;
    }

    .dataTables_wrapper > .row {
        margin: 0;
    }

        .dataTables_wrapper > .row > .col-sm-12 {
            padding: 0;
        }
</style>

<div id="divWidgetContainer<%:strDivID%>">
    <input type="hidden" id="userWidgetId<%:strDivID%>" />
    <center><span id="chart-title<%:strDivID %>" class="title"></span></center>
    <div id="tableSpacer<%:strDivID%>" style="margin: 10px; vertical-align: middle; overflow-x: auto;">
        <table id="grid<%:strDivID %>" style="width: 100%">
            <tbody>
        </table>

    </div>
</div>

<script type="text/javascript">

    $(document).ready(function () {
        if (!$("link[href='" + $.url('/Content/CustomWidget/dataTables.bootstrap.min.css') + "']").length) $('<link href="' + $.url('/Content/CustomWidget/dataTables.bootstrap.min.css') + '" rel="stylesheet" type="text/css"">').appendTo("head");
        if (!$("script[src='" + $.url('/Scripts/CustomWidget/jquery.dataTables.min.js') + "']").length) $('<script src="' + $.url('/Scripts/CustomWidget/jquery.dataTables.min.js') + '" type="text/javascript">').appendTo("head");
        if (!$("script[src='" + $.url('/Scripts/CustomWidget/dataTables.bootstrap.min.js') + "']").length) $('<script src="' + $.url('/Scripts/CustomWidget/dataTables.bootstrap.min.js') + '" type="text/javascript">').appendTo("head");
        if (!$("script[src='" + $.url('/Scripts/CustomWidget/dataTables.responsive.min.js') + "']").length) $('<script src="' + $.url('/Scripts/CustomWidget/dataTables.responsive.min.js') + '" type="text/javascript">').appendTo("head");
        if (!$("script[src='" + $.url('/Scripts/CustomWidget/responsive.bootstrap.min.js') + "']").length) $('<script src="' + $.url('/Scripts/CustomWidget/responsive.bootstrap.min.js') + '" type="text/javascript">').appendTo("head");

        if ($("#userWidgetId<%:strDivID%>").val() == "") {
            $("#userWidgetId<%:strDivID%>").val(Number(<%:ViewData["UserWidgetID"]%>));
        }
        //$("#tbl").DataTable();
        LoadWidget("<%:strDivID %>", "<%:FBUserId %>", $("#userWidgetId<%:strDivID%>").val());

        function LoadWidget(uniqueId, FBUserId, UserWidgetId) {
            var divContainerID_FBProjects = "divWidgetContainer<%:strDivID%>";
            var loc = window.location.pathname;
            var dir = loc.substring(0, loc.lastIndexOf('/'));
            FBAPI.FindExtendedProperty("CustomWidgetData_" + FBUserId + "_" + UserWidgetId,
                    function (msg) {
                        if (msg != null && msg.length > 0) {

                            var savedChartJSON = $.parseJSON(msg[0].PropertyValue);
                            $("#chart-title" + uniqueId).text(savedChartJSON.ChartName)
                            var getDataURL = $.url("/Widgets/OrderBySupervisor/GetData.ashx?Method=loadData&ProjectID=" + savedChartJSON.ProjectId + "&GroupByFieldID=" + savedChartJSON.GroupByFieldId + "&Search=" + savedChartJSON.FieldValue + "&SearchFrom=" + savedChartJSON.FromDateValue + "&SearchTo=" + savedChartJSON.ToDateValue + "&FieldType=" + savedChartJSON.FieldType);

                            $.ajax({
                                async: true,
                                url: getDataURL,
                                success: function (response) {

                                    $("#grid" + uniqueId).dataTable({
                                        columns: response.columns, data: response.data,
                                        "pageLength": 10,

                                        "language": {
                                            "emptyTable": "No matching records found",
                                            "paginate": {
                                                "previous": "«",
                                                "next": "»"
                                            }
                                        },
                                    });
                                }

                            });

                        }
                    });

        }



    });
    
</script>
