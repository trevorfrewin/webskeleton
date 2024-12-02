namespace WebSkeletonSPA.Utilities;

public interface IBlobSource
{
    IEnumerable<dynamic> List(string prefix = "");

    void Delete(string blobName);

    dynamic Get(string blobName);

    void Set(string blobName, dynamic blob);
}
