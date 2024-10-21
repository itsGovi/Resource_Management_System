# The basic structure of the DB

hr_analytics/
├── data/
│   ├── raw/
│   │   └── HRDataset_v14.csv       # Raw CSV data file
│   └── processed/
│       └── .gitkeep                # Placeholder file for processed data
├── database/
│   ├── init/
│   │   ├── 01_create_tables.sql    # SQL script to create tables
│   │   └── 02_import_data.sql      # SQL script to import data from CSV
│   ├── queries/
│   │   ├── q1_turnover_analysis.sql       # SQL script for turnover analysis
│   │   ├── q2_recruitment_analysis.sql    # SQL script for recruitment analysis
│   │   ├── q3_engagement_analysis.sql     # SQL script for engagement analysis
│   │   ├── q4_team_analysis.sql           # SQL script for team analysis
│   │   └── q5_compensation_analysis.sql   # SQL script for compensation analysis
│   └── views/
│       └── combined_metrics.sql   # SQL script for combined metrics view
├── notebooks/
│   ├── data_validation.ipynb     # Jupyter Notebook for data validation
│   └── insights_compilation.ipynb   # Jupyter Notebook for insights compilation
├── config/
│   ├── database.ini              # Configuration file for database connection
│   └── .env                      # Environment variables for sensitive data
└── requirements.txt              # Python dependencies
