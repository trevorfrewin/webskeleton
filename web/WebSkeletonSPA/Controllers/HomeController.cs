using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using WebSkeletonSPA.Models;
using WebSkeletonSPA.Utilities;

namespace WebSkeletonSPA.Controllers;

public class HomeController : Controller
{
    private readonly ILogger<HomeController> _logger;
    private readonly IBlobSource _blobSource;

    public HomeController(IBlobSource blobSource, ILogger<HomeController> logger)
    {
        _blobSource = blobSource;
        _logger = logger;
    }

    public IActionResult Index(HomeViewModel model)
    {
        model.BlobNames = this.Filter(new SearchRequest { Prefix = model.BlobPrefix });

        return View(model);
    }

    [HttpPost]
    public IEnumerable<dynamic> Filter([FromBody] SearchRequest searchQuery)
    {
        return this._blobSource.List(searchQuery.Prefix);
    }

    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }
}