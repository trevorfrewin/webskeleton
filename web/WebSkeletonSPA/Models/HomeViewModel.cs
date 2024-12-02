namespace WebSkeletonSPA.Models;

public class HomeViewModel
{
    public required string BlobPrefix { get; set; }

    public required IEnumerable<dynamic> BlobNames { get; set; }
}
