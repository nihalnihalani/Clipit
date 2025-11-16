"""Clipboard item model"""
from datetime import datetime
from sqlalchemy import Column, Integer, String, Text, DateTime, JSON
from clipit.models.database import Base

class Item(Base):
    """Clipboard item stored in database"""
    __tablename__ = 'items'
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    timestamp = Column(DateTime, default=datetime.utcnow, nullable=False, index=True)
    content = Column(Text, nullable=False)
    app_name = Column(String(255), nullable=True, index=True)
    content_type = Column(String(50), default='text', nullable=False)  # 'text', 'image', 'vision-parsed'
    usage_count = Column(Integer, default=0, nullable=False)
    vector_id = Column(String(36), nullable=True, index=True)  # UUID for embeddings
    tags = Column(JSON, default=list, nullable=False)  # List of semantic tags
    image_path = Column(String(255), nullable=True)  # Relative path to saved image
    
    def __repr__(self):
        content_preview = self.content[:50] + '...' if len(self.content) > 50 else self.content
        return f"<Item(id={self.id}, type={self.content_type}, content='{content_preview}')>"
    
    def to_dict(self):
        """Convert item to dictionary"""
        return {
            'id': self.id,
            'timestamp': self.timestamp.isoformat() if self.timestamp else None,
            'content': self.content,
            'app_name': self.app_name,
            'content_type': self.content_type,
            'usage_count': self.usage_count,
            'vector_id': self.vector_id,
            'tags': self.tags if self.tags else [],
            'image_path': self.image_path
        }
    
    @classmethod
    def create_text_item(cls, content, app_name=None):
        """Factory method to create a text item"""
        return cls(
            content=content,
            app_name=app_name,
            content_type='text',
            timestamp=datetime.now()
        )
    
    @classmethod
    def create_image_item(cls, description, image_path, app_name=None):
        """Factory method to create an image item"""
        return cls(
            content=description,
            app_name=app_name,
            content_type='image',
            image_path=image_path,
            timestamp=datetime.now()
        )

