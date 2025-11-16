"""Main application entry point"""
import sys
from PyQt5.QtWidgets import QApplication
from PyQt5.QtCore import QTimer

from clipit.models.database import init_db, get_session
from clipit.services.clipboard_monitor import ClipboardMonitor
from clipit.services.ai_service import AIService
from clipit.services.hotkey_manager import HotkeyManager
from clipit.services.text_capture import TextCaptureService
from clipit.services.ocr_service import OCRService
from clipit.ui.main_window import MainWindow
from clipit.ui.floating_clippy import FloatingClippyWidget
from clipit.ui.suggestions import SuggestionsOverlay

class ClipitApp:
    """Main Clipit application"""
    
    def __init__(self):
        # Initialize Qt application
        self.app = QApplication(sys.argv)
        self.app.setApplicationName("Clipit")
        self.app.setOrganizationName("Clipit")
        
        # Initialize database
        print("🚀 Initializing Clipit...")
        init_db()
        
        # Initialize AI service (this may take a while)
        print("🤖 Loading AI model...")
        self.ai_service = AIService()
        
        # Initialize services
        self.clipboard_monitor = ClipboardMonitor(ai_service=self.ai_service)
        self.hotkey_manager = HotkeyManager()
        self.text_capture = TextCaptureService()
        self.ocr_service = OCRService()
        
        # Initialize UI components
        self.main_window = MainWindow(self.clipboard_monitor, self.ai_service)
        self.floating_clippy = FloatingClippyWidget()
        self.suggestions_overlay = SuggestionsOverlay()
        
        # Connect signals
        self._connect_signals()
        
        # Start services
        self._start_services()
        
        print("✅ Clipit initialized successfully!")
        print("\n📋 Usage:")
        print("   Alt+X: Ask a question about clipboard history")
        print("   Alt+V: Extract text from screen (OCR)")
        print("   Alt+S: Show clipboard suggestions")
        print("   ESC: Dismiss Clippy")
    
    def _connect_signals(self):
        """Connect signals between components"""
        # Suggestions overlay signals
        self.suggestions_overlay.item_selected.connect(self._on_suggestion_selected)
        self.suggestions_overlay.dismissed.connect(lambda: print("📋 Suggestions dismissed"))
    
    def _start_services(self):
        """Start background services"""
        # Start clipboard monitoring
        self.clipboard_monitor.start_monitoring()
        
        # Start hotkey listener
        self.hotkey_manager.start_listening(
            on_text_capture=self._on_text_capture_hotkey,
            on_vision=self._on_vision_hotkey,
            on_suggestions=self._on_suggestions_hotkey
        )
        
        # Refresh UI after short delay
        QTimer.singleShot(1000, self.main_window.refresh_history)
    
    def _on_text_capture_hotkey(self):
        """Handle Alt+X hotkey for text capture"""
        print("\n⌨️ Text capture hotkey triggered!")
        
        if self.text_capture.is_capturing:
            # Already capturing - stop and process
            print("   Stopping text capture...")
            self.text_capture.stop_capturing()
            # Don't hide Clippy yet - processCapturedText will handle it
        else:
            # Start capturing
            print("   Starting text capture...")
            self.floating_clippy.show_clippy("Clippy is listening...", is_loading=False)
            
            self.text_capture.start_capturing(self._process_captured_text)
    
    def _process_captured_text(self, captured_text):
        """Process captured text and generate AI answer"""
        print(f"\n🎯 Processing captured text: '{captured_text}'")
        
        # Show loading state
        self.floating_clippy.update_message("Clippy is thinking...", is_loading=True)
        
        # Get recent clipboard items for context
        items = self.clipboard_monitor.get_recent_items(limit=10)
        clipboard_context = [(item.content, item.tags if item.tags else []) for item in items]
        
        print(f"   Clipboard context: {len(clipboard_context)} items")
        
        # Generate answer using AI
        answer, image_index = self.ai_service.generate_answer(
            question=captured_text,
            clipboard_context=clipboard_context,
            app_name=self.clipboard_monitor.current_app_name
        )
        
        if answer and answer.strip():
            print(f"   ✅ Generated answer: {answer[:100]}...")
            
            # Replace captured text with answer
            self.text_capture.replace_text_with_answer(answer)
            
            # Show success message
            self.floating_clippy.update_message("Answer ready! 🎉", is_loading=False)
        else:
            print("   ℹ️ No relevant answer generated")
            self.floating_clippy.update_message("No relevant answer found 📋", is_loading=False)
    
    def _on_vision_hotkey(self):
        """Handle Alt+V hotkey for OCR"""
        print("\n👁️ Vision/OCR hotkey triggered!")
        
        # Show loading
        self.floating_clippy.show_clippy("Extracting text from screen...", is_loading=True)
        
        # Parse screen with OCR
        text = self.ocr_service.parse_screen()
        
        if text:
            print(f"   ✅ Extracted {len(text)} characters")
            
            # Save to clipboard history
            from clipit.models.item import Item
            session = get_session()
            item = Item.create_text_item(text, "Screen OCR")
            item.content_type = "vision-parsed"
            session.add(item)
            session.commit()
            
            # Show success
            self.floating_clippy.update_message(f"Extracted {len(text)} characters! ✨", is_loading=False)
            
            # Refresh history
            QTimer.singleShot(500, self.main_window.refresh_history)
        else:
            print("   ❌ OCR failed")
            self.floating_clippy.update_message("OCR failed 😞", is_loading=False)
    
    def _on_suggestions_hotkey(self):
        """Handle Alt+S hotkey for suggestions"""
        print("\n💡 Suggestions hotkey triggered!")
        
        # Get recent items
        items = self.clipboard_monitor.get_recent_items(limit=5)
        
        if items:
            # Show suggestions overlay
            self.suggestions_overlay.show_suggestions(items, "Recent clipboard items")
        else:
            print("   ⚠️ No clipboard items available")
            self.floating_clippy.show_clippy("No clipboard history yet 📋", is_loading=False)
    
    def _on_suggestion_selected(self, item):
        """Handle suggestion selection"""
        print(f"📋 Suggestion selected: {item.content[:50]}...")
        
        # Copy to clipboard
        import win32clipboard
        try:
            win32clipboard.OpenClipboard()
            win32clipboard.EmptyClipboard()
            win32clipboard.SetClipboardText(item.content)
            win32clipboard.CloseClipboard()
            
            # Show success
            self.floating_clippy.show_clippy("Copied to clipboard! ✨", is_loading=False)
        except Exception as e:
            print(f"❌ Failed to copy: {e}")
    
    def run(self):
        """Run the application"""
        # Show main window
        self.main_window.show()
        
        # Run Qt event loop
        return self.app.exec_()
    
    def cleanup(self):
        """Cleanup on exit"""
        print("\n🛑 Shutting down Clipit...")
        
        # Stop services
        self.clipboard_monitor.stop_monitoring()
        self.hotkey_manager.stop_listening()
        
        print("✅ Cleanup complete")

def main():
    """Main entry point"""
    try:
        app = ClipitApp()
        exit_code = app.run()
        app.cleanup()
        sys.exit(exit_code)
    except KeyboardInterrupt:
        print("\n\n🛑 Interrupted by user")
        sys.exit(0)
    except Exception as e:
        print(f"\n❌ Fatal error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()

