-- Step 1: Create the table based on your CSV structure
-- Make sure these columns match your CSV file headers
CREATE TABLE IF NOT EXISTS employees (
    -- Add all columns from your CSV here
    employee_id VARCHAR(50),
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    birthdate DATE,
    gender VARCHAR(10),
    race VARCHAR(50),
    department VARCHAR(50),
    job_title VARCHAR(100),
    location VARCHAR(100),
    hire_date DATE,
    termination_date DATE,
    business_unit VARCHAR(100),
    salary DECIMAL(10,2),
    bonus_percent DECIMAL(5,2),
    exit_date DATE,
    exit_reason VARCHAR(200),
    years_of_service DECIMAL(4,2),
    recruitment_source VARCHAR(100)
);

-- Step 2: Create a temporary table for CSV import
CREATE TEMP TABLE temp_employees (
    LIKE employees
);

-- Step 3: Copy data from CSV
-- You'll execute this through the GUI or psql
COPY temp_employees(
    employee_id,
    first_name,
    last_name,
    birthdate,
    gender,
    race,
    department,
    job_title,
    location,
    hire_date,
    termination_date,
    business_unit,
    salary,
    bonus_percent,
    exit_date,
    exit_reason,
    years_of_service,
    recruitment_source
)
FROM 'C:\path\to\your\HRDataset_v14.csv'  -- You'll need to update this path
WITH (FORMAT csv, HEADER true, DELIMITER ',');

-- Step 4: Insert from temp table to main table
INSERT INTO employees 
SELECT * FROM temp_employees;

-- Step 5: Drop temporary table
DROP TABLE temp_employees;

-- Step 6: Create useful views for analysis
CREATE OR REPLACE VIEW department_summary AS
SELECT 
    department,
    COUNT(*) as employee_count,
    ROUND(AVG(salary)::numeric, 2) as avg_salary,
    ROUND(AVG(years_of_service)::numeric, 2) as avg_tenure,
    COUNT(CASE WHEN exit_date IS NOT NULL THEN 1 END) as turnover_count
FROM 
    employees
GROUP BY 
    department;

-- Step 7: Create an audit table for tracking changes
CREATE TABLE IF NOT EXISTS audit_log (
    id SERIAL PRIMARY KEY,
    table_name VARCHAR(50),
    operation VARCHAR(20),
    old_values JSONB,
    new_values JSONB,
    changed_by VARCHAR(50),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Step 8: Create audit trigger function
CREATE OR REPLACE FUNCTION audit_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO audit_log (table_name, operation, new_values, changed_by)
        VALUES (TG_TABLE_NAME, 'INSERT', row_to_json(NEW)::jsonb, current_user);
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO audit_log (table_name, operation, old_values, new_values, changed_by)
        VALUES (TG_TABLE_NAME, 'UPDATE', row_to_json(OLD)::jsonb, row_to_json(NEW)::jsonb, current_user);
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO audit_log (table_name, operation, old_values, changed_by)
        VALUES (TG_TABLE_NAME, 'DELETE', row_to_json(OLD)::jsonb, current_user);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Step 9: Create trigger
CREATE TRIGGER employees_audit
AFTER INSERT OR UPDATE OR DELETE ON employees
    FOR EACH ROW EXECUTE FUNCTION audit_changes();