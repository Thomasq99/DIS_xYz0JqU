SELECT c.CourseName, creg.Grade FROM StudentRegistrationsToDegrees as sreg, CourseRegistrations as creg, CourseOffers as coffer, Courses as c where sreg.StudentId = %1% and sreg.StudentRegistrationId = creg.StudentRegistrationId and creg.Grade >= 5 and creg.CourseOfferId = coffer.CourseOfferId AND coffer.CourseId = c.CourseId AND sreg.DegreeId = %2% ORDER BY coffer.Year, coffer.Quartile, coffer.CourseOfferId;
WITH ExcellentStudentRegistrations AS (SELECT StudentRegistrationId FROM DegreeProgress WHERE GPA > %1% AND AcqECTS >= TotalECTS EXCEPT (SELECT StudentRegistrationId FROM CourseRegistrations WHERE Grade < 5)) SELECT DISTINCT StudentId FROM ExcellentStudentRegistrations ESR, DegreeProgress DP WHERE ESR.StudentRegistrationId = DP.StudentRegistrationId ORDER BY StudentId;
with all_active_s AS( select SRTD.studentid, SRTD.degreeid from StudentRegistrationsToDegrees SRTD except select dp.studentid, dp.degreeid from degreeprogress dp where dp.acqects >= dp.totalects) SELECT a.degreeid, (count(DISTINCT S.StudentId) FILTER(WHERE Gender='F')/CAST(count(DISTINCT S.StudentId) AS DECIMAL)) AS percentage FROM Students S, all_active_s a WHERE S.StudentId = a.studentid GROUP BY a.degreeid ORDER BY a.degreeid;
SELECT (count(DISTINCT S.StudentId) FILTER(WHERE Gender='F')/CAST(count(DISTINCT S.StudentId) AS DECIMAL)) AS percentage  FROM Degrees D, StudentRegistrationsToDegrees SRTD, Students S WHERE Dept = %1% AND D.DegreeId = SRTD.DegreeId AND S.StudentId = SRTD.StudentId;
SELECT CourseId, CAST(count(StudentRegistrationId) FILTER(WHERE grade >= %1%) AS DECIMAL)/CAST(count(StudentRegistrationId) AS DECIMAL) AS percentagePassing FROM CourseRegistrations cr, CourseOffers co WHERE (grade is not null) and cr.CourseOfferId = co.CourseOfferId GROUP BY CourseId ORDER BY CourseId;
WITH BestGrades AS (SELECT DISTINCT ON(CR.CourseOfferId) CR.CourseOfferId, Grade FROM CourseRegistrations CR, CourseOffers CO WHERE CO.CourseOfferId = CR.CourseOfferId AND CO.Quartile = 1 AND CO.Year=2018 ORDER BY CR.CourseOfferId, CR.Grade DESC NULLS LAST), Stud AS (SELECT CR.CourseOfferId, StudentregistrationId, CR.Grade FROM CourseRegistrations CR, CourseOffers CO WHERE CO.CourseOfferId = CR.CourseOfferId AND CO.Quartile = 1 AND CO.Year=2018) SELECT StudentId, count(StudentId) as numberOfCoursesWhereExcellent FROM Stud S, BestGrades BG, StudentRegistrationsToDegrees SRTD WHERE BG.CourseOfferId = S.CourseOfferId AND BG.Grade = S.Grade AND S.StudentRegistrationId = SRTD.StudentRegistrationId GROUP BY StudentId HAVING count(StudentId) >= %1%;
SELECT DP.DegreeId, S.BirthyearStudent AS Birthyear, S.Gender, avg(gpa) AS avgGrade FROM DegreeProgress DP, Students S WHERE AcqECTS < TotalECTS AND S.StudentId = DP.StudentId GROUP BY CUBE(DP.DegreeId, S.BirthyearStudent, S.Gender) ORDER BY (DP.DegreeId, S.BirthYearStudent, CASE WHEN s.gender = 'F' THEN 1 ELSE 2 END);
WITH required_SA AS (SELECT CourseOfferId, CAST(count(DISTINCT StudentRegistrationId) AS DECIMAL)/50 AS required_SAs FROM CourseRegistrations GROUP BY CourseOfferId), Actual_SA AS (SELECT CourseOfferId, count(DISTINCT StudentRegistrationId) AS actual_SAs FROM StudentAssistants GROUP BY CourseOfferId) SELECT CourseName, Year, Quartile FROM (SELECT CO.CourseOfferId, C.coursename, CO.year, CO.quartile FROM Courses C, CourseOffers CO WHERE C.CourseId = CO.CourseId EXCEPT SELECT CO.CourseOfferId, C.courseName, CO.year, CO.quartile FROM required_SA AS RSA, Actual_SA AS ASA, CourseOffers AS CO, Courses AS C WHERE CO.CourseOfferId = RSA.CourseOfferId AND RSA.CourseOfferId = ASA.CourseOfferId AND ASA.actual_SAs >= RSA.required_SAs AND C.CourseId = CO.CourseId ORDER BY CourseOfferId) AS res_q;