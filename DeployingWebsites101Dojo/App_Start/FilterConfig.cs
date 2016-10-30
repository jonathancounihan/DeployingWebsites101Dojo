using System.Web;
using System.Web.Mvc;

namespace DeployingWebsites101Dojo
{
    public class FilterConfig
    {
        public static void RegisterGlobalFilters(GlobalFilterCollection filters)
        {
            filters.Add(new HandleErrorAttribute());
        }
    }
}
