using WebSkeletonSPA.Utilities;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllersWithViews();
var blobConnectionString = builder.Configuration.GetValue<string>("Blob:ConnectionString");

if(String.IsNullOrWhiteSpace(blobConnectionString))
{
    throw new ApplicationException("App Setting Blob:ConnectionString is required, and cannot be empty.");
}

var blobSource = new BlobSource(blobConnectionString, "myblobcontainer");
builder.Services.AddSingleton<IBlobSource>(blobSource);

var app = builder.Build();

app.MapControllers();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();

app.UseAuthorization();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

app.Run();
