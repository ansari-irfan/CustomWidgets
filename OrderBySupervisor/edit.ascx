<%@ Control Language="C#" Inherits="System.Web.Mvc.ViewUserControl" %>
<%
    var strDivID = Guid.NewGuid().ToString();
    var Business = (FileBound.Business.Standard)Session["FBBusiness"];
    var FBUserId = Business.LoggedInUser.UserID;
%>

<style type="text/css">
    .custom-widget {
        width: 100%;
        padding: 2px;
    }

        .custom-widget input, .custom-widget select {
            width: 150px;
        }
        .custom-widget input.dtpicker{
            width:100px;
        }
</style>

<div class="jqgrid-information" id="divWidgetContainer<%:strDivID %>">
    <br />
    <div id="WidgetError<%:strDivID %>" style="color: Red; font-weight: bold; text-align: center;" />
    <table class="custom-widget">
        <tr>
            <th><%: Resources.WebResources.Workspace_TopTenCharts_WidgetConfiguration%></th>
        </tr>

        <tr class="WidgetContainerRow1">
            <td><%: Resources.WebResources.Widget_EditScreen_TitleText %></td>
            <td align="right">
                <input id="txtTitle<%:strDivID %>" type="text" /></td>
        </tr>
        <tr class="WidgetContainerRow2">
            <td><%: Resources.WebResources.WebSite_General_InfoField_ChartName%>:</td>
            <td align="right">
                <input type="text" title="Chart Name" id="txtChartName<%:strDivID %>" class="validate" /></td>
        </tr>

    </table>
    <br />
    <table class="custom-widget">
        <tr>
            <th><%: Resources.WebResources.Workspace_TopTenCharts_ChartConfiguration%></th>
        </tr>
        <tr class="WidgetContainerRow2">
            <td><%: Resources.WebResources.Workspace_TopTenCharts_Project%>:</td>
            <td align="right">
                <select title="Project" id="ddlProjects<%:strDivID %>" class="validate"></select></td>
        </tr>
        <tr class="WidgetContainerRow1">
            <td>Order by</td>
            <td align="right">
                <select title="order By" id="ddlGroupBy<%:strDivID %>" disabled="disabled" class="validate"></select></td>
        </tr>
        <tr class="WidgetContainerRow2">
            <td>Search by:<span id="dateFormat<%:strDivID %>" style="display: none; font-weight: bold;"> (dd/mm/yyyy)</span></td>
            <td align="right">
                <%--<select title="search By" id="ddlField<%:strDivID %>" class="validate"></select>--%>
                <input type="text" id="txtField<%:strDivID %>" />
                <span id="date<%:strDivID %>" style="display: none;">
                    <input class="dtpicker" type="text" id="txtFromDate<%:strDivID %>" />to
                    <input class="dtpicker"type="text" id="txtToDate<%:strDivID %>" /></span>
            </td>
        </tr>
        <tr>
            <td colspan="2">
                <input id="hdnUserWidgetID<%:strDivID%>" type="hidden" />
                <input id="hdnTitle<%:strDivID%>" type="hidden" />
                <input id="hdnfieldType<%:strDivID%>" type="hidden" />
            </td>
        </tr>
        <tr class="WidgetContainerRow2">
            <td>&nbsp;</td>
            <td align="right">
                <a id="lnkCancel<%:strDivID%>" href="#" style="text-decoration: none;">
                    <img src='<%: Url.Content("~/Content/images/Standard Icons/PNG/FB_Cancel_16.png") %>'
                        alt='<%: Resources.WebResources.WebSite_General_ToolTip_Cancel %>'
                        title='<%: Resources.WebResources.WebSite_General_ToolTip_Cancel %>' />
                </a>
                &nbsp;
                <a id="lnkSave<%:strDivID%>" href="#" style="text-decoration: none;">
                    <img src='<%: Url.Content("~/Content/images/Standard Icons/PNG/FB_Save_16.png") %>'
                        alt='<%: Resources.WebResources.WebSite_General_ToolTip_Save %>'
                        title='<%: Resources.WebResources.WebSite_General_ToolTip_Save %>' />
                </a>
            </td>
        </tr>
    </table>
</div>

