"""Suggestions overlay widget"""
from PyQt5.QtWidgets import (QWidget, QVBoxLayout, QHBoxLayout, QLabel, 
                             QPushButton, QListWidget, QListWidgetItem)
from PyQt5.QtCore import Qt, pyqtSignal
from PyQt5.QtGui import QFont, QKeySequence

class SuggestionsOverlay(QWidget):
    """Overlay widget showing clipboard suggestions"""
    
    item_selected = pyqtSignal(object)  # Emits selected Item
    dismissed = pyqtSignal()
    
    def __init__(self):
        super().__init__()
        self.suggestions = []
        self.selected_index = 0
        
        self._init_ui()
    
    def _init_ui(self):
        """Initialize the UI"""
        # Set window flags
        self.setWindowFlags(
            Qt.WindowStaysOnTopHint |
            Qt.FramelessWindowHint |
            Qt.Tool
        )
        
        # Set size
        self.setFixedSize(560, 400)
        
        # Create main layout
        layout = QVBoxLayout()
        layout.setContentsMargins(16, 16, 16, 16)
        layout.setSpacing(12)
        
        # Header
        header_layout = QHBoxLayout()
        
        header_label = QLabel("Smart Paste Suggestions")
        header_label.setFont(QFont("Arial", 14, QFont.Bold))
        header_layout.addWidget(header_label)
        
        header_layout.addStretch()
        
        help_label = QLabel("↑/↓ move • Enter paste • ESC cancel")
        help_label.setStyleSheet("color: #666; font-size: 10px;")
        header_layout.addWidget(help_label)
        
        layout.addLayout(header_layout)
        
        # Suggestions list
        self.list_widget = QListWidget()
        self.list_widget.setStyleSheet("""
            QListWidget {
                background-color: white;
                border: 1px solid #ccc;
                border-radius: 8px;
                padding: 4px;
            }
            QListWidget::item {
                border: 1px solid #e0e0e0;
                border-radius: 6px;
                padding: 8px;
                margin: 4px;
            }
            QListWidget::item:selected {
                background-color: #e3f2fd;
                border: 2px solid #2196F3;
            }
        """)
        self.list_widget.itemClicked.connect(self._on_item_clicked)
        layout.addWidget(self.list_widget)
        
        self.setLayout(layout)
        
        # Style
        self.setStyleSheet("""
            QWidget {
                background-color: #f5f5f5;
                border-radius: 16px;
            }
        """)
    
    def show_suggestions(self, suggestions, context=""):
        """Show suggestions overlay
        
        Args:
            suggestions: List of Item objects
            context: Search context string
        """
        print(f"📋 Showing {len(suggestions)} suggestions")
        
        self.suggestions = suggestions
        self.selected_index = 0
        
        # Clear list
        self.list_widget.clear()
        
        # Add suggestions
        for idx, item in enumerate(suggestions, 1):
            # Create list item
            content_preview = item.content[:100]
            if len(item.content) > 100:
                content_preview += "..."
            
            item_text = f"{idx}. {content_preview}"
            if item.app_name:
                item_text += f"\n   App: {item.app_name}"
            if item.tags:
                item_text += f"\n   Tags: {', '.join(item.tags[:3])}"
            
            list_item = QListWidgetItem(item_text)
            self.list_widget.addItem(list_item)
        
        # Select first item
        if suggestions:
            self.list_widget.setCurrentRow(0)
        
        # Position in bottom-left
        self._position_bottom_left()
        
        # Show
        self.show()
        self.raise_()
        self.activateWindow()
    
    def _position_bottom_left(self):
        """Position overlay in bottom-left corner"""
        from PyQt5.QtWidgets import QApplication
        screen = QApplication.primaryScreen().geometry()
        
        # Position with some padding
        x = 20
        y = screen.height() - self.height() - 20
        
        self.move(x, y)
    
    def keyPressEvent(self, event):
        """Handle keyboard events"""
        if event.key() == Qt.Key_Escape:
            print("📋 ESC pressed - dismissing suggestions")
            self.dismissed.emit()
            self.hide()
        
        elif event.key() == Qt.Key_Down:
            # Move selection down
            current = self.list_widget.currentRow()
            if current < len(self.suggestions) - 1:
                self.list_widget.setCurrentRow(current + 1)
        
        elif event.key() == Qt.Key_Up:
            # Move selection up
            current = self.list_widget.currentRow()
            if current > 0:
                self.list_widget.setCurrentRow(current - 1)
        
        elif event.key() in (Qt.Key_Return, Qt.Key_Enter):
            # Select current item
            self._select_current_item()
        
        elif Qt.Key_1 <= event.key() <= Qt.Key_9:
            # Number keys 1-9
            idx = event.key() - Qt.Key_1
            if idx < len(self.suggestions):
                self.list_widget.setCurrentRow(idx)
                self._select_current_item()
        
        else:
            super().keyPressEvent(event)
    
    def _select_current_item(self):
        """Select and emit current item"""
        current_row = self.list_widget.currentRow()
        if 0 <= current_row < len(self.suggestions):
            selected_item = self.suggestions[current_row]
            print(f"📋 Selected item: {selected_item.content[:50]}...")
            self.item_selected.emit(selected_item)
            self.hide()
    
    def _on_item_clicked(self, list_item):
        """Handle list item click"""
        self._select_current_item()

