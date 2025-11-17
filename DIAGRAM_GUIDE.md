# How to Create Architecture Diagrams for ClipIt

This guide shows you how to create visual architecture diagrams using various tools.

## 📊 Available Diagram Formats

We've created comprehensive diagrams in **ARCHITECTURE.md** using Mermaid syntax. Here's how to view and create more diagrams:

---

## 1. View Mermaid Diagrams on GitHub

**No tools needed!** GitHub automatically renders Mermaid diagrams.

Just push the `ARCHITECTURE.md` file and view it on GitHub:
```bash
git add ARCHITECTURE.md
git commit -m "Add architecture documentation with Mermaid diagrams"
git push
```

Then open on GitHub: `https://github.com/nihalnihalani/Clipit/blob/nihal-clipit-changes/ARCHITECTURE.md`

---

## 2. Generate PNG/SVG Images from Mermaid

### Install mermaid-cli:
```bash
npm install -g @mermaid-js/mermaid-cli
```

### Generate images:
```bash
# Generate PNG (high resolution)
mmdc -i ARCHITECTURE.md -o architecture-full.png -w 2000

# Generate SVG (vector, scalable)
mmdc -i ARCHITECTURE.md -o architecture-full.svg

# Generate specific diagram (extract to temp file first)
mmdc -i system-overview.mmd -o system-overview.png
```

---

## 3. Online Mermaid Editors

### [Mermaid Live Editor](https://mermaid.live/) (Recommended)
1. Go to https://mermaid.live/
2. Copy any mermaid code block from `ARCHITECTURE.md`
3. Paste into the editor
4. Download as PNG/SVG

### [Draw.io with Mermaid Plugin](https://app.diagrams.net/)
1. Go to https://app.diagrams.net/
2. Extras → Plugins → Add → "Mermaid"
3. Insert → Advanced → Mermaid

---

## 4. Create Diagrams with Draw.io (Visual Editor)

**Best for**: Non-technical stakeholders, presentations

### Steps:
1. Go to https://app.diagrams.net/
2. Choose where to save (Google Drive, OneDrive, Device)
3. Create new diagram

### Recommended Templates:
- **System Architecture**: Use "AWS Architecture" template
- **Sequence Diagrams**: Use "UML Sequence" template
- **Component Diagrams**: Use "UML Component" template
- **Flow Charts**: Use "Basic Flowchart" template

### Export:
- File → Export as → PNG (for documentation)
- File → Export as → SVG (for scaling)
- File → Export as → PDF (for presentations)

---

## 5. Create Diagrams with Lucidchart

**Best for**: Professional presentations, collaboration

1. Go to https://lucid.app/
2. Create free account
3. Use templates:
   - AWS Architecture
   - System Context Diagram
   - Sequence Diagram
   - Entity Relationship Diagram

### Import existing diagrams:
- Can import Draw.io files
- Can import Visio files

---

## 6. Create Diagrams with Microsoft Visio

**Best for**: Enterprise environments, Windows users

1. Open Visio
2. Choose template:
   - **Software and Database** → Software System
   - **Flowchart** → Cross-Functional Flowchart
   - **Software and Database** → UML Sequence

3. Use our architecture as reference

---

## 7. Create Diagrams in VS Code

**Best for**: Developers who want to keep diagrams in code

### Install Extensions:
```bash
code --install-extension bierner.markdown-mermaid
code --install-extension hediet.vscode-drawio
```

### Use Mermaid:
1. Open `ARCHITECTURE.md` in VS Code
2. Press `Ctrl+Shift+V` (or `Cmd+Shift+V` on Mac)
3. Preview renders Mermaid diagrams

### Use Draw.io integration:
1. Create `architecture.drawio.svg` file
2. Edit visually in VS Code
3. Commit as SVG (can be viewed on GitHub)

---

## 8. Generate Diagrams from Code

