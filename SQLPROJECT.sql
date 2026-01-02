
create database project;
use project;



-- Table 1: Job Department
CREATE TABLE JobDepartment (
    Job_ID INT PRIMARY KEY,
    jobdept VARCHAR(50),
    name VARCHAR(100),
    description TEXT,
    salaryrange VARCHAR(50)
);
-- Table 2: Salary/Bonus
CREATE TABLE SalaryBonus (
    salary_ID INT PRIMARY KEY,
    Job_ID INT,
    amount DECIMAL(10,2),
    annual DECIMAL(10,2),
    bonus DECIMAL(10,2),
    CONSTRAINT fk_salary_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(Job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
-- Table 3: Employee
CREATE TABLE Employee (
    emp_ID INT PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    gender VARCHAR(10),
    age INT,
    contact_add VARCHAR(100),
    emp_email VARCHAR(100) UNIQUE,
    emp_pass VARCHAR(50),
    Job_ID INT,
    CONSTRAINT fk_employee_job FOREIGN KEY (Job_ID)
            REFERENCES JobDepartment(Job_ID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- Table 4: Qualification
CREATE TABLE Qualification (
    QualID INT PRIMARY KEY,
    Emp_ID INT,
    Position VARCHAR(50),
    Requirements VARCHAR(255),
    Date_In DATE,
    CONSTRAINT fk_qualification_emp FOREIGN KEY (Emp_ID)
        REFERENCES Employee(emp_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Table 5: Leaves
CREATE TABLE Leaves (
    leave_ID INT PRIMARY KEY,
    emp_ID INT,
    date DATE,
    reason TEXT,
    CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Table 6: Payroll
CREATE TABLE Payroll (
    payroll_ID INT PRIMARY KEY,
    emp_ID INT,
    job_ID INT,
    salary_ID INT,
    leave_ID INT,
    date DATE,
    report TEXT,
    total_amount DECIMAL(10,2),
    CONSTRAINT fk_payroll_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_ID) REFERENCES SalaryBonus(salary_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_leave FOREIGN KEY (leave_ID) REFERENCES Leaves(leave_ID)
        ON DELETE SET NULL ON UPDATE CASCADE
);

select * from JobDepartment ;
select * from SalaryBonus;
select * from Employee;
select * from qualification;
select * from Leaves;
select * from Payroll;

-- 1. EMPLOYEE INSIGHTS

--  How many unique employees are currently in the system?
			
            
            
            select 
            distinct count(emp_id) as employee_count
            from employee;
            
            
            
--  Which departments have the highest number of employees?

			select jobdept,count(emp_id) as employee_count from employee e 
			join jobdepartment j 
			on e.job_id = j.job_id
			group by jobdept
			order by employee_count desc;
            
            
--   What is the average salary per department?


			select 
            j.jobdept,avg(s.amount) as avg_dept 
            from salarybonus s 
			join jobdepartment j 
			on s.job_id = j.job_id
			group by j.jobdept;
            
            
            
--  Who are the top 5 highest-paid employees?


			select  
            e.emp_id, e.firstname, e.lastname,
            s.amount, s.annual, s.bonus 
            from employee e 
			join salarybonus s
			on e.job_id = s.job_id
			order by amount desc
			limit 5;
            
            
            
--  What is the total salary expenditure across the company?

		select 
        sum(annual + bonus) as tot_sal_expenditure 
        from salarybonus;


-- 2. JOB ROLE AND DEPARTMENT ANALYSIS

--  How many different job roles exist in each department?

		select 
        jobdept,count(name) 
        from jobdepartment
		group by jobdept; 

--  What is the average salary range per department?

			SELECT 
				j.jobdept,
				MIN(s.amount) AS min_salary,
				MAX(s.amount) AS max_salary,
				ROUND(AVG(s.amount), 2) AS avg_salary
			FROM jobdepartment j
			JOIN salarybonus s 
			ON j.job_id = s.job_id
			GROUP BY j.jobdept;
--  Which job roles offer the highest salary?

			select j.job_id, j.name , s.amount from jobdepartment j
			join salarybonus s
			on j.job_id = s.job_id
			order by s.amount desc
            limit 5;

--  Which departments have the highest total salary allocation?

			select 
            j.jobdept,  sum(s.amount) as total_sal_allocation
            from jobdepartment j
			join salarybonus s
			on j.job_id = s.job_id
			group by j.jobdept
			order by sum(s.amount) desc;

--  3. QUALIFICATION AND SKILLS ANALYSIS
-- -- How many employees have at least one qualification listed?

			SELECT COUNT(DISTINCT emp_id)
			FROM qualification;
            
-- -- Which positions require the most qualifications?



		SELECT Position, COUNT(Requirements) AS total_requirements
			FROM Qualification
			GROUP BY Position
			ORDER BY total_requirements DESC;

-- -- Which employees have the highest number of qualifications?
		select 
			emp_id, requirements as qualification_,
			count(*) over (partition by emp_id) as count_qualification
			from qualification;
        
-- -- 4. LEAVE AND ABSENCE PATTERNS

-- Which year had the most employees taking leaves?
        
		SELECT 
        YEAR(date) AS leave_year,
        COUNT(leave_id) AS total_leaves
		FROM Leaves
		GROUP BY YEAR(date)
		ORDER BY total_leaves DESC
		LIMIT 1;
        
-- What is the average number of leave days taken by its employees per department?

			SELECT j.jobdept, AVG(emp_leave.leave_count) AS avg_leave_days
			FROM JobDepartment j
			JOIN (
			SELECT e.Job_ID, e.emp_ID, COUNT(l.leave_ID) AS leave_count
			FROM Employee e
			LEFT JOIN Leaves l ON e.emp_ID = l.emp_ID
			GROUP BY e.Job_ID, e.emp_ID
			) AS emp_leave
			ON j.Job_ID = emp_leave.Job_ID
			GROUP BY j.jobdept;

-- Which employees have taken the most leaves?
			SELECT emp_id, COUNT(leave_id) AS no_of_leaves
			FROM Leaves
			GROUP BY emp_id
			ORDER BY no_of_leaves DESC;

-- What is the total number of leave days taken company-wide?

			select 
            count(leave_id) 
            from leaves;
            
--  How do leave days correlate with payroll amounts?

			SELECT emp_ID, COUNT(leave_ID) AS leave_days
			FROM Leaves
			GROUP BY emp_ID;

			SELECT 
            e.emp_ID, COUNT(l.leave_ID) AS leave_days,
            AVG(p.total_amount) AS avg_payroll
			FROM Employee e
			LEFT JOIN Leaves l ON e.emp_ID = l.emp_ID
			JOIN Payroll p ON e.emp_ID = p.emp_ID
			GROUP BY e.emp_ID;


-- 5. PAYROLL AND COMPENSATION ANALYSIS

-- -- What is the total monthly payroll processed?

		select 
        report,sum(total_amount) from payroll
        group by report;
			
-- -- What is the average bonus given per department?
		
        select 
        jobdept,avg(bonus) from jobdepartment j
        join salarybonus s
        on j.job_id = s.job_id
        group by jobdept;
        
-- -- Which department receives the highest total bonuses?
			SELECT 
            j.jobdept, SUM(s.bonus) AS total_bonus
			FROM JobDepartment j
			JOIN SalaryBonus s ON j.job_id = s.job_id
			GROUP BY j.jobdept
			ORDER BY total_bonus DESC;
  
-- -- what is the average value of total_amount after considering leave deductions?
			
            SELECT 
            AVG(total_amount) 
            AS avg_total_amount_after_deductions
			FROM Payroll;


        

      
        