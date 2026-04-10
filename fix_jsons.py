import json
import glob
import re
import os

assets_dir = 'c:/la-previa/assets'

# Find all events json
event_files = glob.glob(f'{assets_dir}/events*.json')

for filepath in event_files:
    with open(filepath, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    modified = False
    for event in data.get('events', []):
        # 1. Remove EVENTO: / EVENT: from templates
        if 'template' in event:
            new_template = re.sub(r'^(EVENTO:\s*|EVENT:\s*)', '', event['template'])
            if new_template != event['template']:
                event['template'] = new_template
                modified = True
                
        # 2. Fix multiplier if title is Tragos Dobles / Double Drinks
        title = event.get('title', '')
        if 'Tragos Dobles' in title or 'Double Drinks' in title:
            if 'variables' in event and 'MULTIPLIER' in event['variables']:
                if event['variables']['MULTIPLIER'] != ['2']:
                    event['variables']['MULTIPLIER'] = ['2']
                    modified = True

    if modified:
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)

# Fix English words in Spanish question jsons (shots -> chupitos)
question_files = [f for f in glob.glob(f'{assets_dir}/questions*.json') if '_en' not in f]
for filepath in question_files:
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Simple regex to replace 'shots' with 'chupitos' (case insensitive)
    if re.search(r'\b(shots|shot)\b', content, re.IGNORECASE):
        # Be careful not to replace ID or English keys if any, but since it's ES, should be safe in text. 
        # But wait, "shots" might be perfectly matched in text
        data = json.loads(content)
        modified = False
        for q in data.get('questions', []):
            if 'text' in q:
                new_text = re.sub(r'\bshots\b', 'chupitos', q['text'], flags=re.IGNORECASE)
                new_text = re.sub(r'\bshot\b', 'chupito', new_text, flags=re.IGNORECASE)
                if new_text != q['text']:
                    q['text'] = new_text
                    modified = True
            
        if modified:
            with open(filepath, 'w', encoding='utf-8') as f:
                json.dump(data, f, ensure_ascii=False, indent=2)

print("Finished fixing events and question jsons")
