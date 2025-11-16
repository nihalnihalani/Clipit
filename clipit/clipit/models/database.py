"""Database setup and session management"""
import os
from pathlib import Path
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, scoped_session

# Base class for all models
Base = declarative_base()

# Database path (Windows AppData)
def get_database_path():
    """Get the database path in Windows AppData"""
    appdata = os.environ.get('APPDATA', '')
    if not appdata:
        # Fallback to local directory
        appdata = os.path.expanduser('~')
    
    clipit_dir = Path(appdata) / 'Clipit'
    clipit_dir.mkdir(parents=True, exist_ok=True)
    
    return clipit_dir / 'clipit.db'

def get_images_directory():
    """Get the images directory in Windows AppData"""
    appdata = os.environ.get('APPDATA', '')
    if not appdata:
        appdata = os.path.expanduser('~')
    
    images_dir = Path(appdata) / 'Clipit' / 'images'
    images_dir.mkdir(parents=True, exist_ok=True)
    
    return images_dir

# Create engine and session
db_path = get_database_path()
engine = create_engine(f'sqlite:///{db_path}', echo=False)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Session = scoped_session(SessionLocal)

def init_db():
    """Initialize the database (create all tables)"""
    Base.metadata.create_all(bind=engine)
    print(f"✅ Database initialized at: {db_path}")

def get_session():
    """Get a database session"""
    return Session()

