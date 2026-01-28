-- ===============================================
-- CAB BOOKING SYSTEM DATA ANALYSIS PROJECT (MySQL)
-- ===============================================

CREATE DATABASE  ProjectDB;
USE ProjectDB;

-- 1. CUSTOMERS TABLE
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    Name VARCHAR(100),
    Phone VARCHAR(15),
    Email VARCHAR(100),
    JoinDate DATE
);

-- select * from customers;

INSERT INTO Customers (CustomerID, Name, Phone, Email, JoinDate) VALUES
(1, 'Rajan Pandey', '9876543210', 'rajan@example.com', '2024-01-10'),
(2, 'Jay Tiwari', '8765432109', 'jay@example.com', '2024-02-15'),
(3, 'Rakesh Yadav', '7654321098', 'rakesh1@example.com', '2024-03-01'),
(4, 'Harsh Singh', '6543210987', 'harshu@example.com', '2024-04-05');

-- 2. DRIVERS TABLE
CREATE TABLE Drivers (
    DriverID INT PRIMARY KEY,
    Name VARCHAR(100),
    Phone VARCHAR(15),
    LicenseNumber VARCHAR(50),
    JoinDate DATE,
    Rating FLOAT
);
-- select * from Drivers;
INSERT INTO Drivers (DriverID, Name, Phone, LicenseNumber, JoinDate, Rating) VALUES
(1, 'Raj Singh', '9123456789', 'DL12345678', '2023-09-01', 4.5),
(2, 'Sunny Chaudhary', '9234567890', 'DL87654321', '2023-10-12', 3.2),
(3, 'Anshu P', '9345678901', 'DL23456789', '2024-01-20', 2.8),
(4, 'Alina Kapoor', '9456789012', 'DL34567890', '2024-03-15', 4.0);

-- 3. CABS TABLE
CREATE TABLE Cabs (
    CabID INT PRIMARY KEY,
    DriverID INT,
    CabType VARCHAR(20),
    PlateNumber VARCHAR(20),
    FOREIGN KEY (DriverID) REFERENCES Drivers(DriverID)
);

INSERT INTO Cabs (CabID, DriverID, CabType, PlateNumber) VALUES
(1, 1, 'Sedan', 'KA01AB1234'),
(2, 2, 'SUV', 'KA01CD5678'),
(3, 3, 'Sedan', 'KA01EF9012'),
(4, 4, 'SUV', 'KA01GH3456');

-- select * from Cabs;

-- 4. BOOKINGS TABLE
CREATE TABLE Bookings (
    BookingID INT PRIMARY KEY,
    CustomerID INT,
    CabID INT,
    BookingTime DATETIME,
    TripStartTime DATETIME,
    TripEndTime DATETIME,
    PickupLocation VARCHAR(100),
    DropoffLocation VARCHAR(100),
    Status VARCHAR(20),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (CabID) REFERENCES Cabs(CabID)
);

INSERT INTO Bookings (BookingID, CustomerID, CabID, BookingTime, TripStartTime, TripEndTime, PickupLocation, DropoffLocation, Status) VALUES
(101, 1, 1, '2025-05-01 08:00:00', '2025-05-01 08:10:00', '2025-05-01 08:40:00', 'Downtown', 'Airport', 'Completed'),
(102, 2, 2, '2025-05-01 09:00:00', NULL, NULL, 'Station', 'Mall', 'Cancelled'),
(103, 1, 3, '2025-05-02 10:00:00', '2025-05-02 10:15:00', '2025-05-02 10:50:00', 'Downtown', 'Hospital', 'Completed'),
(104, 3, 4, '2025-05-03 11:30:00', '2025-05-03 11:45:00', '2025-05-03 12:30:00', 'Mall', 'University', 'Completed'),
(105, 4, 1, '2025-05-04 14:00:00', NULL, NULL, 'Airport', 'Downtown', 'Cancelled');

-- select * from Bookings;

-- 5. TRIP DETAILS TABLE
CREATE TABLE TripDetails (
    TripID INT PRIMARY KEY,
    BookingID INT,
    Distance FLOAT,
    Fare DECIMAL(10,2),
    DriverRating FLOAT,
    FOREIGN KEY (BookingID) REFERENCES Bookings(BookingID)
);

INSERT INTO TripDetails (TripID, BookingID, Distance, Fare, DriverRating) VALUES
(1001, 101, 12.5, 250.00, 5.0),
(1002, 103, 10.0, 200.00, 4.0),
(1003, 104, 15.0, 300.00, 3.5);

select * from TripDetails;

-- 6. FEEDBACK TABLE
CREATE TABLE Feedback (
    FeedbackID INT PRIMARY KEY,
    BookingID INT,
    CustomerFeedback TEXT,
    ReasonForCancellation VARCHAR(100),
    FOREIGN KEY (BookingID) REFERENCES Bookings(BookingID)
);

INSERT INTO Feedback (FeedbackID, BookingID, CustomerFeedback, ReasonForCancellation) VALUES
(501, 102, 'Cab was late, had to cancel.', 'Driver Delay'),
(502, 105, 'Change of plans.', 'Customer Personal Reason');

-- select * from Feedback;

-- ===============================================
-- ANALYTICAL SQL QUERIES (BASED ON CASE STUDY)
-- ===============================================

