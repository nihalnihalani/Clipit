"""AI service using LFM2-350M model"""
import json
import re
from transformers import AutoModelForCausalLM, AutoTokenizer
import torch

class AIService:
    """AI service for answer generation and tagging using LFM2-350M"""
    
    def __init__(self, model_name="meta-llama/Llama-3.2-1B"):
        """Initialize AI service with LFM2-350M model
        
        Note: Using Llama-3.2-1B as a fallback since LFM2-350M might not be publicly available.
        You can change this to the actual model name when available.
        """
        self.model_name = model_name
        self.model = None
        self.tokenizer = None
        self.is_initialized = False
        
        print(f"🤖 Initializing AI service with model: {model_name}")
        self._load_model()
    
    def _load_model(self):
        """Load the model and tokenizer"""
        try:
            print(f"   Loading tokenizer...")
            self.tokenizer = AutoTokenizer.from_pretrained(self.model_name)
            
            print(f"   Loading model (this may take a while)...")
            self.model = AutoModelForCausalLM.from_pretrained(
                self.model_name,
                torch_dtype=torch.float16 if torch.cuda.is_available() else torch.float32,
                device_map="auto" if torch.cuda.is_available() else None,
                low_cpu_mem_usage=True
            )
            
            # Set padding token if not set
            if self.tokenizer.pad_token is None:
                self.tokenizer.pad_token = self.tokenizer.eos_token
            
            self.is_initialized = True
            device = "GPU" if torch.cuda.is_available() else "CPU"
            print(f"   ✅ Model loaded successfully on {device}")
            
        except Exception as e:
            print(f"   ❌ Failed to load model: {e}")
            print(f"   💡 Tip: Make sure you have access to the model and sufficient RAM")
            self.is_initialized = False
    
    def generate_answer(self, question, clipboard_context, app_name=None):
        """Generate answer based on question and clipboard context
        
        Args:
            question: User's question
            clipboard_context: List of (content, tags) tuples
            app_name: Current application name
            
        Returns:
            tuple: (answer_text, image_index) where image_index is None for text answers
        """
        if not self.is_initialized:
            print("❌ Model not initialized")
            return None, None
        
        print(f"🤖 Generating answer for: '{question}'")
        print(f"   Clipboard items: {len(clipboard_context)}")
        
        # Build prompt
        prompt = self._build_answer_prompt(question, clipboard_context, app_name)
        
        # Generate response
        try:
            inputs = self.tokenizer(prompt, return_tensors="pt", truncation=True, max_length=2048)
            
            if torch.cuda.is_available():
                inputs = {k: v.cuda() for k, v in inputs.items()}
            
            with torch.no_grad():
                outputs = self.model.generate(
                    **inputs,
                    max_new_tokens=256,
                    temperature=0.7,
                    do_sample=True,
                    pad_token_id=self.tokenizer.pad_token_id,
                    eos_token_id=self.tokenizer.eos_token_id
                )
            
            response = self.tokenizer.decode(outputs[0], skip_special_tokens=True)
            
            # Extract answer from response
            answer = self._extract_answer(response, prompt)
            
            print(f"   ✅ Generated answer: {answer[:100]}...")
            return answer, None
            
        except Exception as e:
            print(f"   ❌ Error generating answer: {e}")
            return None, None
    
    def generate_tags(self, content, app_name=None, context=None):
        """Generate semantic tags for content
        
        Args:
            content: Clipboard content
            app_name: Application name
            context: Additional context
            
        Returns:
            list: List of tags (3-7 tags)
        """
        if not self.is_initialized:
            return []
        
        print(f"🏷️  Generating tags for: {content[:50]}...")
        
        # Build prompt
        prompt = self._build_tagging_prompt(content, app_name, context)
        
        # Generate response
        try:
            inputs = self.tokenizer(prompt, return_tensors="pt", truncation=True, max_length=512)
            
            if torch.cuda.is_available():
                inputs = {k: v.cuda() for k, v in inputs.items()}
            
            with torch.no_grad():
                outputs = self.model.generate(
                    **inputs,
                    max_new_tokens=100,
                    temperature=0.3,
                    do_sample=True,
                    pad_token_id=self.tokenizer.pad_token_id
                )
            
            response = self.tokenizer.decode(outputs[0], skip_special_tokens=True)
            
            # Extract tags from response
            tags = self._extract_tags(response)
            
            print(f"   ✅ Generated tags: {tags}")
            return tags
            
        except Exception as e:
            print(f"   ❌ Error generating tags: {e}")
            return []
    
    def _build_answer_prompt(self, question, clipboard_context, app_name):
        """Build prompt for answer generation"""
        context_text = ""
        if clipboard_context:
            context_items = []
            for idx, (content, tags) in enumerate(clipboard_context, 1):
                tags_text = f" [Tags: {', '.join(tags)}]" if tags else ""
                context_items.append(f"[{idx}]{tags_text}\n{content[:500]}")
            context_text = "\n\n---\n\n".join(context_items)
        else:
            context_text = "No clipboard context available."
        
        prompt = f"""You are Clipit assistant. Answer the user's question based on their clipboard history.

User Question: {question}

Clipboard Context:
{context_text}

App: {app_name or 'Unknown'}

Instructions:
- Extract and return ONLY the specific information requested
- Do NOT add preamble or explanations
- Just return the raw data
- If not relevant, return empty string

Return JSON format:
{{"A": "your answer here"}}

Answer:"""
        
        return prompt
    
    def _build_tagging_prompt(self, content, app_name, context):
        """Build prompt for tag generation"""
        prompt = f"""Generate 3-7 semantic tags for this clipboard item. Focus on content type, domain, and key topics.

App: {app_name or 'Unknown'}
Content: {content[:500]}

Return JSON format:
{{"tags": ["tag1", "tag2", "tag3"]}}

Tags:"""
        
        return prompt
    
    def _extract_answer(self, response, prompt):
        """Extract answer from model response"""
        # Remove the prompt from response
        if prompt in response:
            response = response.replace(prompt, "").strip()
        
        # Try to extract JSON
        json_match = re.search(r'\{[^}]*"A"[^}]*\}', response)
        if json_match:
            try:
                json_obj = json.loads(json_match.group(0))
                return json_obj.get("A", "").strip()
            except:
                pass
        
        # Fallback: return cleaned response
        return response.strip()
    
    def _extract_tags(self, response):
        """Extract tags from model response"""
        # Try to extract JSON
        json_match = re.search(r'\{[^}]*"tags"[^}]*\}', response)
        if json_match:
            try:
                json_obj = json.loads(json_match.group(0))
                tags = json_obj.get("tags", [])
                # Lowercase and filter
                return [tag.lower().strip() for tag in tags if tag.strip()][:7]
            except:
                pass
        
        # Fallback: try to parse comma-separated
        # Look for lines that might be tags
        lines = response.split('\n')
        for line in lines:
            if ',' in line and len(line) < 200:
                tags = [t.strip().lower() for t in line.split(',') if t.strip()]
                if tags:
                    return tags[:7]
        
        return []