<script type="text/javascript">

    var UserWidgetId = Number(<%:ViewData["UserWidgetID"]%>);
    $('#hdnUserWidgetID<%:strDivID%>').val(UserWidgetId);
    $(document).ready(function () {

        // this doesn't work in the external scripts so get the value now:
        var numberFieldType = '<%= (int)FBEnumerations.FieldType.DateField %>';

        // load the edit widget:
        LoadEdit("<%:strDivID%>", "<%:FBUserId%>", UserWidgetId, numberFieldType);




        //================================================================================================
        //
        // EDIT WIDGET - START
        //
        //================================================================================================

        function LoadEdit(uniqueId, FBUserId, UserWidgetId, numberFieldType) {
            $("#txtTitle" + uniqueId).val($("#title_" + $('#hdnUserWidgetID' + uniqueId).val()).html());
            $('#hdnTitle' + uniqueId).val($("#title_" + $('#hdnUserWidgetID' + uniqueId).val()).html());


            // LOAD THE CURRENTLY SELECTED VALUES:
            LoadCurrentSettings(uniqueId, FBUserId, UserWidgetId, numberFieldType);

            $("#lnkSave" + uniqueId).bind("click", function () {

                var validSave = true;

                $(".validate").each(function () {
                    switch ($(this).attr("tagName")) {
                        case "INPUT":
                            if ($(this).val() == "") {
                                $("#WidgetError" + uniqueId).text("You must specify a value for '" + $(this).attr("title") + "'");
                                validSave = false;
                                return false;
                            }
                            break;
                        case "SELECT":
                            if ($(this).val() == "-1") {
                                $("#WidgetError" + uniqueId).text("You must specify a value for '" + $(this).attr("title") + "'");
                                validSave = false;
                                return false;
                            }
                            break;
                    }
                });

                if (validSave) {

                    if ($("#txtTitle" + uniqueId).val() == '')
                        $("#txtTitle" + uniqueId).val("Order By Supervisor");

                    var data = {
                        Title: $("#txtTitle" + uniqueId).val(),
                        ChartType: $("#ddlChartTypes" + uniqueId).val(),
                        ChartName: $("#txtChartName" + uniqueId).val(),
                        ProjectId: $("#ddlProjects" + uniqueId).val(),
                        GroupByFieldId: $("#ddlGroupBy" + uniqueId).val(),
                        FieldValue: $("#hdnfieldType" + uniqueId).val() == 3 ? "" : $("#txtField" + uniqueId).val(),
                        ToDateValue: $("#txtToDate" + uniqueId).val(),
                        FromDateValue: $("#txtFromDate" + uniqueId).val(),
                        FieldType: $("#hdnfieldType" + uniqueId).val(),
                    }

                    var json = JSON.stringify(data);

                    FBAPI.AddExtendedProperty("CustomWidgetData_" + FBUserId + "_" + UserWidgetId, json, '',
                            function () {
                                // successful save:
                                $("#divWidgetContainer" + uniqueId).parents(".widget").find(".editWidgetlink").click();
                            },
                            function (e) {
                                // failed saving:
                                $("#WidgetError" + uniqueId).text(e.responseText);
                            }
                        );

                    FBAPI.AddExtendedProperty("Title_" + UserWidgetId, $("#txtTitle" + uniqueId).val(), '',
                            function () {
                                // successful save:                	    
                            },
                            function (e) {
                                // failed saving:                        
                            }
                        );
                }
            });

            $("#lnkCancel" + uniqueId).bind("click", function () {
                $("#divWidgetContainer" + uniqueId).parents(".widget").find(".editWidgetlink").click();
                $("#title_" + $('#hdnUserWidgetID' + uniqueId).val()).html($('#hdnTitle' + uniqueId).val());
            });

            // WHEN THE PROJECT CHANGES -
            // WE NEED TO LOOK UP THE FIELDS FOR THAT PROJECT AND UPDATE THE GROUP-BY FIELD DROPDOWN.
            $("#ddlProjects" + uniqueId).change(function () {
                // CLEAR DROPDOWNS:
                $("#ddlGroupBy" + uniqueId).empty();
                
                FBAPI.FindFields(this.value, function (fieldData) {

                    // SUCCESS:
                    if (fieldData != null && fieldData.length > 0) {
                        // POPULATE GROUP-BY AND SUM-FIELD DROPDOWNS:
                        $.each(fieldData, function () {

                            $("#ddlGroupBy" + uniqueId).append('<option value="' + this.Number + '">' + this.Name + '</option>');
                            
                        });

                        $("#ddlGroupBy" + uniqueId).get(0).selectedIndex = 0;
                    }

                    // ENABLE THE DROPDOWNS:
                    $("#ddlGroupBy" + uniqueId).attr('disabled', false);

                    $("#ddlGroupBy" + uniqueId).change();
                }, function () {
                    DisplayConfigError(uniqueId, "failed to look up fields on project change");
                });
            });

            $("#ddlGroupBy" + uniqueId).change(function () {

                FBAPI.FindFields($("#ddlProjects" + uniqueId).val(), function (fieldData) {

                    // SUCCESS:

                    if (fieldData != null && fieldData.length > 0) {
                        // POPULATE GROUP-BY AND SUM-FIELD DROPDOWNS:
                        $.each(fieldData, function () {
                            if ($("#ddlGroupBy" + uniqueId).val() == this.Number) {
                                $("#hdnfieldType" + uniqueId).val(this.Type);
                                if (this.Type == numberFieldType) {
                                    $("#date" + uniqueId).show();
                                    $("#txtField" + uniqueId).hide();
                                    $("#dateFormat" + uniqueId).show();

                                    //$("#txtDateField" + uniqueId).val("");
                                }
                                else {
                                    $("#date" + uniqueId).hide();
                                    $("#dateFormat" + uniqueId).hide();
                                    $("#txtField" + uniqueId).show();
                                    $("#txtToDate" + uniqueId).val("");
                                    $("#txtFromDate" + uniqueId).val("");
                                    //$("#txtField" + uniqueId).val("");
                                }
                            }


                        });

                        
                    }
                   
                }, function () {
                    DisplayConfigError(uniqueId, "failed to look up fields on project change");
                });
            });

            $("#txtFromDate" + uniqueId).datepicker({ dateFormat: 'dd/mm/yy' });
            $("#txtToDate" + uniqueId).datepicker({ dateFormat: 'dd/mm/yy' });

        }
        
        function LoadCurrentSettings(uniqueId, FBUserId, UserWidgetId, numberFieldType) {

            FBAPI.FindExtendedProperty("CustomWidgetData_" + FBUserId + "_" + UserWidgetId,
                    function (msg) {

                        var getProjectsURL = $.url("Widgets/OrderBySupervisor/GetData.ashx?Method=GetProjects");
                        var $ddlProjects = $("#ddlProjects" + uniqueId);
                        var $title = $("#txtTitle" + uniqueId);

                        if (msg != null && msg.length > 0) {

                            var data = $.parseJSON(msg[0].PropertyValue);
                            if (data.Title == undefined || data.Title == '') data.Title = "Order By Supervisor"; //default
                            $title.val(data.Title);

                            // first load all projects:
                            $.ajax({
                                url: getProjectsURL,
                                type: "GET",
                                cache: false,
                                success: function (projectData) {
                                    // success:
                                    var projectOptions = "";
                                    for (var i = 0; i < projectData.length; i++) {
                                        if (projectData[i].ProjectId == data.ProjectId) {
                                            projectOptions += '<option selected="selected" value="' + projectData[i].ProjectId + '">' + projectData[i].ProjectName + '</option>';
                                        } else {
                                            projectOptions += '<option value="' + projectData[i].ProjectId + '">' + projectData[i].ProjectName + '</option>';
                                        }
                                    }
                                    if (projectOptions != "") {
                                        $ddlProjects.append(projectOptions);
                                        $ddlProjects.val(data.ProjectId);
                                    }
                                },
                                error: function (jqXHR) {
                                    DisplayConfigError(uniqueId, jqXHR.responseText);
                                }
                            });

                            $("#ddlChartTypes" + uniqueId).val(data.ChartType);
                            $("#txtChartName" + uniqueId).val(data.ChartName);

                            LoadFields(uniqueId, data.ProjectId, data.GroupByFieldId, data.FieldValue, data.ToDateValue, data.FromDateValue, data.FieldType, numberFieldType);

                        } else {

                            // no data found, we need to load fields for the first (selected) project:
                            $title.val("OrderBySupervisor");

                            $.ajax({
                                url: getProjectsURL,
                                type: "GET",
                                cache: false,
                                success: function (projectData) {
                                    // success:
                                    var projectOptions = "";
                                    for (var i = 0; i < projectData.length; i++) {
                                        projectOptions += '<option value="' + projectData[i].ProjectId + '">' + projectData[i].ProjectName + '</option>';
                                    }
                                    if (projectOptions !== "") {
                                        $ddlProjects.append(projectOptions);
                                    }

                                    if (projectData.length > 0) {
                                        $ddlProjects.get(0).selectedIndex = 0;
                                    }

                                    var pid = $ddlProjects.val(); // select first proj in list:

                                    LoadFields(uniqueId, pid, null, null, null, null, numberFieldType);
                                },
                                error: function (jqXHR) {
                                    DisplayConfigError(uniqueId, jqXHR.responseText);
                                }
                            });

                        }
                    },
                    function () {
                        DisplayConfigError(uniqueId, "failed to look up the Chart Name");
                    }
                );
        }

        function LoadFields(uniqueId, projectId, groupByFieldId, fieldValue, toDateValue, fromDateValue, fieldType, numberFieldType) {

            // LOOK UP THE FIELDS FOR THIS PROJECT:
            FBAPI.FindFields(projectId, function (fieldData) {

                if (fieldData != null && fieldData.length > 0) {

                    var $groupBy = $("#ddlGroupBy" + uniqueId);
                    //var $sum = $("#ddlGroupBy" + uniqueId);

                    var $toDate = $("#txtToDate" + uniqueId);
                    var $fromDate = $("#txtFromDate" + uniqueId);


                    // THERE ARE FIELDS, SO ENABLE THE "GROUP BY" DROP DOWN:
                    $groupBy.attr("disabled", false);
                    
                    // FOR EACH FIELD... 
                    $.each(fieldData, function () {
                        // ADD EACH FIELD TO THE GROUP-BY DROP DOWN, SELECT IF IT WAS THE SAVED VALUE:
                        if (this.FieldID == groupByFieldId) {
                            $groupBy.append('<option selected="selected" value="' + this.Number + '">' + this.Name + '</option>');
                        } else {
                            $groupBy.append('<option value="' + this.Number + '">' + this.Name + '</option>');
                        }

                        // ADD THIS FIELD TO THE SUM-OPTOIN DROP DOWN IF NUMERIC, SELECT IF IT WAS THE SAVED VALUE:
                        if (this.Type == numberFieldType) {
                            $("#date" + uniqueId).show();
                            $("#dateFormat" + uniqueId).show();
                            $("#txtField" + uniqueId).hide();

                            $toDate.val(toDateValue);
                            $fromDate.val(fromDateValue);
                        }
                    });

                    //DDLFieldChange(FieldValue,uniqueId)
                    if (groupByFieldId == null) {
                        $groupBy.get(0).selectedIndex = 0;
                    } else {
                        $groupBy.val(groupByFieldId);
                    }
                    $("#ddlGroupBy" + uniqueId).change();
                    $("#txtField" + uniqueId).val(fieldValue);
                    $("#hdnfieldType" + uniqueId).val(fieldType);


                }
            });

        }

        //================================================================================================
        //
        // EDIT WIDGET - END
        //
        //================================================================================================

    });

    function DisplayConfigError(uniqueId, msg) {
        $("#WidgetError" + uniqueId).text(msg);
        $("#WidgetError" + uniqueId).show();
        $("#chart-title" + uniqueId).hide();
        $("#chart-holder" + uniqueId).hide();
        $("#chart-legend" + uniqueId).hide();
    }

    function ShowLoading() {
        $("#divWidgetContainer" + uniqueId).append("<div id='loading" + uniqueId + "' style='width:100%;text-align:center;'><img class='fileboundLoadingIcon' src='" + $.url('/Content/images/loading/FB-Loading-icon-c_v4-64.gif') + "' alt='loading data' style='text-align:center;' /></div>");
    }

    function RemoveLoading() {
        $("#loading" + uniqueId).remove();
    }

</script>


