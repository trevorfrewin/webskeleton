CREATE TABLE EmployeeAddresses (
    AddressID INT PRIMARY KEY,
    EmployeeID INT,
    LineOne NVARCHAR(50),
    LineTwo NVARCHAR(50),
    Postcode NVARCHAR(15)
);