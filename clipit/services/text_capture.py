"""Text capture service for Windows"""
import time
import pyautogui
from pynput import keyboard
from pynput.keyboard import Key, Controller

class TextCaptureService:
    """Capture user text input and replace with AI answers"""
    
    def __init__(self):
        self.is_capturing = False
        self.captured_text = ""
        self.listener = None
        self.on_capture_complete = None
        self.keyboard_controller = Controller()
        
        # Track modifier keys
        self.alt_pressed = False
        self.ctrl_pressed = False
        self.shift_pressed = False
    
    def start_capturing(self, on_complete):
        """Start capturing text input
        
        Args:
            on_complete: Callback function called with captured text when done
        """
        if self.is_capturing:
            print("⚠️ Already capturing text")
            return
        
        print("🎯 Starting text capture...")
        self.is_capturing = True
        self.captured_text = ""
        self.on_capture_complete = on_complete
        
        # Start keyboard listener
        self.listener = keyboard.Listener(
            on_press=self._on_press,
            on_release=self._on_release
        )
        self.listener.start()
    
    def stop_capturing(self):
        """Stop capturing and return captured text"""
        if not self.is_capturing:
            return
        
        print(f"🛑 Stopping text capture")
        print(f"   Captured: '{self.captured_text}'")
        
        self.is_capturing = False
        
        # Stop listener
        if self.listener:
            self.listener.stop()
            self.listener = None
        
        # Call completion callback
        if self.on_capture_complete and self.captured_text:
            self.on_capture_complete(self.captured_text)
        
        # Reset state
        self.captured_text = ""
        self.on_capture_complete = None
    
    def replace_text_with_answer(self, answer):
        """Replace captured text with AI answer
        
        Args:
            answer: The answer text to insert
        """
        print(f"🔄 Replacing captured text with answer...")
        print(f"   Captured length: {len(self.captured_text)} chars")
        print(f"   Answer: {answer[:100]}...")
        
        try:
            # Small delay to ensure previous operations complete
            time.sleep(0.1)
            
            # Select all the text we just typed (Ctrl+A)
            # This is safer than counting backspaces
            self.keyboard_controller.press(Key.ctrl)
            self.keyboard_controller.press('a')
            self.keyboard_controller.release('a')
            self.keyboard_controller.release(Key.ctrl)
            
            time.sleep(0.05)
            
            # Delete selected text
            self.keyboard_controller.press(Key.backspace)
            self.keyboard_controller.release(Key.backspace)
            
            time.sleep(0.1)
            
            # Type the answer
            # Use pyautogui for more reliable typing
            pyautogui.typewrite(answer, interval=0.01)
            
            print("   ✅ Text replaced successfully")
            
        except Exception as e:
            print(f"   ❌ Error replacing text: {e}")
    
    def _on_press(self, key):
        """Handle key press during capture"""
        try:
            # Track modifier keys
            if key == Key.alt_l or key == Key.alt_r or key == Key.alt:
                self.alt_pressed = True
                return
            if key == Key.ctrl_l or key == Key.ctrl_r or key == Key.ctrl:
                self.ctrl_pressed = True
                return
            if key == Key.shift or key == Key.shift_r:
                self.shift_pressed = True
                return
            
            # Check for Alt+X to stop capturing
            if self.alt_pressed and hasattr(key, 'char') and key.char == 'x':
                print("🎯 Alt+X detected - stopping capture")
                self.stop_capturing()
                return
            
            # Ignore other modifier combinations
            if self.ctrl_pressed or self.alt_pressed:
                return
            
            # Handle special keys
            if key == Key.enter:
                self.captured_text += '\n'
                return
            elif key == Key.space:
                self.captured_text += ' '
                return
            elif key == Key.tab:
                self.captured_text += '\t'
                return
            elif key == Key.backspace:
                if self.captured_text:
                    self.captured_text = self.captured_text[:-1]
                return
            elif key == Key.esc:
                # ESC cancels capture
                print("🛑 ESC pressed - canceling capture")
                self.is_capturing = False
                if self.listener:
                    self.listener.stop()
                self.captured_text = ""
                return
            
            # Capture regular characters
            if hasattr(key, 'char') and key.char:
                self.captured_text += key.char
                
        except AttributeError:
            # Special keys without char attribute
            pass
    
    def _on_release(self, key):
        """Handle key release during capture"""
        # Track modifier key releases
        if key == Key.alt_l or key == Key.alt_r or key == Key.alt:
            self.alt_pressed = False
        if key == Key.ctrl_l or key == Key.ctrl_r or key == Key.ctrl:
            self.ctrl_pressed = False
        if key == Key.shift or key == Key.shift_r:
            self.shift_pressed = False

