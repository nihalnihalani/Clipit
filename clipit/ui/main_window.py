"""Main application window"""
from PyQt5.QtWidgets import (QMainWindow, QWidget, QVBoxLayout, QHBoxLayout,
                             QPushButton, QLabel, QListWidget, QListWidgetItem,
                             QMessageBox, QSystemTrayIcon, QMenu, QAction)
from PyQt5.QtCore import Qt, pyqtSignal
from PyQt5.QtGui import QIcon, QFont
from datetime import datetime

class MainWindow(QMainWindow):
    """Main Clipit window showing clipboard history"""
    
    def __init__(self, clipboard_monitor, ai_service):
        super().__init__()
        self.clipboard_monitor = clipboard_monitor
        self.ai_service = ai_service
        
        self._init_ui()
        self._create_system_tray()
    
    def _init_ui(self):
        """Initialize the UI"""
        self.setWindowTitle("Clipit - Smart Clipboard Manager")
        self.setGeometry(100, 100, 600, 700)
        
        # Central widget
        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        
        # Main layout
        layout = QVBoxLayout()
        layout.setSpacing(12)
        layout.setContentsMargins(16, 16, 16, 16)
        
        # Title
        title_label = QLabel("📋 Clipit - Smart Clipboard Manager")
        title_label.setFont(QFont("Arial", 16, QFont.Bold))
        layout.addWidget(title_label)
        
        # Status section
        status_layout = QHBoxLayout()
        
        self.status_label = QLabel("Status: Monitoring")
        self.status_label.setStyleSheet("color: green; font-weight: bold;")
        status_layout.addWidget(self.status_label)
        
        status_layout.addStretch()
        
        # Control buttons
        self.toggle_btn = QPushButton("Stop Monitoring")
        self.toggle_btn.clicked.connect(self._toggle_monitoring)
        status_layout.addWidget(self.toggle_btn)
        
        clear_btn = QPushButton("Clear History")
        clear_btn.clicked.connect(self._clear_history)
        status_layout.addWidget(clear_btn)
        
        layout.addLayout(status_layout)
        
        # Hotkeys info
        hotkeys_label = QLabel(
            "⌨️ Hotkeys: Alt+X (Ask AI) • Alt+V (OCR) • Alt+S (Suggestions)"
        )
        hotkeys_label.setStyleSheet("""
            background-color: #e3f2fd;
            padding: 8px;
            border-radius: 6px;
            color: #1976d2;
        """)
        layout.addWidget(hotkeys_label)
        
        # AI status
        self.ai_status_label = QLabel("🤖 AI Model: LFM2-350M (Loading...)")
        self.ai_status_label.setStyleSheet("padding: 4px; color: #666;")
        layout.addWidget(self.ai_status_label)
        
        # Clipboard history list
        history_label = QLabel("Clipboard History:")
        history_label.setFont(QFont("Arial", 12, QFont.Bold))
        layout.addWidget(history_label)
        
        self.history_list = QListWidget()
        self.history_list.setStyleSheet("""
            QListWidget {
                border: 1px solid #ccc;
                border-radius: 8px;
                padding: 4px;
            }
            QListWidget::item {
                border-bottom: 1px solid #e0e0e0;
                padding: 8px;
            }
            QListWidget::item:selected {
                background-color: #e3f2fd;
            }
        """)
        self.history_list.itemDoubleClicked.connect(self._on_item_double_clicked)
        layout.addWidget(self.history_list)
        
        # Refresh button
        refresh_btn = QPushButton("🔄 Refresh History")
        refresh_btn.clicked.connect(self.refresh_history)
        layout.addWidget(refresh_btn)
        
        central_widget.setLayout(layout)
        
        # Update AI status
        if self.ai_service and self.ai_service.is_initialized:
            self.ai_status_label.setText(f"🤖 AI Model: {self.ai_service.model_name} (Ready)")
            self.ai_status_label.setStyleSheet("padding: 4px; color: green;")
        else:
            self.ai_status_label.setText("🤖 AI Model: Not initialized")
            self.ai_status_label.setStyleSheet("padding: 4px; color: red;")
    
    def _create_system_tray(self):
        """Create system tray icon"""
        self.tray_icon = QSystemTrayIcon(self)
        self.tray_icon.setToolTip("Clipit - Smart Clipboard Manager")
        
        # Create tray menu
        tray_menu = QMenu()
        
        show_action = QAction("Show Window", self)
        show_action.triggered.connect(self.show)
        tray_menu.addAction(show_action)
        
        tray_menu.addSeparator()
        
        quit_action = QAction("Quit", self)
        quit_action.triggered.connect(self.close)
        tray_menu.addAction(quit_action)
        
        self.tray_icon.setContextMenu(tray_menu)
        self.tray_icon.activated.connect(self._on_tray_activated)
        
        # Show tray icon
        self.tray_icon.show()
    
    def _on_tray_activated(self, reason):
        """Handle tray icon activation"""
        if reason == QSystemTrayIcon.DoubleClick:
            self.show()
            self.raise_()
            self.activateWindow()
    
    def _toggle_monitoring(self):
        """Toggle clipboard monitoring"""
        if self.clipboard_monitor.is_monitoring:
            self.clipboard_monitor.stop_monitoring()
            self.status_label.setText("Status: Stopped")
            self.status_label.setStyleSheet("color: red; font-weight: bold;")
            self.toggle_btn.setText("Start Monitoring")
        else:
            self.clipboard_monitor.start_monitoring()
            self.status_label.setText("Status: Monitoring")
            self.status_label.setStyleSheet("color: green; font-weight: bold;")
            self.toggle_btn.setText("Stop Monitoring")
    
    def _clear_history(self):
        """Clear clipboard history"""
        reply = QMessageBox.question(
            self,
            "Clear History",
            "Are you sure you want to clear all clipboard history?",
            QMessageBox.Yes | QMessageBox.No,
            QMessageBox.No
        )
        
        if reply == QMessageBox.Yes:
            # Clear from database
            session = self.clipboard_monitor.session
            from clipit.models.item import Item
            session.query(Item).delete()
            session.commit()
            
            print("🗑️ Clipboard history cleared")
            self.refresh_history()
    
    def refresh_history(self):
        """Refresh clipboard history display"""
        print("🔄 Refreshing clipboard history...")
        
        # Clear list
        self.history_list.clear()
        
        # Get recent items
        items = self.clipboard_monitor.get_recent_items(limit=50)
        
        print(f"   Found {len(items)} items")
        
        # Add to list
        for item in items:
            # Format item
            content_preview = item.content[:80]
            if len(item.content) > 80:
                content_preview += "..."
            
            # Build display text
            item_text = f"{content_preview}"
            if item.app_name:
                item_text += f"\n   App: {item.app_name}"
            if item.tags:
                item_text += f" • Tags: {', '.join(item.tags[:3])}"
            
            # Format timestamp
            time_str = item.timestamp.strftime("%Y-%m-%d %H:%M:%S")
            item_text += f"\n   {time_str}"
            
            # Add to list
            list_item = QListWidgetItem(item_text)
            list_item.setData(Qt.UserRole, item)  # Store item object
            
            # Color code by type
            if item.content_type == "image":
                list_item.setForeground(Qt.blue)
            
            self.history_list.addItem(list_item)
        
        print("   ✅ History refreshed")
    
    def _on_item_double_clicked(self, list_item):
        """Handle item double click - copy to clipboard"""
        item = list_item.data(Qt.UserRole)
        if item:
            import win32clipboard
            
            try:
                win32clipboard.OpenClipboard()
                win32clipboard.EmptyClipboard()
                win32clipboard.SetClipboardText(item.content)
                win32clipboard.CloseClipboard()
                
                print(f"📋 Copied to clipboard: {item.content[:50]}...")
                
                # Show temporary message
                self.statusBar().showMessage("Copied to clipboard!", 2000)
            except Exception as e:
                print(f"❌ Failed to copy: {e}")
    
    def closeEvent(self, event):
        """Handle window close event"""
        # Minimize to tray instead of closing
        event.ignore()
        self.hide()
        self.tray_icon.showMessage(
            "Clipit",
            "Application minimized to system tray",
            QSystemTrayIcon.Information,
            2000
        )