### Using Graphviz:
```bash
# Install Graphviz
brew install graphviz  # Mac
# or download from https://graphviz.org/download/

# Create DOT file
cat > clipit-structure.dot <<EOF
digraph ClipIt {
    rankdir=TB;
    node [shape=box, style=rounded];
    
    Main [label="main.py"];
    Clipboard [label="Clipboard Monitor"];
    AI [label="AI Service"];
    UI [label="UI Components"];
    DB [label="Database"];
    
    Main -> Clipboard;
    Main -> AI;
    Main -> UI;
    Clipboard -> DB;
    AI -> DB;
}
EOF

# Generate PNG
dot -Tpng clipit-structure.dot -o clipit-structure.png

# Generate SVG
dot -Tsvg clipit-structure.dot -o clipit-structure.svg
```

### Using PlantUML:
```bash
# Install PlantUML
brew install plantuml  # Mac
# or download from https://plantuml.com/download

# Create .puml file
cat > sequence.puml <<EOF
@startuml
actor User
participant "Hotkey Manager" as HK
participant "Text Capture" as TC
participant "AI Service" as AI
participant "Database" as DB

User -> HK: Press Alt+X
HK -> TC: Start capturing
TC -> User: Show "Listening..."

User -> TC: Types question
TC -> AI: Generate answer
AI -> DB: Query history
DB -> AI: Return items
AI -> TC: Return answer
TC -> User: Replace text

@enduml
EOF

# Generate PNG
plantuml sequence.puml

# Generate SVG
plantuml -tsvg sequence.puml
```

---

## 9. Python Code to Generate Diagrams

### Using Diagrams library:
```bash
pip install diagrams
```

```python
# create_architecture.py
from diagrams import Diagram, Cluster
from diagrams.programming.language import Python
from diagrams.onprem.database import SQLite
from diagrams.custom import Custom

with Diagram("ClipIt Architecture", show=False, direction="TB"):
    with Cluster("User Interface"):
        ui = Python("PyQt5 UI")
    
    with Cluster("Services"):
        clipboard = Python("Clipboard Monitor")
        ai = Python("AI Service")
        ocr = Python("OCR Service")
    
    with Cluster("Data"):
        db = SQLite("SQLite DB")
    
    ui >> clipboard >> db
    ui >> ai >> db
    ui >> ocr >> db
```

Run:
```bash
python create_architecture.py
# Generates: clipit_architecture.png
```

---

## 10. Quick ASCII Art Diagrams

For simple diagrams in README or code comments:

```
User → Hotkey Manager → Text Capture Service
                              ↓
                         AI Service ← Database
                              ↓
                         Text Replacement
```

---

## 11. Presentation Slides

### PowerPoint/Keynote/Google Slides:

**Template structure:**

**Slide 1: System Overview**
```
┌────────────────────────────────────┐
│    ClipIt System Architecture      │
├────────────────────────────────────┤
│                                     │
│  [User] → [UI Layer] → [Services]  │
│                ↓                    │
│           [Database]                │
│                                     │
└────────────────────────────────────┘
```

**Slide 2: Data Flow**
- Use animated arrows
- Step-by-step reveal

**Slide 3: Component Details**
- Drill down into each component

---

## 12. Interactive Diagrams

### Using Mermaid + HTML:
Create `architecture.html`:
```html
<!DOCTYPE html>
<html>
<head>
    <script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
</head>
<body>
    <div class="mermaid">
    graph TB
        User[User] --> UI[User Interface]
        UI --> Services[Services]
        Services --> DB[Database]
    </div>
    <script>mermaid.initialize({startOnLoad:true});</script>
</body>
</html>
```

Open in browser for interactive diagram.

---

## 13. Documentation Generators

### Using Sphinx + Graphviz:
```bash
pip install sphinx sphinx-rtd-theme

# Generate docs
sphinx-quickstart
# Add graphviz extension
# Add diagrams to .rst files
make html
```

### Using MkDocs:
```bash
pip install mkdocs mkdocs-material mkdocs-mermaid2-plugin

# Create mkdocs.yml
cat > mkdocs.yml <<EOF
site_name: ClipIt Documentation
theme:
  name: material
plugins:
  - search
  - mermaid2
EOF

# Create docs with mermaid diagrams
mkdocs serve
```

---

## 14. Recommended Tool by Use Case

