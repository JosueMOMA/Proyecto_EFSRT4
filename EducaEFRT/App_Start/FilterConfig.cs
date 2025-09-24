using EducaEFRT.Filters;
using System.Web;
using System.Web.Mvc;

namespace EducaEFRT
{
    public class FilterConfig
    {
        public static void RegisterGlobalFilters(GlobalFilterCollection filters)
        {
            filters.Add(new HandleErrorAttribute());
            filters.Add(new NoCacheAttribute());
            filters.Add(new AuthorizeAttribute());
        }
    }
}
