"""Global hotkey manager for Windows"""
from pynput import keyboard
from pynput.keyboard import Key, KeyCode

class HotkeyManager:
    """Manage global hotkeys for Clipit"""
    
    def __init__(self):
        self.is_listening = False
        self.listener = None
        self.on_text_capture_trigger = None
        self.on_vision_trigger = None
        self.on_suggestions_trigger = None
        
        # Track Alt key state
        self.alt_pressed = False
    
    def start_listening(self, on_text_capture=None, on_vision=None, on_suggestions=None):
        """Start listening for global hotkeys
        
        Args:
            on_text_capture: Callback for Alt+X (text capture)
            on_vision: Callback for Alt+V (OCR/vision)
            on_suggestions: Callback for Alt+S (suggestions)
        """
        if self.is_listening:
            print("⚠️ Hotkey manager already listening")
            return
        
        self.on_text_capture_trigger = on_text_capture
        self.on_vision_trigger = on_vision
        self.on_suggestions_trigger = on_suggestions
        
        print("⌨️  Starting hotkey listener...")
        print("   Alt+X: Text capture")
        print("   Alt+V: Screen OCR")
        print("   Alt+S: Suggestions")
        
        # Start listener
        self.listener = keyboard.Listener(
            on_press=self._on_press,
            on_release=self._on_release
        )
        self.listener.start()
        self.is_listening = True
        
        print("✅ Hotkey listener started")
    
    def stop_listening(self):
        """Stop listening for hotkeys"""
        if not self.is_listening:
            return
        
        print("🛑 Stopping hotkey listener...")
        
        if self.listener:
            self.listener.stop()
            self.listener = None
        
        self.is_listening = False
        print("✅ Hotkey listener stopped")
    
    def _on_press(self, key):
        """Handle key press events"""
        try:
            # Track Alt key
            if key == Key.alt_l or key == Key.alt_r or key == Key.alt:
                self.alt_pressed = True
                return
            
            # Check for Alt+X (text capture)
            if self.alt_pressed and hasattr(key, 'char') and key.char == 'x':
                print("⌨️  Alt+X detected!")
                if self.on_text_capture_trigger:
                    self.on_text_capture_trigger()
                return
            
            # Check for Alt+V (vision/OCR)
            if self.alt_pressed and hasattr(key, 'char') and key.char == 'v':
                print("⌨️  Alt+V detected!")
                if self.on_vision_trigger:
                    self.on_vision_trigger()
                return
            
            # Check for Alt+S (suggestions)
            if self.alt_pressed and hasattr(key, 'char') and key.char == 's':
                print("⌨️  Alt+S detected!")
                if self.on_suggestions_trigger:
                    self.on_suggestions_trigger()
                return
                
        except AttributeError:
            # Special keys without char attribute
            pass
    
    def _on_release(self, key):
        """Handle key release events"""
        # Track Alt key release
        if key == Key.alt_l or key == Key.alt_r or key == Key.alt:
            self.alt_pressed = False