| Use Case | Recommended Tool | Why |
|----------|------------------|-----|
| **Quick documentation** | Mermaid in Markdown | Version controlled, renders on GitHub |
| **Presentation slides** | PowerPoint + Draw.io | Professional, easy to present |
| **Collaboration** | Lucidchart | Real-time collaboration |
| **Developer docs** | Mermaid in VS Code | Stays with code, no external tools |
| **Print materials** | Visio or Draw.io | High quality exports |
| **Interactive docs** | MkDocs + Mermaid | Beautiful, searchable docs site |
| **Code generation** | Python Diagrams | Programmatic, repeatable |
| **Technical specs** | PlantUML | Standard UML notation |

---

## 15. Tips for Good Architecture Diagrams

### Do's:
✅ Use consistent colors (we use color coding in our diagrams)
✅ Add legends explaining symbols
✅ Keep it simple - one concept per diagram
✅ Use standard notation (UML, C4, etc.)
✅ Include timestamps/version numbers
✅ Label all arrows and connections
✅ Group related components

### Don'ts:
❌ Don't overcrowd - split into multiple diagrams
❌ Don't use too many colors - stick to 4-5 max
❌ Don't forget labels - every box needs a name
❌ Don't ignore alignment - use grids
❌ Don't skip the legend
❌ Don't make diagrams too small to read

---

## 16. Our Diagram Color Scheme

We use consistent colors across all diagrams:

```
#ff6b6b - Main application / Critical paths
#4ecdc4 - AI/ML components
#95e1d3 - Data layer
#f9ca24 - Services
#a8dadc - External systems
#ffe66d - Models/AI models
#fff4e1 - Windows API
#e1f5ff - User interaction
#ffe1e1 - AI processing
#e1ffe1 - Database
```

---

## 17. Exporting Diagrams for Different Formats

### For GitHub README:
- Use Mermaid inline (renders automatically)
- Or export as PNG and embed: `![Architecture](architecture.png)`

### For Documentation:
- Export as SVG (scales perfectly)
- Or use Mermaid directly in Markdown

### For Presentations:
- Export as high-res PNG (300 DPI)
- Use transparent background
- Export at 2x size for retina displays

### For Print:
- Export as PDF or high-res PNG
- Use vector format (SVG/PDF) when possible
- Ensure text is readable at print size

---

## 18. Quick Start Commands

### One-line diagram generation:
```bash
# Install all tools
npm install -g @mermaid-js/mermaid-cli
pip install diagrams graphviz

# Generate all diagrams
mmdc -i ARCHITECTURE.md -o diagrams/
python create_architecture.py
```

### Update all diagrams script:
```bash
#!/bin/bash
# update-diagrams.sh

echo "Generating architecture diagrams..."

# Mermaid diagrams
mmdc -i ARCHITECTURE.md -o docs/architecture-full.png -w 2000

# Python diagrams
python scripts/create_architecture.py

# Graphviz
dot -Tpng docs/structure.dot -o docs/structure.png

echo "✅ All diagrams updated!"
```

---

## 19. Version Control for Diagrams

### Store source files:
```
docs/
├── diagrams/
│   ├── architecture.mermaid      # Mermaid source
│   ├── system-flow.drawio        # Draw.io source
│   ├── sequence.puml             # PlantUML source
│   └── structure.dot             # Graphviz source
├── images/                       # Generated images
│   ├── architecture.png
│   ├── system-flow.svg
│   ├── sequence.png
│   └── structure.png
└── ARCHITECTURE.md               # Main documentation
```

### Add to .gitignore (optional):
```
# Don't version generated images, only source
docs/images/*.png
docs/images/*.svg

# But keep the source files
!docs/diagrams/*
```

---

## 20. Examples from Other Projects

### Inspired by:
- **Kubernetes**: https://kubernetes.io/docs/concepts/architecture/
- **Docker**: https://docs.docker.com/get-started/overview/
- **Redis**: https://redis.io/docs/manual/
- **Django**: https://docs.djangoproject.com/en/stable/

All use Mermaid or similar for documentation.

---

## Need Help?

1. Check `ARCHITECTURE.md` for complete Mermaid diagrams
2. Use GitHub to view rendered diagrams
3. Try Mermaid Live Editor: https://mermaid.live/
4. Ask in issues if you need specific diagram types

---

**Last Updated**: 2025-11-16  
**Created for**: ClipIt Project

