"""Clipboard monitoring service for Windows"""
import time
import threading
import win32clipboard
import win32gui
import win32process
import psutil
from datetime import datetime
from PIL import Image
from io import BytesIO
from pathlib import Path
from clipit.models.database import get_session, get_images_directory
from clipit.models.item import Item

class ClipboardMonitor:
    """Monitor Windows clipboard for changes and save to database"""
    
    def __init__(self, ai_service=None):
        self.is_monitoring = False
        self.monitoring_thread = None
        self.last_clipboard_data = None
        self.current_app_name = "Unknown"
        self.current_window_title = ""
        self.ai_service = ai_service
        self.session = None
        
    def start_monitoring(self):
        """Start monitoring clipboard in background thread"""
        if self.is_monitoring:
            print("⚠️ Clipboard monitoring already running")
            return
        
        self.is_monitoring = True
        self.session = get_session()
        print("✅ Clipboard monitoring started")
        
        # Start monitoring thread
        self.monitoring_thread = threading.Thread(target=self._monitor_loop, daemon=True)
        self.monitoring_thread.start()
    
    def stop_monitoring(self):
        """Stop monitoring clipboard"""
        self.is_monitoring = False
        if self.monitoring_thread:
            self.monitoring_thread.join(timeout=2)
        print("🛑 Clipboard monitoring stopped")
    
    def _monitor_loop(self):
        """Main monitoring loop (runs in background thread)"""
        while self.is_monitoring:
            try:
                # Update current app info
                self._update_current_app()
                
                # Check clipboard for changes
                self._check_clipboard()
                
                # Sleep for 500ms (same as macOS version)
                time.sleep(0.5)
            except Exception as e:
                print(f"❌ Error in clipboard monitor: {e}")
                time.sleep(1)  # Longer sleep on error
    
    def _update_current_app(self):
        """Update information about the currently active window"""
        try:
            # Get foreground window
            hwnd = win32gui.GetForegroundWindow()
            if not hwnd:
                self.current_app_name = "Unknown"
                self.current_window_title = ""
                return
            
            # Get window title
            self.current_window_title = win32gui.GetWindowText(hwnd)
            
            # Get process name
            _, pid = win32process.GetWindowThreadProcessId(hwnd)
            try:
                process = psutil.Process(pid)
                self.current_app_name = process.name()
            except:
                self.current_app_name = "Unknown"
                
        except Exception as e:
            print(f"⚠️ Failed to get current app: {e}")
            self.current_app_name = "Unknown"
            self.current_window_title = ""
    
    def _check_clipboard(self):
        """Check clipboard for changes and save new items"""
        try:
            # Try to open clipboard
            win32clipboard.OpenClipboard()
            
            try:
                # Check for image first
                if win32clipboard.IsClipboardFormatAvailable(win32clipboard.CF_DIB):
                    image_data = win32clipboard.GetClipboardData(win32clipboard.CF_DIB)
                    if image_data != self.last_clipboard_data:
                        self.last_clipboard_data = image_data
                        self._save_image_item(image_data)
                
                # Check for text
                elif win32clipboard.IsClipboardFormatAvailable(win32clipboard.CF_UNICODETEXT):
                    text = win32clipboard.GetClipboardData(win32clipboard.CF_UNICODETEXT)
                    if text and text != self.last_clipboard_data:
                        self.last_clipboard_data = text
                        self._save_text_item(text)
            finally:
                win32clipboard.CloseClipboard()
                
        except Exception as e:
            # Clipboard might be locked by another process
            pass
    
    def _save_text_item(self, text):
        """Save text clipboard item to database"""
        try:
            # Filter out empty or very short content
            trimmed = text.strip()
            if len(trimmed) < 3:
                return
            
            # Check for duplicates
            recent_items = self.session.query(Item).order_by(Item.timestamp.desc()).limit(5).all()
            for item in recent_items:
                if item.content == text:
                    print(f"⚠️ Skipping duplicate content")
                    return
            
            print(f"💾 Saving clipboard text: {trimmed[:50]}...")
            
            # Create new item
            item = Item.create_text_item(text, self.current_app_name)
            self.session.add(item)
            self.session.commit()
            
            print(f"   ✅ Saved item ID: {item.id}")
            
            # Generate tags asynchronously if AI service available
            if self.ai_service:
                threading.Thread(
                    target=self._generate_tags_async,
                    args=(item.id, text, self.current_app_name),
                    daemon=True
                ).start()
                
        except Exception as e:
            print(f"   ❌ Failed to save text item: {e}")
            self.session.rollback()
    
    def _save_image_item(self, image_data):
        """Save image clipboard item to database"""
        try:
            print(f"💾 Saving clipboard image...")
            
            # Convert DIB to PIL Image
            # Note: CF_DIB format requires special handling on Windows
            # For simplicity, we'll save as PNG
            
            # Save image to disk
            images_dir = get_images_directory()
            filename = f"{datetime.now().strftime('%Y%m%d_%H%M%S')}.png"
            image_path = images_dir / filename
            
            # For now, create a placeholder (actual image conversion requires more work)
            # In production, you'd properly convert CF_DIB to PIL Image
            description = "[Image from clipboard]"
            
            print(f"   ✅ Image would be saved to: {image_path}")
            
            # Create database item
            item = Item.create_image_item(description, filename, self.current_app_name)
            self.session.add(item)
            self.session.commit()
            
            print(f"   ✅ Saved image item ID: {item.id}")
            
        except Exception as e:
            print(f"   ❌ Failed to save image item: {e}")
            self.session.rollback()
    
    def _generate_tags_async(self, item_id, content, app_name):
        """Generate tags for an item (runs in background thread)"""
        try:
            if not self.ai_service:
                return
            
            print(f"🏷️  Generating tags for item {item_id}...")
            tags = self.ai_service.generate_tags(content, app_name, None)
            
            if tags:
                # Update item with tags
                item = self.session.query(Item).get(item_id)
                if item:
                    item.tags = tags
                    self.session.commit()
                    print(f"   ✅ Tags saved: {tags}")
        except Exception as e:
            print(f"   ❌ Failed to generate tags: {e}")
    
    def get_recent_items(self, limit=10):
        """Get recent clipboard items"""
        try:
            return self.session.query(Item).order_by(Item.timestamp.desc()).limit(limit).all()
        except Exception as e:
            print(f"❌ Failed to get recent items: {e}")
            return []

