CREATE DATABASE Academy_dz6;
GO
USE Academy_dz6;
GO

CREATE TABLE Teachers (
    Id INT PRIMARY KEY IDENTITY,
    Name NVARCHAR(MAX) NOT NULL,
    Surname NVARCHAR(MAX) NOT NULL
);

CREATE TABLE Assistants (
    Id INT PRIMARY KEY IDENTITY,
    TeacherId INT NOT NULL FOREIGN KEY REFERENCES Teachers(Id)
);

CREATE TABLE Curators (
    Id INT PRIMARY KEY IDENTITY,
    TeacherId INT NOT NULL FOREIGN KEY REFERENCES Teachers(Id)
);

CREATE TABLE Deans (
    Id INT PRIMARY KEY IDENTITY,
    TeacherId INT NOT NULL FOREIGN KEY REFERENCES Teachers(Id)
);

CREATE TABLE Heads (
    Id INT PRIMARY KEY IDENTITY,
    TeacherId INT NOT NULL FOREIGN KEY REFERENCES Teachers(Id)
);

CREATE TABLE Faculties (
    Id INT PRIMARY KEY IDENTITY,
    Building INT CHECK(Building BETWEEN 1 AND 5) NOT NULL,
    Name NVARCHAR(100) UNIQUE NOT NULL,
    DeanId INT NOT NULL FOREIGN KEY REFERENCES Deans(Id)
);

CREATE TABLE Departments (
    Id INT PRIMARY KEY IDENTITY,
    Building INT CHECK(Building BETWEEN 1 AND 5) NOT NULL,
    Name NVARCHAR(100) UNIQUE NOT NULL,
    FacultyId INT NOT NULL FOREIGN KEY REFERENCES Faculties(Id),
    HeadId INT NOT NULL FOREIGN KEY REFERENCES Heads(Id)
);

CREATE TABLE Groups (
    Id INT PRIMARY KEY IDENTITY,
    Name NVARCHAR(10) UNIQUE NOT NULL,
    Year INT CHECK(Year BETWEEN 1 AND 5) NOT NULL,
    DepartmentId INT NOT NULL FOREIGN KEY REFERENCES Departments(Id)
);

CREATE TABLE GroupsCurators (
    Id INT PRIMARY KEY IDENTITY,
    CuratorId INT NOT NULL FOREIGN KEY REFERENCES Curators(Id),
    GroupId INT NOT NULL FOREIGN KEY REFERENCES Groups(Id)
);

