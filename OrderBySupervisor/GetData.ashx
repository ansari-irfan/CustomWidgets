<%@ WebHandler Language="C#" Class="Handler" %>

using System;
using System.Web;
using FileBound;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using System.Globalization;
using Newtonsoft.Json;

public class Handler : IHttpHandler, System.Web.SessionState.IRequiresSessionState
{
    public void ProcessRequest(HttpContext context)
    {
        try
        {
            GetDataResults data;
            var method = !string.IsNullOrEmpty(context.Request.QueryString["Method"]) ? context.Request.QueryString["Method"].ToLower() : "";

            switch (method)
            {
                case "loaddata":
                    data = GetData(context); ;
                    break;
                case "getprojects":
                    data = GetProjects(context);
                    break;
                case "fieldvalue":
                    data = GetFieldValue(context);
                    break;
                default:
                    throw new Exception("Invalid Method");
            }

            if (data.Result == string.Empty)
            {
                return;
            }
            context.Response.ContentType = data.ContentType;
            context.Response.StatusCode = data.StatusCode;
            context.Response.Write(data.Result);
        }
        catch (Exception ex)
        {
            context.Response.StatusCode = 500;
            context.Response.ContentType = "text/plain";
            context.Response.Write("Error from GetData.ashx: " + ex.Message);
        }

    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

    public GetDataResults GetData(HttpContext context)
    {
        var results = new GetDataResults();
        string Search_Value;
        long projectId;
        long groupByFieldId;
        string FieldType = context.Request.QueryString["FieldType"];
        string SearchToDate = context.Request.QueryString["SearchTo"];
        string SearchFromDate = context.Request.QueryString["SearchFrom"];
        Search_Value = context.Request.QueryString["Search"];
        var business = (FileBound.Business.Standard)context.Session["FBBusiness"];
        long.TryParse(context.Request.QueryString["ProjectID"], out projectId);
        long.TryParse(context.Request.QueryString["GroupByFieldID"], out groupByFieldId);

        // first look up the project:
        var projects = new ProjectCollection { Filter = { ProjectID = projectId } };
        business.GetCollection(projects);

        if (projects.TotalCount > 0)
        {
            var fields = new FieldCollection { Filter = { ProjectID = projectId } };
            business.GetCollection(fields);

            if (fields.TotalCount > 0)
            {

                var rpt = new Report
                {
                    Name = "FBReport_OrderBySupervisor",
                    Source = "FBReport_OrderBySupervisor"
                };

                rpt.ReportParms.Add(new ReportParm
                {
                    Name = "ProjectID",
                    Value = projectId.ToString()
                });

                if (Search_Value != null)
                {
                    rpt.ReportParms.Add(new ReportParm
                    {
                        Name = "Search_Value",
                        Value = Search_Value.ToString()
                    });
                }

                if (SearchToDate != null)
                {
                    rpt.ReportParms.Add(new ReportParm
                    {
                        Name = "SearchToDate",
                        Value = SearchToDate.ToString()
                    });
                }

                if (SearchFromDate != null)
                {
                    rpt.ReportParms.Add(new ReportParm
                    {
                        Name = "SearchFromDate",
                        Value = SearchFromDate.ToString()
                    });
                }

                if (groupByFieldId != null)
                {
                    rpt.ReportParms.Add(new ReportParm
                    {
                        Name = "GroupByFldNum",
                        Value = groupByFieldId.ToString()
                    });
                }

                if (FieldType != null)
                {
                    rpt.ReportParms.Add(new ReportParm
                    {
                        Name = "FieldType",
                        Value = FieldType.ToString()
                    });
                }



                DataSet ds;
                try
                {
                    ds = business.RunReport(rpt);
                }
                catch (Exception ex)
                {
                    results.Result = ex.Message;
                    results.StatusCode = 500;
                    results.ContentType = "text/plain";
                    return results;
                }

                var listFieldValues = new List<FieldValue>();

                if (ds.Tables.Count > 0)
                {
 if (ds.Tables[0].Rows.Count > 0)
                    {
                    var table = ds.Tables[0].Rows[0].Table;
                    DataColumn[] subjectColumns = table.Columns.Cast<DataColumn>().ToArray();
                    
                    var col =subjectColumns.Select(c=>c.ColumnName);
                    var column = col.Select(c => new { title = c });

                    List<List<string>> tablevalue = new List<List<string>>(); 

                    foreach (DataRow dr in ds.Tables[0].Rows)
                    {
                        List<string> r = new List<string>();
                       for(int i=0;i<col.Count();i++)
                       {
                           r.Add(Convert.ToString(dr[i]));
                       }

                       tablevalue.Add(r);
                    }
                    
                    results.Result = JsonConvert.SerializeObject(new { columns = column, data = tablevalue });
}
                }
            }
        }

        results.StatusCode = 200;
        results.ContentType = "application/json";
        return results;
    }


    public GetDataResults GetFieldValue(HttpContext context)
    {
        var results = new GetDataResults();
        long projectId;
        long groupByFieldId;


        var business = (FileBound.Business.Standard)context.Session["FBBusiness"];
        long.TryParse(context.Request.QueryString["ProjectID"], out projectId);
        long.TryParse(context.Request.QueryString["GroupByFieldID"], out groupByFieldId);

        // first look up the project:
        var projects = new ProjectCollection { Filter = { ProjectID = projectId } };
        business.GetCollection(projects);

        if (projects.TotalCount > 0)
        {
            var fields = new FieldCollection { Filter = { ProjectID = projectId } };
            business.GetCollection(fields);

            //var mask = "";
            //Field sumField = null;

            if (fields.TotalCount > 0)
            {

                var rpt = new Report
                {
                    Name = "FBReport_FieldValue",
                    Source = "FBReport_FieldValue"
                };

                rpt.ReportParms.Add(new ReportParm
                {
                    Name = "ProjectID",
                    Value = projectId.ToString()
                });

                if (groupByFieldId != null)
                {
                    rpt.ReportParms.Add(new ReportParm
                    {
                        Name = "@GroupByFldNum",
                        Value = groupByFieldId.ToString()
                    });
                }

                DataSet ds;
                try
                {
                    ds = business.RunReport(rpt);
                }
                catch (Exception ex)
                {
                    results.Result = ex.Message;
                    results.StatusCode = 500;
                    results.ContentType = "text/plain";
                    return results;
                }

                var listFieldValues = new List<FieldValue>();

                if (ds.Tables.Count > 0)
                {



                    results.Result = JsonConvert.SerializeObject(ds.Tables);

                }
            }
        }
        //results.Result = projectId.ToString() + "," + groupByFieldId.ToString();
        results.StatusCode = 200;
        results.ContentType = "application/json";
        return results;
    }


    private static GetDataResults GetProjects(HttpContext context)
    {
        var results = new GetDataResults();
        var projectData = new List<ProjectData>();

        var business = (FileBound.Business.Standard)context.Session["FBBusiness"];

        if (business != null)
        {
            // first look up the project:
            var projects = new ProjectCollection();
            business.GetCollection(projects);

            foreach (Project project in projects)
            {
                var fields = new FieldCollection { Filter = { ProjectID = project.ProjectID } };
                business.GetCollection(fields);

                // make sure this project has some index fields:
                if (fields.TotalCount > 0)
                {
                    projectData.Add(new ProjectData() { ProjectId = project.ProjectID, ProjectName = project.Name });
                }
            }

            if (projectData.Any())
            {
                results.Result = JsonConvert.SerializeObject(projectData);
            }
        }

        results.ContentType = "application/json";
        results.StatusCode = 200;
        return results;
    }

    public class GetDataResults
    {
        public string Result { get; set; }
        public int StatusCode { get; set; }
        public string ContentType { get; set; }
    }

    public class FieldValue
    {
        public string FieldName = string.Empty;
        public decimal Value;
        public string Label = string.Empty;
        public string PieChartTooltip = string.Empty;
        public string BarChartTooltip = string.Empty;
    }

    public class ProjectData
    {
        public long ProjectId { get; set; }
        public string ProjectName { get; set; }
        public FieldCollection Fields { get; set; }
    }

    public class Employee
    {
        public List<string> ColumnName { get; set; }
        public Dictionary<string, string> ProjectName { get; set; }
    }
}
