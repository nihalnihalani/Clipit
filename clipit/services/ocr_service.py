"""OCR service for screen text extraction"""
import pytesseract
from PIL import ImageGrab
import time

class OCRService:
    """Extract text from screen using OCR (Tesseract)"""
    
    def __init__(self):
        self.is_processing = False
        self.last_parsed_text = ""
        
        # Try to configure Tesseract path (common Windows location)
        try:
            # Try common installation paths
            tesseract_paths = [
                r'C:\Program Files\Tesseract-OCR\tesseract.exe',
                r'C:\Program Files (x86)\Tesseract-OCR\tesseract.exe',
            ]
            
            for path in tesseract_paths:
                try:
                    pytesseract.pytesseract.tesseract_cmd = path
                    # Test if it works
                    pytesseract.get_tesseract_version()
                    print(f"✅ Tesseract found at: {path}")
                    break
                except:
                    continue
        except Exception as e:
            print(f"⚠️ Could not configure Tesseract: {e}")
            print("   Make sure Tesseract OCR is installed")
    
    def parse_screen(self):
        """Capture screen and extract text using OCR
        
        Returns:
            str: Extracted text from screen
        """
        if self.is_processing:
            print("⚠️ OCR already processing")
            return None
        
        print("📸 Capturing screen for OCR...")
        self.is_processing = True
        
        try:
            start_time = time.time()
            
            # Capture entire screen
            screenshot = ImageGrab.grab()
            print(f"   ✅ Screen captured: {screenshot.size}")
            
            # Extract text using Tesseract
            print("   🔍 Running OCR...")
            text = pytesseract.image_to_string(screenshot)
            
            # Clean up text
            text = text.strip()
            
            elapsed = time.time() - start_time
            print(f"   ✅ OCR complete in {elapsed:.2f}s")
            print(f"   📝 Extracted {len(text)} characters")
            
            self.last_parsed_text = text
            return text
            
        except Exception as e:
            print(f"   ❌ OCR failed: {e}")
            return None
        finally:
            self.is_processing = False
    
    def parse_region(self, bbox):
        """Capture specific screen region and extract text
        
        Args:
            bbox: Tuple of (left, top, right, bottom)
            
        Returns:
            str: Extracted text from region
        """
        if self.is_processing:
            print("⚠️ OCR already processing")
            return None
        
        print(f"📸 Capturing screen region: {bbox}")
        self.is_processing = True
        
        try:
            # Capture specific region
            screenshot = ImageGrab.grab(bbox=bbox)
            
            # Extract text
            text = pytesseract.image_to_string(screenshot)
            text = text.strip()
            
            print(f"   ✅ Extracted {len(text)} characters from region")
            return text
            
        except Exception as e:
            print(f"   ❌ OCR failed: {e}")
            return None
        finally:
            self.is_processing = False
    
    def get_last_parsed_text(self):
        """Get the last parsed text"""
        return self.last_parsed_text