CREATE TABLE Subjects (
    Id INT PRIMARY KEY IDENTITY,
    Name NVARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE Lectures (
    Id INT PRIMARY KEY IDENTITY,
    SubjectId INT NOT NULL FOREIGN KEY REFERENCES Subjects(Id),
    TeacherId INT NOT NULL FOREIGN KEY REFERENCES Teachers(Id)
);

CREATE TABLE GroupsLectures (
    Id INT PRIMARY KEY IDENTITY,
    GroupId INT NOT NULL FOREIGN KEY REFERENCES Groups(Id),
    LectureId INT NOT NULL FOREIGN KEY REFERENCES Lectures(Id)
);

CREATE TABLE LectureRooms (
    Id INT PRIMARY KEY IDENTITY,
    Building INT CHECK(Building BETWEEN 1 AND 5) NOT NULL,
    Name NVARCHAR(10) UNIQUE NOT NULL
);

CREATE TABLE Schedules (
    Id INT PRIMARY KEY IDENTITY,
    Class INT CHECK(Class BETWEEN 1 AND 8) NOT NULL,
    DayOfWeek INT CHECK(DayOfWeek BETWEEN 1 AND 7) NOT NULL,
    Week INT CHECK(Week BETWEEN 1 AND 52) NOT NULL,
    LectureId INT NOT NULL FOREIGN KEY REFERENCES Lectures(Id),
    LectureRoomId INT NOT NULL FOREIGN KEY REFERENCES LectureRooms(Id)
);

GO

SELECT DISTINCT lr.Name
FROM LectureRooms lr
JOIN Schedules s ON lr.Id = s.LectureRoomId
JOIN Lectures l ON s.LectureId = l.Id
JOIN Teachers t ON l.TeacherId = t.Id
WHERE t.Name = 'Edward' AND t.Surname = 'Hopper';

GO

SELECT DISTINCT t.Surname
FROM Teachers t
JOIN Assistants a ON t.Id = a.TeacherId
JOIN Lectures l ON t.Id = l.TeacherId
JOIN GroupsLectures gl ON l.Id = gl.LectureId
JOIN Groups g ON g.Id = gl.GroupId
WHERE g.Name = 'F505';

GO

SELECT DISTINCT s.Name
FROM Subjects s
JOIN Lectures l ON s.Id = l.SubjectId
JOIN Teachers t ON l.TeacherId = t.Id
JOIN GroupsLectures gl ON l.Id = gl.LectureId
JOIN Groups g ON gl.GroupId = g.Id
WHERE t.Name = 'Alex' AND t.Surname = 'Carmack' AND g.Year = 5;

GO

SELECT DISTINCT t.Surname
FROM Teachers t
WHERE t.Id NOT IN (
    SELECT DISTINCT l.TeacherId
    FROM Lectures l
    JOIN Schedules s ON l.Id = s.LectureId
    WHERE s.DayOfWeek = 1
);

GO

SELECT lr.Name, lr.Building
FROM LectureRooms lr
WHERE lr.Id NOT IN (
    SELECT LectureRoomId
    FROM Schedules
    WHERE DayOfWeek = 3 AND Week = 2 AND Class = 3
);

GO

SELECT DISTINCT t.Name + ' ' + t.Surname AS FullName
FROM Teachers t
JOIN Faculties f ON f.DeanId = t.Id OR f.Id IN (
    SELECT d.FacultyId
    FROM Departments d
    JOIN Groups g ON d.Id = g.DepartmentId
    JOIN GroupsLectures gl ON g.Id = gl.GroupId
    JOIN Lectures l ON gl.LectureId = l.Id
    WHERE l.TeacherId = t.Id
)
WHERE f.Name = 'Computer Science'
  AND t.Id NOT IN (
    SELECT c.TeacherId
    FROM Curators c
    JOIN GroupsCurators gc ON c.Id = gc.CuratorId
    JOIN Groups g ON gc.GroupId = g.Id
    JOIN Departments d ON g.DepartmentId = d.Id
    WHERE d.Name = 'Software Development'
);

GO

SELECT DISTINCT Building FROM Faculties
UNION
SELECT DISTINCT Building FROM Departments
UNION
SELECT DISTINCT Building FROM LectureRooms;

GO

SELECT t.Name + ' ' + t.Surname AS FullName, 'Декан' AS Role FROM Teachers t
JOIN Deans d ON t.Id = d.TeacherId
UNION ALL
SELECT t.Name + ' ' + t.Surname, 'Завідувач' FROM Teachers t
JOIN Heads h ON t.Id = h.TeacherId
UNION ALL
SELECT t.Name + ' ' + t.Surname, 'Викладач' FROM Teachers t
WHERE t.Id NOT IN (
    SELECT TeacherId FROM Deans
    UNION
    SELECT TeacherId FROM Heads
    UNION
    SELECT TeacherId FROM Curators
    UNION
    SELECT TeacherId FROM Assistants
)
UNION ALL
SELECT t.Name + ' ' + t.Surname, 'Куратор' FROM Teachers t
JOIN Curators c ON t.Id = c.TeacherId
UNION ALL
SELECT t.Name + ' ' + t.Surname, 'Асистент' FROM Teachers t
JOIN Assistants a ON t.Id = a.TeacherId;

GO

SELECT DISTINCT s.DayOfWeek
FROM Schedules s
JOIN LectureRooms lr ON s.LectureRoomId = lr.Id
WHERE lr.Name IN ('A311', 'A104') AND lr.Building = 6;