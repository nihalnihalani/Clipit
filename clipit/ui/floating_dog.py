"""Floating dog widget for Windows"""
from PyQt5.QtWidgets import QWidget, QLabel, QVBoxLayout
from PyQt5.QtCore import Qt, QTimer, QPoint
from PyQt5.QtGui import QMovie, QFont

class FloatingDogWidget(QWidget):
    """Floating dog animation widget"""
    
    def __init__(self):
        super().__init__()
        self.is_visible = False
        self.message = "Clipit is ready!"
        self.is_loading = False
        
        self._init_ui()
        self._setup_escape_handler()
    
    def _init_ui(self):
        """Initialize the UI"""
        # Set window flags for frameless, always on top, transparent
        self.setWindowFlags(
            Qt.FramelessWindowHint |
            Qt.WindowStaysOnTopHint |
            Qt.Tool  # Don't show in taskbar
        )
        
        # Make background transparent
        self.setAttribute(Qt.WA_TranslucentBackground)
        
        # Set size
        self.setFixedSize(200, 200)
        
        # Create layout
        layout = QVBoxLayout()
        layout.setContentsMargins(10, 10, 10, 10)
        
        # Create message label
        self.message_label = QLabel(self.message)
        self.message_label.setAlignment(Qt.AlignCenter)
        self.message_label.setWordWrap(True)
        self.message_label.setFont(QFont("Arial", 10))
        self.message_label.setStyleSheet("""
            QLabel {
                background-color: rgba(255, 255, 255, 220);
                border-radius: 10px;
                padding: 10px;
                color: #333;
            }
        """)
        
        # Create dog animation placeholder
        self.dog_label = QLabel("🐕")
        self.dog_label.setAlignment(Qt.AlignCenter)
        self.dog_label.setFont(QFont("Arial", 48))
        self.dog_label.setStyleSheet("""
            QLabel {
                background-color: rgba(255, 255, 255, 220);
                border-radius: 50px;
                padding: 20px;
            }
        """)
        
        # Add to layout
        layout.addWidget(self.dog_label)
        layout.addWidget(self.message_label)
        layout.addStretch()
        
        self.setLayout(layout)
        
        # Animation timer for loading
        self.anim_timer = QTimer()
        self.anim_timer.timeout.connect(self._animate_loading)
        self.anim_frame = 0
    
    def _setup_escape_handler(self):
        """Setup ESC key handler"""
        # Will be handled at application level
        pass
    
    def show_dog(self, message="Clipit is ready!", is_loading=False):
        """Show the dog with a message
        
        Args:
            message: Message to display
            is_loading: Whether to show loading animation
        """
        print(f"🐕 Showing dog: {message}")
        
        self.message = message
        self.is_loading = is_loading
        self.message_label.setText(message)
        
        # Position in top-right corner
        self._position_top_right()
        
        # Show window
        self.show()
        self.raise_()
        self.activateWindow()
        self.is_visible = True
        
        # Start loading animation if needed
        if is_loading:
            self.anim_timer.start(200)  # Update every 200ms
        else:
            self.anim_timer.stop()
            self.dog_label.setText("🐕")
    
    def hide_dog(self):
        """Hide the dog"""
        print("🐕 Hiding dog")
        self.hide()
        self.is_visible = False
        self.anim_timer.stop()
    
    def update_message(self, message, is_loading=False):
        """Update message and loading state
        
        Args:
            message: New message
            is_loading: Whether to show loading animation
        """
        self.message = message
        self.is_loading = is_loading
        self.message_label.setText(message)
        
        if is_loading and not self.anim_timer.isActive():
            self.anim_timer.start(200)
        elif not is_loading:
            self.anim_timer.stop()
            self.dog_label.setText("🐕")
            
            # Auto-hide after 2 seconds when done
            QTimer.singleShot(2000, self.hide_dog)
    
    def _position_top_right(self):
        """Position dog in top-right corner of screen"""
        from PyQt5.QtWidgets import QApplication
        screen = QApplication.primaryScreen().geometry()
        
        # Position with some padding from edges
        x = screen.width() - self.width() - 20
        y = 20
        
        self.move(x, y)
    
    def _animate_loading(self):
        """Animate loading state"""
        if not self.is_loading:
            return
        
        # Simple animation using dog emoji rotation
        dogs = ["🐕", "🐶", "🐕‍🦺", "🐩"]
        self.dog_label.setText(dogs[self.anim_frame % len(dogs)])
        self.anim_frame += 1
    
    def keyPressEvent(self, event):
        """Handle key press events"""
        if event.key() == Qt.Key_Escape:
            print("🐕 ESC pressed - hiding dog")
            self.hide_dog()
        else:
            super().keyPressEvent(event)

