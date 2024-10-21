import pandas as pd
from sqlalchemy import create_engine
import os
from dotenv import load_dotenv
import sys
from pathlib import Path

# Add project root to path
project_root = Path(__file__).parent.parent.parent
sys.path.append(str(project_root))

load_dotenv()

def create_database_connection():
    """Create database connection string"""
    db_params = {
        'host': 'localhost',
        'database': 'hr_analytics',
        'user': os.getenv('DB_USER'),
        'password': os.getenv('DB_PASSWORD'),
        'port': 5432
    }
    
    return f"postgresql://{db_params['user']}:{db_params['password']}@{db_params['host']}:{db_params['port']}/{db_params['database']}"

def create_and_populate_db():
    """Create database tables and import CSV data"""
    try:
        # Create database connection
        engine = create_engine(create_database_connection())
        
        # Read CSV file
        csv_path = project_root / 'data' / 'HRDataset_v14.csv'
        df = pd.read_csv(csv_path)
        
        # Clean column names (remove spaces, special characters)
        df.columns = df.columns.str.lower().str.replace(' ', '_')
        
        # Import to database
        df.to_sql('employees', engine, if_exists='replace', index=False)
        print("✅ Database created and populated successfully!")
        
        return True
    except Exception as e:
        print(f"❌ Error creating database: {str(e)}")
        return False

if __name__ == "__main__":
    create_and_populate_db()