-- 1. Customers with most completed bookings
SELECT c.Name, COUNT(b.BookingID) AS Completed_Bookings
FROM Customers c
JOIN Bookings b ON c.CustomerID = b.CustomerID
WHERE b.Status = 'Completed'
GROUP BY c.CustomerID
ORDER BY Completed_Bookings DESC;

-- 2. Customers who cancelled more than 30% of bookings
SELECT c.Name,
       COUNT(CASE WHEN b.Status = 'Cancelled' THEN 1 END) AS Cancelled,
       COUNT(*) AS Total_Bookings,
       ROUND(COUNT(CASE WHEN b.Status = 'Cancelled' THEN 1 END)/COUNT(*)*100,2) AS Cancel_Percentage
FROM Customers c
JOIN Bookings b ON c.CustomerID = b.CustomerID
GROUP BY c.CustomerID
HAVING Cancel_Percentage > 30;

-- 3. Busiest day of the week for bookings
SELECT DAYNAME(BookingTime) AS Day_Of_Week, COUNT(*) AS Total_Bookings
FROM Bookings
GROUP BY Day_Of_Week
ORDER BY Total_Bookings DESC;

-- 4. Drivers with average rating below 3.0
SELECT d.Name, ROUND(AVG(t.DriverRating),2) AS Avg_Rating
FROM Drivers d
JOIN Cabs c ON d.DriverID = c.DriverID
JOIN Bookings b ON c.CabID = b.CabID
JOIN TripDetails t ON b.BookingID = t.BookingID
GROUP BY d.DriverID
HAVING Avg_Rating < 3.0;

-- 5. Top 5 drivers by total distance
SELECT d.Name, SUM(t.Distance) AS Total_Distance
FROM Drivers d
JOIN Cabs c ON d.DriverID = c.DriverID
JOIN Bookings b ON c.CabID = b.CabID
JOIN TripDetails t ON b.BookingID = t.BookingID
GROUP BY d.DriverID
ORDER BY Total_Distance DESC
LIMIT 5;

-- 6. Total revenue generated in last 6 months
SELECT ROUND(SUM(Fare), 2) AS Total_Revenue
FROM TripDetails
JOIN Bookings ON TripDetails.BookingID = Bookings.BookingID
WHERE Bookings.Status = 'Completed'
AND TripEndTime >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH);

-- 7. Top 3 most frequent routes
SELECT PickupLocation, DropoffLocation, COUNT(*) AS Trip_Count
FROM Bookings
WHERE Status = 'Completed'
GROUP BY PickupLocation, DropoffLocation
ORDER BY Trip_Count DESC
LIMIT 3;

-- 8. Correlation: driver rating vs total earnings
SELECT d.Name, ROUND(AVG(t.DriverRating),2) AS Avg_Rating,
       ROUND(SUM(t.Fare),2) AS Total_Earnings,
       COUNT(t.TripID) AS Trips_Completed
FROM Drivers d
JOIN Cabs c ON d.DriverID = c.DriverID
JOIN Bookings b ON c.CabID = b.CabID
JOIN TripDetails t ON b.BookingID = t.BookingID
GROUP BY d.DriverID
ORDER BY Avg_Rating DESC;

-- 9. Average waiting time by pickup location
SELECT PickupLocation, ROUND(AVG(TIMESTAMPDIFF(MINUTE, BookingTime, TripStartTime)),2) AS Avg_Waiting_Minutes
FROM Bookings
WHERE TripStartTime IS NOT NULL
GROUP BY PickupLocation
ORDER BY Avg_Waiting_Minutes DESC;

-- 10. Common reasons for cancellation
SELECT ReasonForCancellation, COUNT(*) AS Occurrences
FROM Feedback
GROUP BY ReasonForCancellation
ORDER BY Occurrences DESC;

-- 11. Revenue contribution by trip distance type
SELECT CASE WHEN Distance < 10 THEN 'Short Trip' ELSE 'Long Trip' END AS Trip_Type,
       ROUND(SUM(Fare),2) AS Total_Revenue
FROM TripDetails
GROUP BY Trip_Type;

-- 12. Compare revenue by cab type
SELECT CabType, ROUND(SUM(t.Fare),2) AS Total_Revenue, COUNT(t.TripID) AS Trips
FROM Cabs c
JOIN Bookings b ON c.CabID = b.CabID
JOIN TripDetails t ON b.BookingID = t.BookingID
GROUP BY CabType;

-- 13. Inactive customers (no bookings in 3 months)
SELECT c.Name, MAX(b.BookingTime) AS Last_Booking
FROM Customers c
LEFT JOIN Bookings b ON c.CustomerID = b.CustomerID
GROUP BY c.CustomerID
HAVING Last_Booking < DATE_SUB(CURDATE(), INTERVAL 3 MONTH);

-- 14. Weekend vs weekday bookings
SELECT CASE WHEN DAYOFWEEK(BookingTime) IN (1,7) THEN 'Weekend' ELSE 'Weekday' END AS Day_Type,
       COUNT(*) AS Total_Bookings
FROM Bookings
GROUP BY Day_Type;


select * from customers;
select * from drivers;
select * from cabs;
select * from Bookings;
select * from tripdetails;
select * from feddback;
