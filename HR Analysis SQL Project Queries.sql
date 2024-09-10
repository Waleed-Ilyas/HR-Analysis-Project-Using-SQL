CREATE TABLE Employees (
    EmployeeID SERIAL PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Gender VARCHAR(10),
    DOB DATE,
    DepartmentID INT
);

CREATE TABLE Departments (
    DepartmentID SERIAL PRIMARY KEY,
    DepartmentName VARCHAR(50)
);

CREATE TABLE Salaries (
    EmployeeID INT,
    Salary DECIMAL(10, 2),
    Bonus DECIMAL(10, 2),
    PayDate DATE,
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

CREATE TABLE JobRoles (
    RoleID SERIAL PRIMARY KEY,
    RoleName VARCHAR(50),
    DepartmentID INT,
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);

CREATE TABLE Attendance (
    EmployeeID INT,
    Date DATE,
    Status VARCHAR(20),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

CREATE TABLE Promotions (
    EmployeeID INT,
    OldRoleID INT,
    NewRoleID INT,
    PromotionDate DATE,
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID),
    FOREIGN KEY (OldRoleID) REFERENCES JobRoles(RoleID),
    FOREIGN KEY (NewRoleID) REFERENCES JobRoles(RoleID)
);


-- 1. List all employees working in the 'IT' department.

SELECT e.FirstName, e.LastName
FROM Employees e
JOIN Departments d ON e.DepartmentID = d.DepartmentID
WHERE d.DepartmentName = 'IT';

-- 2. Retrieve the names and salaries of all employees earning more than $70,000.

SELECT e.FirstName, e.LastName, s.Salary
FROM Employees e
JOIN Salaries s ON e.EmployeeID = s.EmployeeID
WHERE s.Salary > 70000;

-- 3. Count the number of employees in each department.

SELECT d.DepartmentName, COUNT(e.EmployeeID) AS EmployeeCount
FROM Employees e
JOIN Departments d ON e.DepartmentID = d.DepartmentID
GROUP BY d.DepartmentName;

-- 4. Find the total number of days an employee with ID 5 was absent.

SELECT COUNT(*) AS AbsentDays
FROM Attendance
WHERE EmployeeID = 5 AND Status = 'Absent';

-- 5. List all employees who were promoted in the year 2023.

SELECT e.FirstName, e.LastName, p.PromotionDate, jr_old.RoleName
AS OldRole, jr_new.RoleName AS NewRole FROM Employees e
JOIN Promotions p ON e.EmployeeID = p.EmployeeID
JOIN JobRoles jr_old ON p.OldRoleID = jr_old.RoleID
JOIN JobRoles jr_new ON p.NewRoleID = jr_new.RoleID
WHERE EXTRACT(YEAR FROM p.PromotionDate) = 2023;

-- 6. Retrieve the average salary for each department.

SELECT d.DepartmentName, AVG(s.Salary) AS AvgSalary
FROM Employees e
JOIN Salaries s ON e.EmployeeID = s.EmployeeID
JOIN Departments d ON e.DepartmentID = d.DepartmentID
GROUP BY d.DepartmentName;

-- 7. Find the top 3 employees with the highest bonuses.

SELECT e.FirstName, e.LastName, s.Bonus
FROM Employees e
JOIN Salaries s ON e.EmployeeID = s.EmployeeID
ORDER BY s.Bonus DESC
LIMIT 3;

-- 8. Get the total attendance count for each employee.

SELECT e.FirstName, e.LastName, 
COUNT(a.Status) AS AttendanceCount
FROM Employees e
JOIN Attendance a 
ON e.EmployeeID = a.EmployeeID
GROUP BY e.FirstName, e.LastName;

-- 9. Find the employee who has the longest continuous service without being absent (consider continuous days of presence).

SELECT EmployeeID, MAX(ContinuousDays) AS MaxContinuousDays
FROM (
SELECT EmployeeID,Status, 
SUM(CASE WHEN Status = 'Present' THEN 1 ELSE 0 END) 
OVER (PARTITION BY EmployeeID ORDER BY Date) AS ContinuousDays
 FROM Attendance
  WHERE Status = 'Present'
) AS ContinuousPresent
GROUP BY EmployeeID
ORDER BY MaxContinuousDays DESC
LIMIT 1;


-- 10. Identify the highest salary in each department and list all employees who earn this highest salary.

WITH MaxSalaryPerDept AS (
    SELECT d.DepartmentID, MAX(s.Salary) AS MaxSalary
    FROM Employees e
    JOIN Salaries s ON e.EmployeeID = s.EmployeeID
    JOIN Departments d ON e.DepartmentID = d.DepartmentID
    GROUP BY d.DepartmentID
)
SELECT e.FirstName, e.LastName, d.DepartmentName, s.Salary
FROM Employees e
JOIN Salaries s ON e.EmployeeID = s.EmployeeID
JOIN Departments d ON e.DepartmentID = d.DepartmentID
JOIN MaxSalaryPerDept msp ON d.DepartmentID = msp.DepartmentID AND s.Salary = msp.MaxSalary;


-- 11. Calculate the year-on-year promotion rate for the 'Manager' role.

SELECT EXTRACT(YEAR FROM p.PromotionDate) AS Year, 
COUNT(p.EmployeeID) AS Promotions
FROM Promotions p
JOIN JobRoles jr ON p.NewRoleID = jr.RoleID
WHERE jr.RoleName = 'Manager'
GROUP BY EXTRACT(YEAR FROM p.PromotionDate)
ORDER BY Year;











