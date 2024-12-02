using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;

namespace WebSkeletonSPA.Utilities;

public class BlobSource(string connectionString, string containerName) : IBlobSource
{
    private string ConnectionString { get; } = connectionString;

    private string ContainerName { get; } = containerName;

    public void Delete(string blobName)
    {
        throw new NotImplementedException();
    }

    public dynamic Get(string blobName)
    {
        throw new NotImplementedException();
    }

    public IEnumerable<dynamic> List(string namePrefix = "")
    {
        var blobServiceClient = new BlobServiceClient(this.ConnectionString);

        BlobContainerClient containerClient = blobServiceClient.GetBlobContainerClient(this.ContainerName);

        return containerClient.GetBlobs(Azure.Storage.Blobs.Models.BlobTraits.None, Azure.Storage.Blobs.Models.BlobStates.None, namePrefix);
    }

    public void Set(string blobName, dynamic blob)
    {
        throw new NotImplementedException();
    }
}